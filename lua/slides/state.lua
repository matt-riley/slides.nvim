-- lua/slides/state.lua
local M = {
  active = false,
  slides = {},
  current = 1,
  fragments = {},
  fragment_index = 1,
  output_lines = nil,
  buf = nil,
  win = nil,
  bg_buf = nil,
  bg_win = nil,
  source_buf = nil,
}

--- Reset state to initial values.
function M.reset()
  M.active = false
  M.slides = {}
  M.current = 1
  M.fragments = {}
  M.fragment_index = 1
  M.output_lines = nil
  M.buf = nil
  M.win = nil
  M.bg_buf = nil
  M.bg_win = nil
  M.source_buf = nil
end

return M
