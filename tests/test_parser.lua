local MiniTest = require("mini.test")
local T = MiniTest.new_set()

local parser = require("slides.parser")
local slides = require("slides")

local parse_set = MiniTest.new_set({
  hooks = {
    pre_case = function()
      slides.setup()
    end,
  },
})

parse_set["splits slides and trims blank lines"] = function()
  local input = {
    "",
    "# Slide 1",
    "",
    "---",
    "",
    "## Slide 2",
    "",
  }

  local result = parser.parse(input)

  MiniTest.expect.equality(result, {
    { "# Slide 1" },
    { "## Slide 2" },
  })
end

parse_set["returns at least one slide for empty input"] = function()
  local result = parser.parse({ "---" })

  MiniTest.expect.equality(result, { {} })
end

parse_set["respects custom separators"] = function()
  slides.setup({ separator = "^===+$" })

  local result = parser.parse({ "A", "===", "B" })

  MiniTest.expect.equality(result, {
    { "A" },
    { "B" },
  })
end

T["parse"] = parse_set

return T
