local slides = require("slides")
local state = require("slides.state")

describe("slides.setup", function()
  it("applies defaults and overrides", function()
    slides.setup({ fullscreen = false, border = "single" })

    assert.is_false(slides.config.fullscreen)
    assert.equals("single", slides.config.border)
    assert.equals("^%-%-%-+$", slides.config.separator)
    assert.equals(0.8, slides.config.width)
    assert.equals(0.8, slides.config.height)
  end)
end)

describe("slides.state.reset", function()
  it("resets state fields", function()
    state.active = true
    state.slides = { { "slide" } }
    state.current = 2
    state.buf = 12
    state.win = 34
    state.bg_buf = 56
    state.bg_win = 78
    state.source_buf = 90

    state.reset()

    assert.is_false(state.active)
    assert.are.same({}, state.slides)
    assert.equals(1, state.current)
    assert.is_nil(state.buf)
    assert.is_nil(state.win)
    assert.is_nil(state.bg_buf)
    assert.is_nil(state.bg_win)
    assert.is_nil(state.source_buf)
  end)
end)
