local MiniTest = require("mini.test")
local T = MiniTest.new_set()

local renderer = require("slides.renderer")

T["build_fullscreen_lines places output footer"] = function()
  local lines = renderer.build_fullscreen_lines({ "Title" }, { "out" }, 8, 20)

  MiniTest.expect.equality(#lines, 8)
  MiniTest.expect.equality(lines[#lines], "--------------")
  MiniTest.expect.equality(lines[#lines - 1], "out")
  MiniTest.expect.equality(lines[#lines - 2], "--- Output ---")
end

T["build_fullscreen_lines trims output to fit"] = function()
  local lines = renderer.build_fullscreen_lines({ "Title" }, { "1", "2", "3", "4" }, 6, 20)

  MiniTest.expect.equality(#lines, 6)
  MiniTest.expect.equality(lines[#lines], "--------------")
  MiniTest.expect.equality(lines[#lines - 1], "4")
  MiniTest.expect.equality(lines[#lines - 2], "3")
  MiniTest.expect.equality(lines[#lines - 3], "--- Output ---")
end

T["build_fullscreen_lines centers content"] = function()
  local lines = renderer.build_fullscreen_lines({ "Hi" }, nil, 5, 10)

  MiniTest.expect.equality(lines[3], "    Hi")
end

return T
