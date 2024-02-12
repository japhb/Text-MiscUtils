# ABSTRACT: Utilities for Unicode presentation mangling

unit module Text::MiscUtils::Emojify;

use Text::MiscUtils::Layout;


#| Fix up presentation for (possibly width-changing) text/emoji variants
sub presentation-fixup($char, $mod, $expected-width = 0) {
    my $spacer = ' ' x (0 max $expected-width - duospace-width($char));
    $char ~ $mod ~ $spacer
}

#| Select emoji presentation for a character and pad to width 2 if needed
sub emojify($char)        is export { presentation-fixup($char, "\x[FE0F]", 2) }

#| Select text presentation for a character
sub textify($char)        is export { presentation-fixup($char, "\x[FE0E]") }

#| Set skin tone (2..6) for a face or person emoji, and pad to width 2 if needed
sub toneify($char, $tone) is export { presentation-fixup($char, chr(0x1f3f9 + $tone), 2) }
