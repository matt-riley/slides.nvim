local T = MiniTest.new_set()

local parser = require("slides.parser")

T["preprocess_blocks"] = function()
  local lines = {
    "Start",
    "~~~tr a b",
    "aaa",
    "~~~",
    "End"
  }

  local slides = parser.parse(lines)
  -- The parser splits into slides. We expect 1 slide here.
  
  MiniTest.expect.equality(#slides, 1)
  local slide_lines = slides[1]
  
  -- trim_blank_lines might affect indices, but output should be:
  -- Start
  -- bbb
  -- End
  
  MiniTest.expect.equality(slide_lines[1], "Start")
  MiniTest.expect.equality(slide_lines[2], "bbb")
  MiniTest.expect.equality(slide_lines[3], "End")
end

return T