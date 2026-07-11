local MiniTest = require("mini.test")
local T = MiniTest.new_set()

local runner = require("slides.runner")

local original_system

local runner_set = MiniTest.new_set({
  hooks = {
    pre_case = function()
      original_system = vim.system
    end,
    post_case = function()
      vim.system = original_system
    end,
  },
})

runner_set["runs argv commands with structured options"] = function()
  local captured = {}
  local system_callback
  local handle = { id = 42 }

  vim.system = function(command, opts, callback)
    captured.command = command
    captured.opts = opts
    system_callback = callback
    return handle
  end

  local result
  local returned = runner.run({ "bash" }, {
    stdin = "printf 'hello'",
    cwd = "/tmp/project",
    timeout = 250,
  }, function(value)
    result = value
  end)

  MiniTest.expect.equality(returned, handle)
  MiniTest.expect.equality(captured.command, { "bash" })
  MiniTest.expect.equality(captured.opts, {
    text = true,
    stdin = "printf 'hello'",
    cwd = "/tmp/project",
    timeout = 250,
  })

  system_callback({
    code = 0,
    signal = 0,
    stdout = "first\n\nthird\n",
    stderr = "",
  })

  vim.wait(100, function()
    return result ~= nil
  end)

  MiniTest.expect.equality(result.ok, true)
  MiniTest.expect.equality(result.code, 0)
  MiniTest.expect.equality(result.signal, 0)
  MiniTest.expect.equality(result.stdout, "first\n\nthird\n")
  MiniTest.expect.equality(result.stderr, "")
  MiniTest.expect.equality(result.lines, { "first", "", "third" })
end

runner_set["uses stderr for failed command output"] = function()
  local system_callback

  vim.system = function(_, _, callback)
    system_callback = callback
    return {}
  end

  local result
  runner.run({ "false" }, {}, function(value)
    result = value
  end)

  system_callback({
    code = 2,
    signal = 0,
    stdout = "",
    stderr = "command failed\n",
  })

  vim.wait(100, function()
    return result ~= nil
  end)

  MiniTest.expect.equality(result.ok, false)
  MiniTest.expect.equality(result.lines, { "command failed" })
end

runner_set["reports a failed command with no output"] = function()
  local system_callback

  vim.system = function(_, _, callback)
    system_callback = callback
    return {}
  end

  local result
  runner.run({ "false" }, {}, function(value)
    result = value
  end)

  system_callback({
    code = 7,
    signal = 0,
    stdout = "",
    stderr = "",
  })

  vim.wait(100, function()
    return result ~= nil
  end)

  MiniTest.expect.equality(result.lines, { "Process exited with code 7" })
end

runner_set["cancels a running process"] = function()
  local received_signal
  local handle = {
    kill = function(_, signal)
      received_signal = signal
    end,
  }

  MiniTest.expect.equality(runner.cancel(handle), true)
  MiniTest.expect.equality(received_signal, 15)
  MiniTest.expect.equality(runner.cancel(nil), false)
end

T["runner"] = runner_set

return T
