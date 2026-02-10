-- lua/slides/init.lua
local M = {}

local parser = require("slides.parser")
local renderer = require("slides.renderer")
local state = require("slides.state")

local function update_fragments()
  state.fragments = parser.build_fragments(state.slides[state.current] or {})
  if #state.fragments == 0 then
    state.fragments = { {} }
  end
  if not state.fragment_index or state.fragment_index < 1 then
    state.fragment_index = 1
  elseif state.fragment_index > #state.fragments then
    state.fragment_index = #state.fragments
  end
end

local function render_current()
  renderer.render(state.fragments[state.fragment_index], state.current, #state.slides)
end

--- Configure the plugin with user options.
--- @param opts? table User configuration options
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", {
    separator = "^%-%-%-+$",
    fragment_separator = "^%+%++$",
    border = "rounded",
    fullscreen = true,
    width = 0.8,
    height = 0.8,
  }, opts or {})
end

--- Toggle presentation mode on/off.
function M.toggle()
  if state.active then
    renderer.close()
    pcall(vim.api.nvim_del_augroup_by_name, "SlidesLiveReload")
    state.reset()
    return
  end

  local source_buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(source_buf, 0, -1, false)
  local slides = parser.parse(lines)

  state.source_buf = source_buf
  state.slides = slides
  state.current = 1
  state.fragment_index = 1
  state.output_lines = nil
  state.active = true

  renderer.open()
  update_fragments()
  render_current()

  -- Buffer-local keymaps for navigation
  local buf = state.buf
  local opts = { noremap = true, silent = true, buffer = buf }
  vim.keymap.set("n", "l", function() M.next_slide() end, opts)
  vim.keymap.set("n", "h", function() M.prev_slide() end, opts)
  vim.keymap.set("n", "<C-e>", function() M.execute_code() end, opts)
  vim.keymap.set("n", "q", function() M.toggle() end, opts)
  vim.keymap.set("n", "<Escape>", function() M.toggle() end, opts)

  -- Live reload
  local group = vim.api.nvim_create_augroup("SlidesLiveReload", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    buffer = source_buf,
    callback = function()
      M.refresh()
    end,
  })
end

--- Refresh the current presentation from the source buffer.
function M.refresh()
  if not state.active or not state.source_buf then return end

  local lines = vim.api.nvim_buf_get_lines(state.source_buf, 0, -1, false)
  local slides = parser.parse(lines)

  state.slides = slides
  if state.current > #slides then
    state.current = #slides
  end

  state.output_lines = nil
  update_fragments()
  render_current()
end

--- Execute the first code block in the current slide.
function M.execute_code()
  if not state.active or not state.buf then return end

  local current_slide = (state.fragments and state.fragments[state.fragment_index]) or state.slides[state.current]
  local blocks = parser.find_code_blocks(current_slide)

  if #blocks == 0 then
    print("No code blocks found on this slide.")
    return
  end

  local block = blocks[1]
  local output = {}

  local function append_output(result)
    for line in result:gmatch("[^\r\n]+") do
      table.insert(output, line)
    end
  end

  local function run_tempfile(ext, cmd, code_lines)
    local tmp = vim.fn.tempname() .. ext
    vim.fn.writefile(code_lines, tmp)
    local result = vim.fn.system(cmd .. " " .. vim.fn.shellescape(tmp))
    vim.fn.delete(tmp)
    return result
  end

  if block.lang == "lua" then
    local code = table.concat(block.code, "\n")
    -- Capture print output? Complex. For now just run it.
    -- Or use redirect.
    append_output(vim.fn.execute("lua " .. code))
  elseif block.lang == "bash" or block.lang == "sh" then
    local code = table.concat(block.code, "\n")
    append_output(vim.fn.system(code))
  elseif block.lang == "python" or block.lang == "python3" then
    local code = table.concat(block.code, "\n")
    append_output(vim.fn.system("python3 -c " .. vim.fn.shellescape(code)))
  elseif block.lang == "go" or block.lang == "golang" then
    append_output(run_tempfile(".go", "go run", block.code))
  elseif block.lang == "typescript" or block.lang == "ts" then
    append_output(run_tempfile(".ts", "bun run", block.code))
  else
    print("Unsupported language: " .. (block.lang or "unknown"))
    return
  end

  state.output_lines = output
  render_current()
end

--- Advance to the next slide.
function M.next_slide()
  if not state.active then return end
  if state.fragment_index < #state.fragments then
    state.fragment_index = state.fragment_index + 1
    render_current()
    return
  end
  if state.current < #state.slides then
    state.current = state.current + 1
    state.fragment_index = 1
    state.output_lines = nil
    update_fragments()
    render_current()
  end
end

--- Go back to the previous slide.
function M.prev_slide()
  if not state.active then return end
  if state.fragment_index > 1 then
    state.fragment_index = state.fragment_index - 1
    render_current()
    return
  end
  if state.current > 1 then
    state.current = state.current - 1
    state.output_lines = nil
    update_fragments()
    state.fragment_index = #state.fragments
    render_current()
  end
end

return M
