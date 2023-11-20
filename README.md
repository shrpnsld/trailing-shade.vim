# trailing-shade.vim

Highlight trailing whitespace with a shade of the current background color, so it always looks natural, regardless of a color scheme you're using. With a dark background (`:h background`), the highlighting has a lighter shade, and with a light background, the highlighting has a darker shade.

The offsets of `ctermbg` and `guibg` colors in the `Normal` highlight group are used as a shade of the background color.

By default, highlighting works only with listed buffers (`:h buflisted`), so trailing whitespace won't be visible in help files or some plugin buffers.

### How it looks

<image src="screenshots/catppuccin-mocha.png" with="400" height="200"> <image src="screenshots/rose-pine-dawn.png" with="400" height="200">
<image src="screenshots/kanawaga-wave.png" with="400" height="200"> <image src="screenshots/kanawaga-lotus.png" with="400" height="200">
<image src="screenshots/nord.png" with="400" height="200"> <image src="screenshots/tokyonight-day.png" with="400" height="200">

## Installation

Use string `'shrpnsld/trailing-shade.vim'` with your plugin manager and you're good to go.

## Confuguration

### Set color offsets

Shade offset for TUI colors (`:h tui-colors`). The range for this option is typically within `0..255`.

```vim
let g:trailing_shade_cterm = 8
```

Shade offset for GUI colors (`:h gui-colors`). The format for this option is `0xRRGGBB`.

```vim
let g:trailing_shade_gui = 0x363636
```

### Other options

While in *Insert* mode, highlight trailing whitespace occurring only aflter the cursor.

```vim
let g:trailing_shade_after_cursor = 1
```

## Commands

`:TrailingShadeOn` – turn on for all buffers.

`:TrailingShadeOff` – turn off for all buffers.

`:TrailingShadeOnHere` – turn on for current buffer.

`:TrailingShadeOffHere` – turn off for current buffer.

