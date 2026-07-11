local M = {}

---@class slides.RunnerOptions
---@field stdin? string Standard input passed to the process.
---@field cwd? string Working directory for the process.
---@field timeout? integer Timeout in milliseconds.

---@class slides.RunnerResult
---@field ok boolean Whether the process exited successfully.
---@field code integer Process exit code.
---@field signal integer Process exit signal.
---@field stdout string Captured standard output.
---@field stderr string Captured standard error.
---@field lines string[] Normalized output lines for rendering.

---@param lines string[]
---@param text string?
local function append_lines(lines, text)
  if not text or text == "" then
    return
  end

  local normalized = text:gsub("\r\n", "\n"):gsub("\r", "\n"):gsub("\n+$", "")
  if normalized == "" then
    return
  end

  vim.list_extend(lines, vim.split(normalized, "\n", { plain = true }))
end

---@param raw vim.SystemCompleted
---@return slides.RunnerResult
local function normalize_result(raw)
  raw = raw or {}

  local code = raw.code or -1
  local stdout = raw.stdout or ""
  local stderr = raw.stderr or ""
  local lines = {}

  append_lines(lines, stdout)
  append_lines(lines, stderr)

  if #lines == 0 and code ~= 0 then
    lines = { ("Process exited with code %d"):format(code) }
  end

  return {
    ok = code == 0,
    code = code,
    signal = raw.signal or 0,
    stdout = stdout,
    stderr = stderr,
    lines = lines,
  }
end

---@param command string[]
---@param opts? slides.RunnerOptions
---@param callback? fun(result: slides.RunnerResult)
---@return vim.SystemObj
function M.run(command, opts, callback)
  if type(command) ~= "table" or #command == 0 then
    error("command must be a non-empty argv table")
  end
  if callback ~= nil and type(callback) ~= "function" then
    error("callback must be a function")
  end
  if type(vim.system) ~= "function" then
    error("slides.nvim code execution requires vim.system (Neovim 0.10+)")
  end

  opts = opts or {}
  callback = callback or function() end

  local system_opts = { text = true }
  if opts.stdin ~= nil then
    system_opts.stdin = opts.stdin
  end
  if opts.cwd ~= nil then
    system_opts.cwd = opts.cwd
  end
  if opts.timeout ~= nil then
    system_opts.timeout = opts.timeout
  end

  return vim.system(command, system_opts, function(raw)
    local result = normalize_result(raw)
    vim.schedule(function()
      callback(result)
    end)
  end)
end

---@param job vim.SystemObj?
---@return boolean cancelled
function M.cancel(job)
  if not job or type(job.kill) ~= "function" then
    return false
  end

  local ok = pcall(job.kill, job, 15)
  return ok
end

M.normalize_result = normalize_result

return M
