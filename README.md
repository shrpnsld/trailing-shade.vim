# trailing-shade.vim

Highlight trailing whitespace with a shade of the current background color, so it always looks natural, regardless of a color scheme in use. With a dark background (`:h background`), the highlighting has a lighter shade, and with a light background, the highlighting has a darker shade.

The offsets of `ctermbg` and `guibg` colors in the `Normal` highlight group are used as a shade of the background color.

By default, highlighting works only with listed buffers (`:h buflisted`), so trailing whitespace won't be visible in help files or some plugin buffers.

## Confuguration

`g:trailing_shade_cterm` – offset for terminal colors. The range for this value is defined by *tui-colors* (`:h tui-colors`), typically within `0..255`.

`g:trailing_shade_gui` – offset for GUI colors. The format for this value is defined by *gui-colors* (`:h gui-colors`), typically it's `#RRGGBB`.

`g:trailing_shade_after_cursor` – while in *Insert* mode, highlight trailing whitespace occurring only after the cursor.

## Commands

`:TrailingShadeOn` – turn on trailing-shade for all buffers.

`:TrailingShadeOff` – turn off trailing-shade for all buffers.

`:TrailingShadeOnHere` – turn on trailing-shade for current buffer.

`:TrailingShadeOffHere` – turn off trailing-shade for current buffer.

