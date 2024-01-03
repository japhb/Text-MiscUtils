unit module Text::MiscUtils::Layout;


# Needed for colorstrip() to handle laying out already-colored text
use Terminal::ANSIColor;


#| Format a simple glanceable Unicode 1.1 horizontal ruler
sub horizontal-ruler(UInt:D $width = 80) is export {
    # 16:9  - 64x18, 80x22.5, 96x27, 112x31.5, 128x36
    # 16:10 - 64x20, 80x25,   96x30, 112x35,   128x40

    constant $nine    = '¹²³⁴⁵⁶⁷⁸⁹';
    constant @markers = flat (1..9).map({ chr($_ + 0x2775) }), '│';
    constant $hundred = @markers.map({ $nine ~ $_ }).join;

    my $ruler = $hundred x (ceiling $width / 100);
    substr($ruler, 0, $width)
}


#| Calculate monospaced width of a single line of text, ignoring ANSI colors
#  XXXX: Does not handle cursor-movement control characters such as TAB
sub duospace-width(Str:D $text, Bool :$wide-context = False) is export {
    # OLD APPROXIMATION, simply counting NFG characters
    # colorstrip($text).chars

    # Unicode TR11 approximation, based on legacy character set display width
    # compatibility and General_Category visibility -- first strip out ANSI
    # codes and likely invisible/non-spacing Unicode characters, then sum the
    # counts of remaining characters in each width category
    my constant %ignore = < Mn Mc Me Cc Cf Cs Co Cn > Z=> 1 xx *;
    my $counts = colorstrip($text)
                 .ords
                 .map({ .uniprop('East_Asian_Width') unless %ignore{.uniprop} })
                 .Bag;

    $counts<N> + $counts<Na> + $counts<H>   # Generally narrow
    + 2 * ($counts<F> + $counts<W>)         # Always wide
    + (1 + $wide-context) * $counts<A>      # Context-dependent
}


#| Wrap a single line of (possibly ANSI colored) $text to a given $width
#  Returns an array of wrapped lines with no trailing newlines.
#  Doesn't try to split single words wider than $width.
#  Tries to maintain any leading indent, but does not account for tabs.
sub text-wrap(UInt:D $width is copy, Str:D $text is copy) is export {
    $text    .= trim-trailing;
    $width max= 1;

    return [''] if $text.match(/^\s*$/);

    my @pieces = $text.split(/\s+/);

    my $indent = '';
    if !@pieces[0] {
        @pieces.shift;
        $indent = ~$text.match(/^(\s+)/)[0];
    }
    my $ilen = duospace-width($indent);

    my @lines;
    my $cur = 0;
    while @pieces.shift -> $piece {
        my $len = duospace-width($piece);
        if !$cur || $cur + $len + 1 > $width {
            @lines.push: "$indent$piece";
            $cur = $ilen + $len;
        }
        else {
            @lines[*-1] ~= ' ' ~ $piece;
            $cur += $len + 1;
        }
    }

    @lines
}


#| Duospace-aware text wrapper utility:
#| Wrap (possibly ANSI colored) $text to $width, adding $prefix at the start of
#| each line AFTER the first, and $first-prefix to the start of the FIRST line.
#| Fills lines with spaces to exact width if $fill-trailing is True (default).
#
#  Differs from text-wrap above:
#    * Accepts explicit indent/prefix values, rather than trying to guess
#    * Defaults to filling short lines with trailing spaces to match width
#    * Returns an empty array if $text contains only whitespace or is empty
#
sub wrap-text(UInt:D $width, Str:D $text, Bool:D :$fill-trailing = True,
              Str:D :$prefix = '', Str:D :$first-prefix = '') is export {
    my @words = $text.words;
    return [] unless @words;

    # Quick out for short text; still joins @words to maintain consistent spacing
    if $width >= duospace-width($first-prefix ~ $text) {
        my $line = $first-prefix ~ @words.join(' ');
        return $line ~ (' ' x ($width - duospace-width($line)) if $fill-trailing);
    }

    # Invariants:
    #  * Latest line in @lines always contains at least a prefix and one word
    #  * No line is wider than $width unless it contains only ONE too-long word
    #    (no attempt is made to split single words across multiple lines or to
    #    modify the prefix in such cases)
    my @lines = $first-prefix ~ @words.shift;
    my $cur   = duospace-width(@lines[0]);
    my $plen  = duospace-width($prefix);

    for @words -> $word {
        my $len = duospace-width($word);
        # If next word won't fit, use it to start a new line
        if $cur + $len + 1 > $width {
            @lines[*-1] ~= ' ' x ($width - $cur) if $fill-trailing && $width > $cur;
            @lines.push: "$prefix$word";
            $cur = $plen + $len;
        }
        # ... otherwise just extend the last line
        else {
            @lines[*-1] ~= " $word";
            $cur += $len + 1;
        }
    }
    @lines[*-1] ~= ' ' x ($width - $cur) if $fill-trailing && $width > $cur;

    @lines
}


#| Render an array of (possibly ANSI colored) multi-line text blocks horizontally into $width-sized columns
#  Thus (5, "12\n34\n", "abc\ndefg\nhi", :sep<|>) --> "12   |abc  \n34   |defg \n     |hi   "
sub text-columns(UInt:D $width, *@blocks, Str:D :$sep = '  ', Bool :$force-wrap) is export {
    my @fitted;
    for @blocks -> $block {
        @fitted.push: $block.split(/\n/).flatmap({
            duospace-width($_) <= $width && !$force-wrap ?? $_ !! text-wrap($width, $_)
        });
    }

    # See http://irclog.perlgeek.de/perl6/2016-07-13#i_12834465
    # for discussion about the ragged transpose operation
    my $max = @fitted.map(*.elems).max;
    my @rows = zip @fitted.map(*.[^$max]);

    @rows.map({ .map({ my $row = $^a || ''; $row ~ ' ' x max(0, $width - duospace-width($row)) }).join($sep) }).join("\n")
}


#| Render an array of (possibly ANSI colored) text cells into one evenly spaced line justified to $width
#  Adds at least one space between the cells, even if it makes the line longer than $width.
sub evenly-spaced(UInt:D $width, *@cells) is export {
    my @c = @cells.grep: *.chars;
    return '' unless @c;

    my $gaps  = max 1, @c - 1;
    my $chars = @c.map({ duospace-width($_) }).sum;
    my $pad   = ($width - $chars) / $gaps;

    my $line = '';
    my $used = 0;
    for @c.kv -> $col, $text {
        my $spaces = max 1, round($pad * ($col + 1) - $used);
        $used += $spaces;
        $line ~= $text;
        $line ~= ' ' x $spaces unless $col == @c.end;
    }

    $line
}
