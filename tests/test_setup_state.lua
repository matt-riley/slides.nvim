local MiniTest = require("mini.test")
local T = MiniTest.new_set()

local slides = require("slides")
local state = require("slides.state")

local setup_set = MiniTest.new_set()

setup_set["applies defaults and overrides"] = function()
  slides.setup({ fullscreen = false, border = "single" })

  MiniTest.expect.equality(slides.config.fullscreen, false)
  MiniTest.expect.equality(slides.config.border, "single")
  MiniTest.expect.equality(slides.config.separator, "^%-%-%-+$")
  MiniTest.expect.equality(slides.config.fragment_separator, "^%s*%+%+%+*%s*$")
  MiniTest.expect.equality(slides.config.width, 0.8)
  MiniTest.expect.equality(slides.config.height, 0.8)
end

T["setup"] = setup_set

local state_set = MiniTest.new_set()

state_set["resets state fields"] = function()
  state.active = true
  state.slides = { { "slide" } }
  state.current = 2
  state.fragments = { { "a" } }
  state.fragment_index = 2
  state.output_lines = { "out" }
  state.buf = 12
  state.win = 34
  state.bg_buf = 56
  state.bg_win = 78
  state.source_buf = 90

  state.reset()

  MiniTest.expect.equality(state.active, false)
  MiniTest.expect.equality(state.slides, {})
  MiniTest.expect.equality(state.current, 1)
  MiniTest.expect.equality(state.fragments, {})
  MiniTest.expect.equality(state.fragment_index, 1)
  MiniTest.expect.equality(state.output_lines, nil)
  MiniTest.expect.equality(state.buf, nil)
  MiniTest.expect.equality(state.win, nil)
  MiniTest.expect.equality(state.bg_buf, nil)
  MiniTest.expect.equality(state.bg_win, nil)
  MiniTest.expect.equality(state.source_buf, nil)
end

T["state.reset"] = state_set

return T
