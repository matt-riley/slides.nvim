local slides = require("slides")
local state = require("slides.state")
local renderer = require("slides.renderer")

describe("slides.toggle", function()
  before_each(function()
    slides.setup({ fullscreen = false, border = "single" })
    state.reset()
    vim.o.columns = 80
    vim.o.lines = 24
    vim.o.cmdheight = 1
  end)

  after_each(function()
    if state.active then
      renderer.close()
      state.reset()
    end
  end)

  it("opens and closes the viewer", function()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
      "# Slide 1",
      "---",
      "# Slide 2",
    })
    vim.api.nvim_set_current_buf(buf)

    slides.toggle()

    assert.is_true(state.active)
    assert.equals(2, #state.slides)
    assert.equals(1, state.current)
    assert.is_true(state.win ~= nil and vim.api.nvim_win_is_valid(state.win))

    slides.toggle()

    assert.is_false(state.active)
    assert.is_nil(state.win)
    assert.is_nil(state.buf)
  end)
end)
