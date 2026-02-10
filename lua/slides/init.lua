-- lua/slides/init.lua
local M = {}

local parser = require("slides.parser")
local renderer = require("slides.renderer")
local state = require("slides.state")

--- Configure the plugin with user options.
--- @param opts? table User configuration options
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", {
    separator = "^%-%-%-+$",
    border = "rounded",
    fullscreen = true,
    width = 0.8,
    height = 0.8,
  }, opts or {})
end

--- Toggle presentation mode on/off.
function M.toggle()
  if state.active then
    renderer.close()
    state.reset()
    return
  end

  local source_buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(source_buf, 0, -1, false)
  local slides = parser.parse(lines)

  state.source_buf = source_buf
  state.slides = slides
  state.current = 1
  state.active = true

  renderer.open()
  renderer.render(state.slides[state.current], state.current, #state.slides)

  -- Buffer-local keymaps for navigation
  local buf = state.buf
  local opts = { noremap = true, silent = true, buffer = buf }
  vim.keymap.set("n", "l", function() M.next_slide() end, opts)
  vim.keymap.set("n", "h", function() M.prev_slide() end, opts)
  vim.keymap.set("n", "q", function() M.toggle() end, opts)
  vim.keymap.set("n", "<Escape>", function() M.toggle() end, opts)
end

--- Advance to the next slide.
function M.next_slide()
  if not state.active then return end
  if state.current < #state.slides then
    state.current = state.current + 1
    renderer.render(state.slides[state.current], state.current, #state.slides)
  end
end

--- Go back to the previous slide.
function M.prev_slide()
  if not state.active then return end
  if state.current > 1 then
    state.current = state.current - 1
    renderer.render(state.slides[state.current], state.current, #state.slides)
  end
end

return M
