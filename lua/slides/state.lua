-- lua/slides/state.lua
local M = { active=false, slides={}, current=1, buf=nil, win=nil, source_buf=nil }

--- Reset state to initial values.
function M.reset()
  M.active = false
  M.slides = {}
  M.current = 1
  M.buf = nil
  M.win = nil
  M.source_buf = nil
end

return M
