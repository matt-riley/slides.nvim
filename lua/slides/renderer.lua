-- lua/slides/renderer.lua
local state = require('slides.state')

local M = {}

local function get_ui()
  return (vim.api.nvim_list_uis() or {})[1] or { width = vim.o.columns, height = vim.o.lines }
end

local function indent(pad, s)
  if pad <= 0 then
    return s
  end
  return string.rep(' ', pad) .. s
end

local function center_pad(win_width, s)
  local w = vim.fn.strdisplaywidth(s)
  if w >= win_width then
    return s
  end
  return indent(math.floor((win_width - w) / 2), s)
end

--- Open the floating presentation window.
function M.open()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    vim.api.nvim_buf_delete(state.buf, { force = true })
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = 'markdown'

  local ui = get_ui()
  local width = math.floor(ui.width * 0.8)
  local height = math.floor(ui.height * 0.8)
  local row = math.floor((ui.height - height) / 2)
  local col = math.floor((ui.width - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
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
  if not state.buf or not state.win then
    return
  end
  if not vim.api.nvim_buf_is_valid(state.buf) or not vim.api.nvim_win_is_valid(state.win) then
    return
  end

  local win_width = vim.api.nvim_win_get_width(state.win)
  local win_height = vim.api.nvim_win_get_height(state.win)

  local max_line_width = 0
  for _, line in ipairs(slide_lines or {}) do
    max_line_width = math.max(max_line_width, vim.fn.strdisplaywidth(line))
  end

  local content_pad = math.max(0, math.floor((win_width - max_line_width) / 2))
  local counter = string.format('[%d/%d]', current, total)

  local out = {}

  local content_height = (#(slide_lines or {}) + 2)
  local top_pad = math.max(0, math.floor((win_height - content_height) / 2))
  for _ = 1, top_pad do
    table.insert(out, '')
  end

  for _, line in ipairs(slide_lines or {}) do
    table.insert(out, indent(content_pad, line))
  end

  table.insert(out, '')
  table.insert(out, center_pad(win_width, counter))

  vim.bo[state.buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, out)
  vim.bo[state.buf].modifiable = false
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
