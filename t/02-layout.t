use Test;
use Text::MiscUtils::Layout;


plan 42;


# text-wrap() -- 8 tests
is text-wrap(-17, ''), '', 'text-wrap with empty string and negative width';
is text-wrap(  0, ''), '', 'text-wrap with empty string and zero width';
is text-wrap(  4, ''), '', 'text-wrap with empty string and positive width';

is text-wrap( -8, '   '), '', 'text-wrap with whitespace only and negative width';
is text-wrap(  0, '   '), '', 'text-wrap with whitespace only and zero width';
is text-wrap(  2, '   '), '', 'text-wrap with whitespace only and less width';
is text-wrap(  3, '   '), '', 'text-wrap with whitespace only and equal width';
is text-wrap(  8, '   '), '', 'text-wrap with whitespace only and greater width';

# XXXX: Whitespace surrounded by ANSI codes
# XXXX: Only ANSI codes
# XXXX: ANSI codes next to text
# XXXX: ANSI codes surrounded by text
# XXXX: ANSI codes embedded in text

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
