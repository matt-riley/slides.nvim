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

--- Parse buffer lines into slides, splitting on --- separators.
--- @param lines string[] Buffer lines
--- @return string[][] List of slides (each slide is a list of lines)
function M.parse(lines)
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

return M
