# slides.nvim

A tiny Neovim plugin for presenting Markdown slides in a full-screen floating window.

## Features

- Write slides in a single Markdown file, separated by `---`
- Renders in a full-screen floating window (configurable)
- Slide counter
- Syntax highlighting
- Toggle the viewer with `:Slides`
- Optional inline image rendering via image.nvim (Kitty/Ghostty compatible)

## Installation

```lua
-- lazy.nvim
{ "mattriley/slides.nvim", opts = {} }

-- packer.nvim
use { "mattriley/slides.nvim", config = function() require("slides").setup() end }
```

## Usage

1. Create a Markdown file and separate slides with `---`:

   ```markdown
   # Slide 1
   
   ---
   
   # Slide 2
   ```

2. Open the file in Neovim and run:

   ```vim
   :Slides
   ```

## Images

Image rendering is optional and uses [image.nvim](https://github.com/3rd/image.nvim).
Place images on their own line using standard Markdown syntax:

```markdown
![Alt text](path/to/image.png)
![Remote](https://example.com/image.png)
```

Enable image support in your setup:

```lua
require("slides").setup({
  images = {
    enabled = true,
  },
})
```

Install image.nvim alongside slides.nvim (lazy.nvim example):

```lua
{
  "mattriley/slides.nvim",
  opts = { images = { enabled = true } },
  dependencies = {
    { "3rd/image.nvim", opts = {} },
  },
}
```

Remote URLs require `curl`. See image.nvim for ImageMagick and terminal requirements.

## Keybindings

| Key | Action |
| --- | ------ |
| `l` | Next slide |
| `h` | Previous slide |
| `q` | Quit viewer |
| `<Esc>` | Quit viewer |

## Configuration

```lua
require("slides").setup({
  -- fullscreen = true,
  -- border = "rounded",
  -- width = 0.8,
  -- height = 0.8,
  -- images = {
  --   enabled = false,
  --   download_remote = true,
  --   max_width_window_percentage = 100,
  --   max_height_window_percentage = 50,
  -- },
})
```

Available options:

- `fullscreen`: use a full-screen floating window (default: true)
- `border`: floating window border style (used when fullscreen = false)
- `width`: floating window width (number, used when fullscreen = false)
- `height`: floating window height (number, used when fullscreen = false)
- `images.enabled`: enable image rendering via image.nvim (default: false)
- `images.download_remote`: allow remote image URLs (default: true, requires `curl`)
- `images.max_width_window_percentage`: max width as percent of window (default: 100)
- `images.max_height_window_percentage`: max height as percent of window (default: 50)

Slides are split on `---`.

## Requirements

- Neovim 0.8+
- (Optional) Treesitter Markdown parser for improved syntax highlighting
- (Optional) image.nvim + ImageMagick for image rendering in Kitty/Ghostty-compatible terminals

## Testing

Tests use [mini.test](https://github.com/echasnovski/mini.nvim). Ensure mini.nvim is installed
(or set `MINI_PATH` to a local checkout), then run:

```bash
MINI_PATH=/path/to/mini.nvim \
  nvim --headless -u tests/minimal_init.lua \
  -c "lua MiniTest.run({})" -c "qa"
```
