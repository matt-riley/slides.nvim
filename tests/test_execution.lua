local MiniTest = require("mini.test")
local T = MiniTest.new_set()

local executor = require("slides.executor")
local runner = require("slides.runner")
local slides = require("slides")
local state = require("slides.state")

local original_prepare
local original_run
local original_cancel
local prepare_stub
local run_stub
local cancel_stub

---@param module table
---@param name string
---@param value any
local function set_field(module, name, value)
  module[name] = value
end

local execution_set = MiniTest.new_set({
  hooks = {
    pre_case = function()
      original_prepare = executor.prepare
      original_run = runner.run
      original_cancel = runner.cancel

      set_field(executor, "prepare", function(...)
        return prepare_stub(...)
      end)
      set_field(runner, "run", function(...)
        return run_stub(...)
      end)
      set_field(runner, "cancel", function(...)
        return cancel_stub(...)
      end)

      slides.setup({ execution_timeout = 1234 })
      state.reset()
      state.active = true
      state.buf = vim.api.nvim_get_current_buf()
      state.slides = {
        {
          "```bash",
          "echo hello",
          "```",
        },
      }
      state.fragments = { state.slides[1] }
      state.current = 1
      state.fragment_index = 1
    end,
    post_case = function()
      set_field(executor, "prepare", original_prepare)
      set_field(runner, "run", original_run)
      set_field(runner, "cancel", original_cancel)
      state.reset()
    end,
  },
})

execution_set["renders running state and completed output"] = function()
  local captured = {}
  local callback
  local cleaned = false
  local job = { id = 1 }

  prepare_stub = function()
    return {
      command = { "bash" },
      stdin = "echo hello",
      cleanup = function()
        cleaned = true
      end,
    }
  end

  cancel_stub = function()
    return false
  end

  run_stub = function(command, opts, on_exit)
    captured.command = command
    captured.opts = opts
    callback = on_exit
    return job
  end

  slides.execute_code()

  MiniTest.expect.equality(captured.command, { "bash" })
  MiniTest.expect.equality(captured.opts, {
    stdin = "echo hello",
    timeout = 1234,
  })
  MiniTest.expect.equality(state.output_lines, { "Running..." })
  MiniTest.expect.equality(state.execution_job, job)

  callback({ lines = { "hello" } })

  MiniTest.expect.equality(cleaned, true)
  MiniTest.expect.equality(state.output_lines, { "hello" })
  MiniTest.expect.equality(state.execution_job, nil)
end

execution_set["ignores stale output after replacing a job"] = function()
  local callbacks = {}
  local jobs = { { id = 1 }, { id = 2 } }
  local run_count = 0
  local cancelled
  local cleanup_count = 0

  prepare_stub = function()
    return {
      command = { "bash" },
      stdin = "echo hello",
      cleanup = function()
        cleanup_count = cleanup_count + 1
      end,
    }
  end

  cancel_stub = function(job)
    if job then
      cancelled = job
      return true
    end
    return false
  end

  run_stub = function(_, _, callback)
    run_count = run_count + 1
    callbacks[run_count] = callback
    return jobs[run_count]
  end

  slides.execute_code()
  slides.execute_code()

  MiniTest.expect.equality(cancelled, jobs[1])
  MiniTest.expect.equality(state.execution_job, jobs[2])

  callbacks[1]({ lines = { "old" } })
  MiniTest.expect.equality(cleanup_count, 1)
  MiniTest.expect.equality(state.output_lines, { "Running..." })
  MiniTest.expect.equality(state.execution_job, jobs[2])

  callbacks[2]({ lines = { "new" } })
  MiniTest.expect.equality(cleanup_count, 2)
  MiniTest.expect.equality(state.output_lines, { "new" })
  MiniTest.expect.equality(state.execution_job, nil)
end

execution_set["cancels an active job when the slide has no code block"] = function()
  local job = { id = 1 }
  local cancelled

  state.execution_job = job
  state.fragments = { { "# No code here" } }

  cancel_stub = function(value)
    cancelled = value
    return true
  end

  slides.execute_code()

  MiniTest.expect.equality(cancelled, job)
  MiniTest.expect.equality(state.execution_job, nil)
  MiniTest.expect.equality(state.output_lines, { "No code blocks found on this slide." })
end

T["execution"] = execution_set

return T
