-- lua/slides/state.lua
---@class slides.State
---@field active boolean Whether presentation mode is active.
---@field slides string[][] Parsed slides.
---@field current integer Current slide index (1-based).
---@field fragments string[][] Current slide fragments.
---@field fragment_index integer Current fragment index (1-based).
---@field output_lines string[]? Output lines from code execution.
---@field buf integer? Presentation buffer handle.
---@field win integer? Presentation window handle.
---@field bg_buf integer? Fullscreen background buffer handle.
---@field bg_win integer? Fullscreen background window handle.
---@field source_buf integer? Source markdown buffer handle.
---@type slides.State
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
