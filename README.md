# slides.nvim

A tiny Neovim plugin for presenting Markdown slides in a centered floating window.

## Features

- Write slides in a single Markdown file, separated by `---`
- Renders in a centered floating window
- Slide counter
- Syntax highlighting
- Toggle the viewer with `:Slides`

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
  -- border = "rounded",
  -- width = 0.8,
  -- height = 0.8,
})
```

Available options:

- `border`: floating window border style
- `width`: floating window width (number)
- `height`: floating window height (number)

Slides are split on `---`.

## Requirements

- Neovim 0.8+
- (Optional) Treesitter Markdown parser for improved syntax highlighting
