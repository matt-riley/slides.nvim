local MiniTest = require("mini.test")
local T = MiniTest.new_set()

local executor = require("slides.executor")

local deps = {
  progpath = "/usr/bin/nvim",
  tempname = function()
    return "/tmp/slides-code"
  end,
  writefile = function()
    return 0
  end,
  delete = function()
    return 0
  end,
}

T["prepares shell code for stdin"] = function()
  local request = executor.prepare({
    lang = "bash",
    code = { "echo hello", "echo world" },
  }, deps)

  MiniTest.expect.equality(request.command, { "bash" })
  MiniTest.expect.equality(request.stdin, "echo hello\necho world")
  MiniTest.expect.equality(request.cleanup, nil)
end

T["prepares python code for stdin"] = function()
  local request = executor.prepare({
    lang = "python",
    code = { "print('hello')" },
  }, deps)

  MiniTest.expect.equality(request.command, { "python3", "-" })
  MiniTest.expect.equality(request.stdin, "print('hello')")
end

T["prepares lua code in an isolated Neovim process"] = function()
  local request = executor.prepare({
    lang = "lua",
    code = { "print('hello')" },
  }, deps)

  MiniTest.expect.equality(request.command, {
    "/usr/bin/nvim",
    "--headless",
    "-u",
    "NONE",
    "-c",
    "lua print('hello')",
    "-c",
    "qa!",
  })
  MiniTest.expect.equality(request.stdin, nil)
end

T["uses a temporary Go file and removes it after execution"] = function()
  local written
  local deleted
  local request = executor.prepare({
    lang = "go",
    code = { "package main", "func main() {}" },
  }, {
    progpath = deps.progpath,
    tempname = deps.tempname,
    writefile = function(lines, path)
      written = { lines = lines, path = path }
      return 0
    end,
    delete = function(path)
      deleted = path
      return 0
    end,
  })

  MiniTest.expect.equality(written, {
    lines = { "package main", "func main() {}" },
    path = "/tmp/slides-code.go",
  })
  MiniTest.expect.equality(request.command, { "go", "run", "/tmp/slides-code.go" })
  MiniTest.expect.equality(type(request.cleanup), "function")

  request.cleanup()
  MiniTest.expect.equality(deleted, "/tmp/slides-code.go")
end

T["uses a temporary TypeScript file"] = function()
  local written_path
  local request = executor.prepare({
    lang = "typescript",
    code = { "console.log('hello')" },
  }, {
    progpath = deps.progpath,
    tempname = deps.tempname,
    writefile = function(_, path)
      written_path = path
      return 0
    end,
    delete = deps.delete,
  })

  MiniTest.expect.equality(written_path, "/tmp/slides-code.ts")
  MiniTest.expect.equality(request.command, { "bun", "run", "/tmp/slides-code.ts" })
end

T["rejects unsupported languages"] = function()
  local request, err = executor.prepare({
    lang = "brainfuck",
    code = { "+" },
  }, deps)

  MiniTest.expect.equality(request, nil)
  MiniTest.expect.equality(err, "Unsupported language: brainfuck")
end

return T
