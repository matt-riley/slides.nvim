-- lua/slides/renderer.lua
local M = {}

local state = require("slides.state")

--- Open the floating presentation window.
function M.open()
  local buf = vim.api.nvim_create_buf(false, true)

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "markdown"

  local editor_width = vim.o.columns
  local editor_height = vim.o.lines - vim.o.cmdheight

  local slides_mod = package.loaded["slides"]
  local cfg = (slides_mod and slides_mod.config) or {}

  local win_width = math.floor(editor_width * (cfg.width or 0.8))
  local win_height = math.floor(editor_height * (cfg.height or 0.8))

  local col = math.floor((editor_width - win_width) / 2)
  local row = math.floor((editor_height - win_height) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = win_width,
    height = win_height,
    col = col,
    row = row,
    style = "minimal",
    border = cfg.border or "rounded",
  })

  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true

  state.buf = buf
  state.win = win
end

--- Render a slide in the floating window.
--- @param slide_lines string[] Lines of the current slide
--- @param current number Current slide number
--- @param total number Total number of slides
function M.render(slide_lines, current, total)
  local buf = state.buf
  local win = state.win

  if not buf or not vim.api.nvim_buf_is_valid(buf) then return end
  if not win or not vim.api.nvim_win_is_valid(win) then return end

  local win_width = vim.api.nvim_win_get_width(win)
  local win_height = vim.api.nvim_win_get_height(win)

  -- Slide counter footer
  local counter = string.format("[%d/%d]", current, total)
  local counter_line = counter

  -- Vertical centering: total content = slide lines + 2 (blank + counter)
  local content_height = #slide_lines + 2
  local v_pad = math.max(0, math.floor((win_height - content_height) / 2))

  -- Build final buffer content
  local output = {}
  for _ = 1, v_pad do
    table.insert(output, "")
  end
  for _, line in ipairs(slide_lines) do
    table.insert(output, line)
  end
  table.insert(output, "")
  table.insert(output, counter_line)

  -- Write to buffer
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
  vim.bo[buf].modifiable = false
end

--- Close the floating presentation window.
function M.close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    vim.api.nvim_buf_delete(state.buf, { force = true })
  end
  state.win = nil
  state.buf = nil
end

return M
