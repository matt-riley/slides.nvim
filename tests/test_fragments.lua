local MiniTest = require("mini.test")
local T = MiniTest.new_set()

local slides = require("slides")
local state = require("slides.state")
local parser = require("slides.parser")

local saved_options = {}

local fragment_set = MiniTest.new_set({
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
        slides.toggle()
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

fragment_set["builds fragments from separators"] = function()
  slides.setup()
  local fragments = parser.build_fragments({ "A", "++", "B", "++", "C" })

  MiniTest.expect.equality(fragments, {
    { "A" },
    { "A", "B" },
    { "A", "B", "C" },
  })
end

fragment_set["steps through fragments before slides"] = function()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    "A",
    "++",
    "B",
    "---",
    "C",
    "++",
    "D",
  })
  vim.api.nvim_set_current_buf(buf)

  slides.toggle()

  MiniTest.expect.equality(state.current, 1)
  MiniTest.expect.equality(state.fragment_index, 1)
  MiniTest.expect.equality(#state.fragments, 2)
  MiniTest.expect.equality(state.fragments[1], { "A" })
  MiniTest.expect.equality(state.fragments[2], { "A", "B" })

  slides.next_slide()
  MiniTest.expect.equality(state.current, 1)
  MiniTest.expect.equality(state.fragment_index, 2)

  slides.next_slide()
  MiniTest.expect.equality(state.current, 2)
  MiniTest.expect.equality(state.fragment_index, 1)
  MiniTest.expect.equality(state.fragments[1], { "C" })
  MiniTest.expect.equality(state.fragments[2], { "C", "D" })

  slides.prev_slide()
  MiniTest.expect.equality(state.current, 1)
  MiniTest.expect.equality(state.fragment_index, 2)
end

T["fragments"] = fragment_set

return T
