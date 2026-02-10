# slides.nvim

A tiny Neovim plugin for presenting Markdown slides in a full-screen floating window.

## Features

- Write slides in a single Markdown file, separated by `---`
- Renders in a full-screen floating window (configurable)
- Slide counter
- Syntax highlighting
- Live reload on file save
- Execute code blocks with `<C-e>`
- Pre-process content with `~~~` blocks
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
| `<C-e>` | Execute code block |
| `q` | Quit viewer |
| `<Esc>` | Quit viewer |

## Configuration

```lua
require("slides").setup({
  -- fullscreen = true,
  -- border = "rounded",
  -- width = 0.8,
  -- height = 0.8,
})
```

## Dynamic Content

### Code Execution

Press `<C-e>` to execute the first code block on the current slide. Supported languages: `lua`, `bash`, `sh`, `python`, `go`/`golang`, `ts`/`typescript` (via bun). The output is appended to the slide.

### Pre-processing

Use `~~~command` blocks to generate content dynamically. For example:

    ~~~date
    ~~~

This will replace the block with the output of the `date` command before rendering.

Available options:

- `fullscreen`: use a full-screen floating window (default: true)
- `border`: floating window border style (used when fullscreen = false)
- `width`: floating window width (number, used when fullscreen = false)
- `height`: floating window height (number, used when fullscreen = false)

Slides are split on `---`.

## Requirements

- Neovim 0.8+
- (Optional) Treesitter Markdown parser for improved syntax highlighting

## Testing

Tests use [mini.test](https://github.com/echasnovski/mini.nvim). Ensure mini.nvim is installed
(or set `MINI_PATH` to a local checkout), then run:

```bash
MINI_PATH=/path/to/mini.nvim \
  nvim --headless -u tests/minimal_init.lua \
  -c "lua MiniTest.run({})" -c "qa"
```
