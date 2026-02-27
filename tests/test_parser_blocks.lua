local T = MiniTest.new_set()

local parser = require("slides.parser")

T["find_code_blocks"] = function()
  local lines = {
    "# Header",
    "",
    "```lua",
    "print('hello')",
    "```",
    "",
    "Text",
    "",
    "```bash",
    "echo world",
    "```",
  }

  local blocks = parser.find_code_blocks(lines)
  MiniTest.expect.equality(#blocks, 2)

  MiniTest.expect.equality(blocks[1].lang, "lua")
  MiniTest.expect.equality(blocks[1].code, { "print('hello')" })

  MiniTest.expect.equality(blocks[2].lang, "bash")
  MiniTest.expect.equality(blocks[2].code, { "echo world" })
end

return T
