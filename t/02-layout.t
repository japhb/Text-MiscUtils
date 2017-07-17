use Test;
use Text::MiscUtils::Layout;


plan 64;


# text-wrap() -- 30 tests
is text-wrap(-7, ''), '', 'text-wrap with empty string and negative width';
is text-wrap( 0, ''), '', 'text-wrap with empty string and zero width';
is text-wrap( 4, ''), '', 'text-wrap with empty string and positive width';

is text-wrap(-8, '   '), '', 'text-wrap with whitespace only and negative width';
is text-wrap( 0, '   '), '', 'text-wrap with whitespace only and zero width';
is text-wrap( 2, '   '), '', 'text-wrap with whitespace only and less width';
is text-wrap( 3, '   '), '', 'text-wrap with whitespace only and equal width';
is text-wrap( 8, '   '), '', 'text-wrap with whitespace only and greater width';

is text-wrap(-9, "\e[1m"), "\e[1m", 'text-wrap with one ANSI color command and negative width';
is text-wrap( 0, "\e[1m"), "\e[1m", 'text-wrap with one ANSI color command and zero width';
is text-wrap( 2, "\e[1m"), "\e[1m", 'text-wrap with one ANSI color command and small width';
is text-wrap(12, "\e[1m"), "\e[1m", 'text-wrap with one ANSI color command and large width';

is text-wrap(-4, "\e[1m   "), "\e[1m", 'text-wrap with one ANSI command, trailing whitespace, and negative width';
is text-wrap( 0, "\e[1m   "), "\e[1m", 'text-wrap with one ANSI command, trailing whitespace, and zero width';
is text-wrap( 3, "\e[1m   "), "\e[1m", 'text-wrap with one ANSI command, trailing whitespace, and small width';
is text-wrap(15, "\e[1m   "), "\e[1m", 'text-wrap with one ANSI command, trailing whitespace, and large width';

is text-wrap(-6, "  \e[1m "), "  \e[1m", 'text-wrap with one ANSI command, surrounding whitespace, and negative width';
is text-wrap( 0, "  \e[1m "), "  \e[1m", 'text-wrap with one ANSI command, surrounding whitespace, and zero width';
is text-wrap( 4, "  \e[1m "), "  \e[1m", 'text-wrap with one ANSI command, surrounding whitespace, and small width';
is text-wrap(20, "  \e[1m "), "  \e[1m", 'text-wrap with one ANSI command, surrounding whitespace, and large width';

is text-wrap(-5, "  \e[1m   \e[0m   "), ("  \e[1m", "  \e[0m"), 'text-wrap with two ANSI commands, surrounding whitespace, and negative width';
is text-wrap( 0, "  \e[1m   \e[0m   "), ("  \e[1m", "  \e[0m"), 'text-wrap with two ANSI commands, surrounding whitespace, and zero width';
is text-wrap( 5, "  \e[1m   \e[0m   "), "  \e[1m \e[0m", 'text-wrap with two ANSI commands, surrounding whitespace, and small width';
is text-wrap(19, "  \e[1m   \e[0m   "), "  \e[1m \e[0m", 'text-wrap with two ANSI commands, surrounding whitespace, and large width';

is text-wrap(-3, "  \e[1mab   123\e[0m    \e[1m!#^*\e[0m     c\e[1mde\e[0mf   "),
    ("  \e[1mab", "  123\e[0m", "  \e[1m!#^*\e[0m", "  c\e[1mde\e[0mf"),
    'text-wrap with intermingled ANSI commands, whitespace, and text, and negative width';

is text-wrap(0, "  \e[1mab   123\e[0m    \e[1m!#^*\e[0m     c\e[1mde\e[0mf   "),
    ("  \e[1mab", "  123\e[0m", "  \e[1m!#^*\e[0m", "  c\e[1mde\e[0mf"),
    'text-wrap with intermingled ANSI commands, whitespace, and text, and zero width';

is text-wrap(7, "  \e[1mab   123\e[0m    \e[1m!#^*\e[0m     c\e[1mde\e[0mf   "),
    ("  \e[1mab", "  123\e[0m", "  \e[1m!#^*\e[0m", "  c\e[1mde\e[0mf"),
    'text-wrap with intermingled ANSI commands, whitespace, and text, and small width';

is text-wrap(8, "  \e[1mab   123\e[0m    \e[1m!#^*\e[0m     c\e[1mde\e[0mf   "),
    ("  \e[1mab 123\e[0m", "  \e[1m!#^*\e[0m", "  c\e[1mde\e[0mf"),
    'text-wrap with intermingled ANSI commands, whitespace, and text, and medium width';

is text-wrap(12, "  \e[1mab   123\e[0m    \e[1m!#^*\e[0m     c\e[1mde\e[0mf   "),
    ("  \e[1mab 123\e[0m", "  \e[1m!#^*\e[0m c\e[1mde\e[0mf"),
    'text-wrap with intermingled ANSI commands, whitespace, and text, and large width';

is text-wrap(13, "  \e[1mab   123\e[0m    \e[1m!#^*\e[0m     c\e[1mde\e[0mf   "),
    ("  \e[1mab 123\e[0m \e[1m!#^*\e[0m", "  c\e[1mde\e[0mf"),
    'text-wrap with intermingled ANSI commands, whitespace, and text, and larger width';

# XXXX: Whitespace contains \t \r \n
# XXXX: Words smaller than width
# XXXX: Words bigger than width
# XXXX: Words of mixed lengths
# XXXX: Multiple lines of text get reformatted to one/fewer/same/more lines


# text-columns() -- 0 tests

# XXXX: No blocks, one block, two blocks, several blocks
# XXXX: Changing separator
# XXXX: Empty blocks: one, two, more, mixed in
# XXXX: Blocks of same lengths, different lengths, different order lengths
# XXXX: Blocks with short lines, exactly width lines, long lines split in two or more


# evenly-spaced() -- 34 tests
is evenly-spaced(-15), '', 'evenly-spaced with no cells and negative width';
is evenly-spaced(  0), '', 'evenly-spaced with no cells and zero width';
is evenly-spaced(  5), '', 'evenly-spaced with no cells and positive width';

is evenly-spaced(-37, ''), '', 'evenly-spaced with one empty cell and negative width';
is evenly-spaced(  0, ''), '', 'evenly-spaced with one empty cell and zero width';
is evenly-spaced( 12, ''), '', 'evenly-spaced with one empty cell and positive width';

is evenly-spaced(-16, '', '', ''), '', 'evenly-spaced with several empty cells and negative width';
is evenly-spaced(  0, '', '', ''), '', 'evenly-spaced with several empty cells and zero width';
is evenly-spaced(  4, '', '', ''), '', 'evenly-spaced with several empty cells and positive width';

is evenly-spaced( -3, 'a', '', ''), 'a', 'evenly-spaced with one non-empty cell and negative width';
is evenly-spaced(  0, '', 'b', ''), 'b', 'evenly-spaced with one non-empty cell and zero width';
is evenly-spaced(  6, '', '', 'c'), 'c', 'evenly-spaced with one non-empty cell and positive width';

is evenly-spaced( -7, 'a', 'b', ''), 'a b', 'evenly-spaced with two non-empty cells and negative width';
is evenly-spaced(  0, 'a', '', 'b'), 'a b', 'evenly-spaced with two non-empty cells and zero width';
is evenly-spaced(  2, '', 'a', 'b'), 'a b', 'evenly-spaced with two non-empty cells and insufficient width';
is evenly-spaced(  3, 'a', '', 'b'), 'a b', 'evenly-spaced with two non-empty cells and just enough width';
is evenly-spaced(  4, 'a', 'b', ''), 'a  b', 'evenly-spaced with two non-empty cells and a little extra width';
is evenly-spaced(  5, '', 'a', 'b'), 'a   b', 'evenly-spaced with two non-empty cells and more extra width';
is evenly-spaced(  8, 'a', '', 'b'), 'a      b', 'evenly-spaced with two non-empty cells and lots of extra width';

is evenly-spaced( -7, 'a', 'b', 'c'), 'a b c', 'evenly-spaced with three non-empty cells and negative width';
is evenly-spaced(  0, 'a', 'b', 'c'), 'a b c', 'evenly-spaced with three non-empty cells and zero width';
is evenly-spaced(  2, 'a', 'b', 'c'), 'a b c', 'evenly-spaced with three non-empty cells and insufficient width';
is evenly-spaced(  5, 'a', 'b', 'c'), 'a b c', 'evenly-spaced with three non-empty cells and just enough width';
is evenly-spaced(  6, 'a', 'b', 'c'), 'a  b c', 'evenly-spaced with three non-empty cells and a little extra width';
is evenly-spaced(  7, 'a', 'b', 'c'), 'a  b  c', 'evenly-spaced with three non-empty cells and more extra width';
is evenly-spaced(  8, 'a', 'b', 'c'), 'a   b  c', 'evenly-spaced with three non-empty cells and even more extra width';
is evenly-spaced( 11, 'a', 'b', 'c'), 'a    b    c', 'evenly-spaced with three non-empty cells and lots of extra width';

is evenly-spaced( 12, '1', '22', '55555'), '1  22  55555', 'evenly-spaced with three different length cells 1-2-5';
is evenly-spaced( 12, '1', '55555', '22'), '1  55555  22', 'evenly-spaced with three different length cells 1-5-2';
is evenly-spaced( 12, '22', '1', '55555'), '22  1  55555', 'evenly-spaced with three different length cells 2-1-5';
is evenly-spaced( 12, '22', '55555', '1'), '22  55555  1', 'evenly-spaced with three different length cells 2-5-1';
is evenly-spaced( 12, '55555', '1', '22'), '55555  1  22', 'evenly-spaced with three different length cells 5-1-2';
is evenly-spaced( 12, '55555', '22', '1'), '55555  22  1', 'evenly-spaced with three different length cells 5-2-1';

is evenly-spaced( 11, "\e[1mabc\e[0m", '', '1234'), "\e[1mabc\e[0m    1234", 'evenly-spaced with an ANSI-colored cell and a plain cell';


done-testing;
