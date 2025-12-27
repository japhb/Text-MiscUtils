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


#| Calculate monospaced width of a single line of text, accounting for
#| narrow and wide characters, ignoring ANSI SGR color/attribute escapes
#  XXXX: Does not handle cursor-movement control characters such as TAB
sub duospace-width(Str:D $text, Bool :$wide-context = False) is export {
    duospace-width-core((my str $str = colorstrip($text)),
                        (my int $context = +$wide-context))
}

#| Optimized core for duospace-width, when colorstrip is known NOT needed.
#| If you're not sure which to use, use the regular duospace-width routine.
#|
#| Like duospace-width, calculates monospace width of a single line of text,
#| while being aware of narrow and wide codepoints using the Unicode TR11
#| width approximation: ignore likely invisible/non-spacing codepoints then
#| sum the width of the remaining codepoints using their East_Asian_Width
#| property and a flag for the interpretation of (A)mbiguous width codepoints.
sub duospace-width-core(str $text, int $wide-context) is export {
    # Various chunks of this cribbed from Rakudo setting internals
    use nqp;
    my constant $gc-prop  = nqp::unipropcode('General_Category');
    my constant $eaw-prop = nqp::unipropcode('East_Asian_Width');
    my constant $ignore   = nqp::hash(
        'Mn', 1, 'Mc', 1, 'Me', 1, 'Cc', 1, 'Cf', 1, 'Cs', 1, 'Co', 1, 'Cn', 1);
    my constant $narrow   = nqp::hash(
        'N', 1, 'Na', 1, 'H', 1, 'F', 2, 'W', 2, 'A', 1);
    my constant $wide     = nqp::hash(
        'N', 1, 'Na', 1, 'H', 1, 'F', 2, 'W', 2, 'A', 2);

    my $cells := $wide-context ?? $wide !! $narrow;
    my $codes := nqp::strtocodes(
        $text,
        nqp::const::NORMALIZE_NFC,
        nqp::create(array[uint32])
    );

    my int  $elems = nqp::elems($codes);
    my int  $i     = -1;
    my uint $width = 0;
    my uint $ord;

    nqp::while(
        nqp::islt_i(++$i, $elems),
        nqp::stmts(
            ($ord = nqp::atpos_u($codes, $i)),
            nqp::unless(
                nqp::atkey($ignore, nqp::getuniprop_str($ord, $gc-prop)),
                ($width = nqp::add_i($width,
                                     nqp::atkey($cells,
                                                nqp::getuniprop_str($ord, $eaw-prop)))),
            )
        )
    );

    $width
}


#| Determine whether a single line of text has any characters that are *NOT*
#| width 1.  The presence of either width 0 or width 2 characters, or control
#| characters such as tab and newline, will cause this routine to return False;
#| otherwise it returns True.  This version strips ANSI SGR color/attribute
#| escapes before doing the calculation.
sub is-monospace(Str:D $text, Bool :$wide-context = False) is export {
    is-monospace-core((my str $str = colorstrip($text)),
                      (my int $context = +$wide-context))
}

#| Optimized core for is-monospace, when colorstrip is known NOT needed.  If
#| you're not sure which to use, use the regular is-monospace routine.
#|
#| Like is-monospace, determines whether a single line of text has any
#| characters that are *NOT* width 1.  The presence of either width 0 or width
#| 2 characters, or control characters such as tab and newline, will cause this
#| routine to return False; otherwise it returns True.
sub is-monospace-core(str $text, int $wide-context) is export {
    use nqp;
    my constant $gc-prop  = nqp::unipropcode('General_Category');
    my constant $eaw-prop = nqp::unipropcode('East_Asian_Width');
    my constant $zero     = nqp::hash(
        'Mn', 1, 'Mc', 1, 'Me', 1, 'Cc', 1, 'Cf', 1, 'Cs', 1, 'Co', 1, 'Cn', 1);
    my constant $a-narrow = nqp::hash('F', 1, 'W', 1);
    my constant $a-wide   = nqp::hash('F', 1, 'W', 1, 'A', 1);

    my $is-wide := $wide-context ?? $a-wide !! $a-narrow;
    my $codes := nqp::strtocodes(
        $text,
        nqp::const::NORMALIZE_NFC,
        nqp::create(array[uint32])
    );

    my int  $elems = nqp::elems($codes);
    my int  $i     = -1;
    my uint $mono  = 1;
    my uint $ord;

    nqp::while(
        (nqp::iseq_i($mono, 1) && nqp::islt_i(++$i, $elems)),
        nqp::stmts(
            ($ord = nqp::atpos_u($codes, $i)),
            nqp::if(
                nqp::atkey($zero, nqp::getuniprop_str($ord, $gc-prop)),
                ($mono = 0),
                nqp::if(
                    nqp::atkey($is-wide, nqp::getuniprop_str($ord, $eaw-prop)),
                    ($mono = 0),
                )
            )
        )
    );

    ?$mono
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
