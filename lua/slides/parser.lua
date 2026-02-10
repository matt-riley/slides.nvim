-- lua/slides/parser.lua
local M = {}

--- Remove leading and trailing empty lines from a list of lines.
--- @param lines string[]
--- @return string[]
local function trim_blank_lines(lines)
  local start_idx = 1
  local end_idx = #lines

  while start_idx <= end_idx and lines[start_idx]:match("^%s*$") do
    start_idx = start_idx + 1
  end

  while end_idx >= start_idx and lines[end_idx]:match("^%s*$") do
    end_idx = end_idx - 1
  end

  local trimmed = {}
  for i = start_idx, end_idx do
    table.insert(trimmed, lines[i])
  end
  return trimmed
end

local function execute_preprocessor(cmd, input_lines)
  local input = table.concat(input_lines, "\n")
  local output = vim.fn.system(cmd, input)
  local result_lines = {}
  for line in output:gmatch("[^\r\n]+") do
    table.insert(result_lines, line)
  end
  return result_lines
end

local function preprocess(lines)
  local new_lines = {}
  local in_block = false
  local current_cmd = nil
  local block_lines = {}

  for _, line in ipairs(lines) do
    local cmd = line:match("^~~~(.+)")
    local end_block = line:match("^~~~$")

    if in_block then
      if end_block then
        local output = execute_preprocessor(current_cmd, block_lines)
        for _, l in ipairs(output) do
          table.insert(new_lines, l)
        end
        in_block = false
        current_cmd = nil
        block_lines = {}
      else
        table.insert(block_lines, line)
      end
    elseif cmd then
      in_block = true
      current_cmd = cmd
    else
      table.insert(new_lines, line)
    end
  end
  
  -- Handle unclosed block (just append raw?)
  if in_block then
    table.insert(new_lines, "~~~" .. current_cmd)
    for _, l in ipairs(block_lines) do
      table.insert(new_lines, l)
    end
  end

  return new_lines
end

--- Parse buffer lines into slides, splitting on --- separators.
--- @param lines string[] Buffer lines
--- @return string[][] List of slides (each slide is a list of lines)
function M.parse(lines)
  -- Run preprocessors first
  lines = preprocess(lines)

  local slides = {}
  local current = {}

  local slides_mod = package.loaded["slides"]
  local separator = (slides_mod and slides_mod.config and slides_mod.config.separator) or "^%-%-%-+$"

  for _, line in ipairs(lines) do
    if line:match(separator) then
      local trimmed = trim_blank_lines(current)
      if #trimmed > 0 or #slides > 0 then
        table.insert(slides, trimmed)
      end
      current = {}
    else
      table.insert(current, line)
    end
  end

  -- Add the final slide
  local trimmed = trim_blank_lines(current)
  if #trimmed > 0 or #slides > 0 then
    table.insert(slides, trimmed)
  end

  -- Ensure at least one slide
  if #slides == 0 then
    table.insert(slides, {})
  end

  return slides
end

--- Find code blocks in a list of lines.
--- @param lines string[]
--- @return table[] List of { lang = string, code = string[] }
function M.find_code_blocks(lines)
  local blocks = {}
  local current_lang = nil
  local current_code = {}
  local in_block = false

  for _, line in ipairs(lines) do
    local lang = line:match("^```(%w+)")
    local end_block = line:match("^```$")

    if in_block then
      if end_block then
        table.insert(blocks, { lang = current_lang, code = current_code })
        in_block = false
        current_code = {}
        current_lang = nil
      else
        table.insert(current_code, line)
      end
    elseif lang then
      in_block = true
      current_lang = lang
    end
  end

  return blocks
end

return M
