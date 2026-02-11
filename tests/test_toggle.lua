local MiniTest = require("mini.test")
local T = MiniTest.new_set()

local slides = require("slides")
local state = require("slides.state")
local renderer = require("slides.renderer")

local saved_options = {}

local toggle_set = MiniTest.new_set({
  hooks = {
    pre_case = function()
      saved_options.columns = vim.o.columns
      saved_options.lines = vim.o.lines
      saved_options.cmdheight = vim.o.cmdheight

      slides.setup({ fullscreen = false, border = "single" })
      state.reset()

      vim.o.columns = 80
      vim.o.lines = 24
      vim.o.cmdheight = 1
    end,
    post_case = function()
      if state.active then
        renderer.close()
        state.reset()
      end

      if saved_options.columns then
        vim.o.columns = saved_options.columns
      end
      if saved_options.lines then
        vim.o.lines = saved_options.lines
      end
      if saved_options.cmdheight then
        vim.o.cmdheight = saved_options.cmdheight
      end
    end,
  },
})

toggle_set["opens and closes the viewer"] = function()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    "# Slide 1",
    "---",
    "# Slide 2",
  })
  vim.api.nvim_set_current_buf(buf)

  slides.toggle()

  MiniTest.expect.equality(state.active, true)
  MiniTest.expect.equality(#state.slides, 2)
  MiniTest.expect.equality(state.current, 1)
  MiniTest.expect.equality(state.win ~= nil, true)
  MiniTest.expect.equality(vim.api.nvim_win_is_valid(state.win), true)
  MiniTest.expect.equality(vim.wo[state.win].signcolumn, "no")
  MiniTest.expect.equality(vim.wo[state.win].number, false)
  MiniTest.expect.equality(vim.wo[state.win].relativenumber, false)

  slides.toggle()

  MiniTest.expect.equality(state.active, false)
  MiniTest.expect.equality(state.win, nil)
  MiniTest.expect.equality(state.buf, nil)
end

T["toggle"] = toggle_set

return T
