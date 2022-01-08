use Test;
use Text::MiscUtils::English;


plan 55;


# _s() with 1, 2, or 3 args (default, custom, or irregular plurals respectively)
is _s(-5), 's', 'default plural of negatives: plural';
is _s(-1), '',  'default plural of negatives: singular';
is _s( 0), 's', 'default plural of zero';
is _s( 1), '',  'default plural of positives: singular';
is _s(16), 's', 'default plural of positives: plural';

is _s(-8, 'es'), 'es', 'custom plural of negatives: plural';
is _s(-1, 'es'), '',   'custom plural of negatives: singular';
is _s( 0, 'es'), 'es', 'custom plural of zero';
is _s( 1, 'es'), '',   'custom plural of positives: singular';
is _s(12, 'es'), 'es', 'custom plural of positives: plural';

is _s(-4, 'geese', 'goose'), 'geese', 'irregular plural of negatives: plural';
is _s(-1, 'geese', 'goose'), 'goose', 'irregular plural of negatives: singular';
is _s( 0, 'geese', 'goose'), 'geese', 'irregular plural of zero';
is _s( 1, 'geese', 'goose'), 'goose', 'irregular plural of positives: singular';
is _s(42, 'geese', 'goose'), 'geese', 'irregular plural of positives: plural';


# ordinal()
is ordinal(0), '0th', 'ordinal of 0';
is ordinal(1), '1st', 'ordinal of 1';
is ordinal(2), '2nd', 'ordinal of 2';
is ordinal(3), '3rd', 'ordinal of 3';
is ordinal(4), '4th', 'ordinal of 4';
is ordinal(5), '5th', 'ordinal of 5';
is ordinal(6), '6th', 'ordinal of 6';
is ordinal(7), '7th', 'ordinal of 7';
is ordinal(8), '8th', 'ordinal of 8';
is ordinal(9), '9th', 'ordinal of 9';

is ordinal(10), '10th', 'ordinal of 10';
is ordinal(11), '11th', 'ordinal of 11';
is ordinal(12), '12th', 'ordinal of 12';
is ordinal(13), '13th', 'ordinal of 13';
is ordinal(14), '14th', 'ordinal of 14';
is ordinal(15), '15th', 'ordinal of 15';
is ordinal(16), '16th', 'ordinal of 16';
is ordinal(17), '17th', 'ordinal of 17';
is ordinal(18), '18th', 'ordinal of 18';
is ordinal(19), '19th', 'ordinal of 19';

is ordinal(20), '20th', 'ordinal of 20';
is ordinal(21), '21st', 'ordinal of 21';
is ordinal(22), '22nd', 'ordinal of 22';
is ordinal(23), '23rd', 'ordinal of 23';
is ordinal(24), '24th', 'ordinal of 24';
is ordinal(25), '25th', 'ordinal of 25';
is ordinal(26), '26th', 'ordinal of 26';
is ordinal(27), '27th', 'ordinal of 27';
is ordinal(28), '28th', 'ordinal of 28';
is ordinal(29), '29th', 'ordinal of 29';

is ordinal(130), '130th', 'ordinal of 130';
is ordinal(131), '131st', 'ordinal of 131';
is ordinal(132), '132nd', 'ordinal of 132';
is ordinal(133), '133rd', 'ordinal of 133';
is ordinal(134), '134th', 'ordinal of 134';
is ordinal(135), '135th', 'ordinal of 135';
is ordinal(136), '136th', 'ordinal of 136';
is ordinal(137), '137th', 'ordinal of 137';
is ordinal(138), '138th', 'ordinal of 138';
is ordinal(139), '139th', 'ordinal of 139';


done-testing;
