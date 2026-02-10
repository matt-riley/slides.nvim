local parser = require("slides.parser")
local slides = require("slides")

describe("slides.parser", function()
  before_each(function()
    slides.setup()
  end)

  it("splits slides and trims blank lines", function()
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

    assert.are.same({
      { "# Slide 1" },
      { "## Slide 2" },
    }, result)
  end)

  it("returns at least one slide for empty input", function()
    local result = parser.parse({ "---" })

    assert.are.same({ {} }, result)
  end)

  it("respects custom separators", function()
    slides.setup({ separator = "^===+$" })

    local result = parser.parse({ "A", "===", "B" })

    assert.are.same({
      { "A" },
      { "B" },
    }, result)
  end)
end)
