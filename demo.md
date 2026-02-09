# slides.nvim

A tiny Markdown slide deck in Neovim.

---

## Features

- Write slides in plain Markdown
- Navigate slide-by-slide inside Neovim
- Clean, readable presentation layout
- Lua-first plugin configuration
- Code fences with syntax highlighting

---

## Syntax highlighting test

```lua
local M = {}

function M.greet(name)
  name = name or "world"
  print("Hello, " .. name .. "!")
end

return M
```

---

## Mixed content

Here is a short paragraph with **bold text** and *italic text* to demonstrate inline formatting.

You can combine Markdown elements to create slides that read well and present clearly.

---

## Thanks

That’s the end of the demo deck.
