# slides.nvim

A tiny Neovim plugin for presenting Markdown slides in a full-screen floating window.

## Features

- Write slides in a single Markdown file, separated by `---`
- Renders in a full-screen floating window (configurable)
- Slide counter
- Syntax highlighting
- Live reload on file save
- Execute code blocks asynchronously with `<C-e>`
- Fragments/reveals with `++` separators
- Pre-process content with `~~~` blocks
- Toggle the viewer with `:Slides`

## Installation

```lua
-- lazy.nvim
{ "matt-riley/slides.nvim", opts = {} }

-- packer.nvim
use { "matt-riley/slides.nvim", config = function() require("slides").setup() end }
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
  -- execution_timeout = 30000,
})
```

## Dynamic Content

### Code Execution

Press `<C-e>` to execute the first code block on the current slide. Execution runs asynchronously through `vim.system`, so the editor remains responsive while the command is running. Moving to another slide, refreshing the source, closing the viewer, or starting another command cancels the active process and ignores stale output.

Supported languages:

- `lua` — executed by an isolated headless Neovim process
- `bash` and `sh` — source is passed through standard input
- `python` and `python3` — source is passed to `python3 -`
- `go` and `golang` — executed from a temporary `.go` file
- `ts` and `typescript` — executed from a temporary `.ts` file via Bun

Standard output and standard error are rendered in the slide footer. Commands time out after 30 seconds by default; configure `execution_timeout` in milliseconds to change that limit.

### Fragments/Reveals

Use a line containing only `++` (whitespace is ok) to reveal content in steps within a slide. The next/previous slide keys advance through fragments before changing slides.

```markdown
- Item 1
+
- Item 2
+
- Item 3
```

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
- `fragment_separator`: pattern for fragment separators (default: `^%s*%+%+%+*%s*$`)
- `execution_timeout`: maximum code execution time in milliseconds (default: `30000`)

Slides are split on `---`.

## Requirements

- Neovim 0.10+ (`vim.system`)
- (Optional) Treesitter Markdown parser for improved syntax highlighting
- The relevant runtime for executed code (`bash`, `python3`, `go`, or `bun`)

## Versioning

- Canonical project version is stored in [`VERSION`](VERSION).
- `release-please` updates both `VERSION` and `CHANGELOG.md`.

## Testing

Tests use [mini.test](https://github.com/nvim-mini/mini.nvim). Ensure mini.nvim is installed
(or set `MINI_PATH` to a local checkout), then run:

```bash
MINI_PATH=/path/to/mini.nvim \
  nvim --headless -u tests/minimal_init.lua \
  -c "lua MiniTest.run({})" -c "qa"
```

## Documentation (`:help`)

Help docs are generated from Lua annotations in `lua/slides/init.lua` via
[mini.doc](https://github.com/nvim-mini/mini.doc):

```bash
make docs
```

`make docs` injects the current value from [`VERSION`](VERSION) into the
generated vim help file.
