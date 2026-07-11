local M = {}

---@class slides.CodeBlock
---@field lang string
---@field code string[]

---@class slides.ExecutionRequest
---@field command string[] Process argv.
---@field stdin? string Process standard input.
---@field cleanup? fun() Cleanup invoked after process completion.

---@class slides.ExecutorDependencies
---@field progpath? string Neovim executable path.
---@field tempname? fun(): string Temporary path generator.
---@field writefile? fun(lines: string[], path: string): integer Temporary file writer.
---@field delete? fun(path: string): integer Temporary file remover.

---@param deps? slides.ExecutorDependencies
---@return table
local function resolve_dependencies(deps)
  deps = deps or {}

  return {
    progpath = deps.progpath or vim.v.progpath,
    tempname = deps.tempname or vim.fn.tempname,
    writefile = deps.writefile or vim.fn.writefile,
    delete = deps.delete or vim.fn.delete,
  }
end

---@param block slides.CodeBlock
---@param extension string
---@param command fun(path: string): string[]
---@param deps table
---@return slides.ExecutionRequest? request
---@return string? err
local function temporary_request(block, extension, command, deps)
  local path = deps.tempname() .. extension
  local ok, result = pcall(deps.writefile, block.code, path)
  if not ok or result == -1 then
    return nil, ("Unable to write temporary %s file"):format(extension)
  end

  return {
    command = command(path),
    cleanup = function()
      pcall(deps.delete, path)
    end,
  }
end

---@param block slides.CodeBlock
---@param dependencies? slides.ExecutorDependencies
---@return slides.ExecutionRequest? request
---@return string? err
function M.prepare(block, dependencies)
  if type(block) ~= "table" or type(block.lang) ~= "string" or type(block.code) ~= "table" then
    return nil, "Invalid code block"
  end

  local deps = resolve_dependencies(dependencies)
  local lang = block.lang:lower()
  local code = table.concat(block.code, "\n")

  if lang == "bash" or lang == "sh" then
    return {
      command = { lang },
      stdin = code,
    }
  end

  if lang == "python" or lang == "python3" then
    return {
      command = { "python3", "-" },
      stdin = code,
    }
  end

  if lang == "lua" then
    return temporary_request(block, ".lua", function(path)
      return { deps.progpath, "--headless", "-u", "NONE", "-l", path }
    end, deps)
  end

  if lang == "go" or lang == "golang" then
    return temporary_request(block, ".go", function(path)
      return { "go", "run", path }
    end, deps)
  end

  if lang == "typescript" or lang == "ts" then
    return temporary_request(block, ".ts", function(path)
      return { "bun", "run", path }
    end, deps)
  end

  return nil, "Unsupported language: " .. (block.lang ~= "" and block.lang or "unknown")
end

return M
