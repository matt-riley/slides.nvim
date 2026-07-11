-- lua/slides/init.lua
local M = {}

local executor = require("slides.executor")
local parser = require("slides.parser")
local renderer = require("slides.renderer")
local runner = require("slides.runner")
local state = require("slides.state")

--- slides.nvim
---
--- Present Markdown files as slides inside a floating Neovim window.
---
--- Features ~
--- - Split slides on `---`.
--- - Reveal fragments using `++` separators.
--- - Live reload after writing the source buffer.
--- - Execute the first fenced code block on a slide with `<C-e>`.
---
--- Usage ~
--- - Open a Markdown file.
--- - Run `:Slides` to toggle presentation mode.
--- - Use `h`/`l` to move through fragments and slides.
---
---@tag slides

--- Plugin configuration.
---@class slides.Config
---@field separator string Pattern used to split slides.
---@field fragment_separator string Pattern used to split fragments.
---@field border string Floating window border style in non-fullscreen mode.
---@field fullscreen boolean Use fullscreen floating window.
---@field width number Floating width ratio in non-fullscreen mode.
---@field height number Floating height ratio in non-fullscreen mode.
---@field execution_timeout integer Maximum code execution time in milliseconds.

---@private
---@type slides.Config
local defaults = {
  separator = "^%-%-%-+$",
  fragment_separator = "^%s*%+%+%+*%s*$",
  border = "rounded",
  fullscreen = true,
  width = 0.8,
  height = 0.8,
  execution_timeout = 30000,
}

---@private
---@type slides.Config
M.config = vim.deepcopy(defaults)

---@private
local function update_fragments()
  state.fragments = parser.build_fragments(state.slides[state.current] or {}, M.config)
  if #state.fragments == 0 then
    state.fragments = { {} }
  end
  if not state.fragment_index or state.fragment_index < 1 then
    state.fragment_index = 1
  elseif state.fragment_index > #state.fragments then
    state.fragment_index = #state.fragments
  end
end

---@private
local function render_current()
  renderer.render(state.fragments[state.fragment_index], state.current, #state.slides, M.config)
end

---@private
local function cancel_execution()
  state.execution_id = state.execution_id + 1
  local job = state.execution_job
  state.execution_job = nil
  runner.cancel(job)
end

--- Configure slides.nvim.
---
--- Example:
--- `require("slides").setup({ fullscreen = false, width = 0.9, height = 0.9 })`
---
---@param opts? slides.Config User configuration options
function M.setup(opts)
  opts = opts or {}
  vim.validate({
    separator = { opts.separator, "string", true },
    fragment_separator = { opts.fragment_separator, "string", true },
    border = { opts.border, "string", true },
    fullscreen = { opts.fullscreen, "boolean", true },
    width = { opts.width, "number", true },
    height = { opts.height, "number", true },
    execution_timeout = { opts.execution_timeout, "number", true },
  })
  M.config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts)
end

--- Toggle presentation mode on or off.
---
--- Keymaps inside the slides window:
--- - `l`: next fragment/slide
--- - `h`: previous fragment/slide
--- - `<C-e>`: execute first fenced code block on current slide
--- - `q` / `<Esc>`: close presentation
function M.toggle()
  if state.active then
    cancel_execution()
    renderer.close()
    pcall(vim.api.nvim_del_augroup_by_name, "SlidesLiveReload")
    state.reset()
    return
  end

  local source_buf = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(source_buf, 0, -1, false)
  local slides = parser.parse(lines, M.config)

  state.source_buf = source_buf
  state.slides = slides
  state.current = 1
  state.fragment_index = 1
  state.output_lines = nil
  state.execution_job = nil
  state.active = true

  renderer.open(M.config)
  update_fragments()
  render_current()

  -- Buffer-local keymaps for navigation
  local buf = state.buf
  local opts = { noremap = true, silent = true, buffer = buf }
  vim.keymap.set("n", "l", function()
    M.next_slide()
  end, opts)
  vim.keymap.set("n", "h", function()
    M.prev_slide()
  end, opts)
  vim.keymap.set("n", "<C-e>", function()
    M.execute_code()
  end, opts)
  vim.keymap.set("n", "q", function()
    M.toggle()
  end, opts)
  vim.keymap.set("n", "<Escape>", function()
    M.toggle()
  end, opts)

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

--- Refresh the active presentation from the source buffer.
function M.refresh()
  if not state.active or not state.source_buf then
    return
  end

  cancel_execution()

  local lines = vim.api.nvim_buf_get_lines(state.source_buf, 0, -1, false)
  local slides = parser.parse(lines, M.config)

  state.slides = slides
  if state.current > #slides then
    state.current = #slides
  end

  state.output_lines = nil
  update_fragments()
  render_current()
end

--- Execute the first fenced code block in the current slide.
function M.execute_code()
  if not state.active or not state.buf then
    return
  end

  cancel_execution()
  local execution_id = state.execution_id

  local current_slide = (state.fragments and state.fragments[state.fragment_index]) or state.slides[state.current]
  local blocks = parser.find_code_blocks(current_slide)

  if #blocks == 0 then
    state.output_lines = { "No code blocks found on this slide." }
    render_current()
    return
  end

  local request, prepare_err = executor.prepare(blocks[1])
  if not request then
    state.output_lines = { prepare_err or "Unable to prepare code block." }
    render_current()
    return
  end

  state.output_lines = { "Running..." }
  render_current()

  local cleaned = false
  local function cleanup()
    if cleaned then
      return
    end
    cleaned = true
    if request.cleanup then
      request.cleanup()
    end
  end

  local ok, job_or_err = pcall(runner.run, request.command, {
    stdin = request.stdin,
    cwd = request.cwd,
    timeout = M.config.execution_timeout,
  }, function(result)
    cleanup()

    if not state.active or state.execution_id ~= execution_id then
      return
    end

    state.execution_job = nil
    state.output_lines = result.lines
    render_current()
  end)

  if not ok then
    cleanup()
    if state.execution_id == execution_id then
      state.output_lines = { tostring(job_or_err) }
      render_current()
    end
    return
  end

  state.execution_job = job_or_err
end

--- Advance to the next fragment or slide.
function M.next_slide()
  if not state.active then
    return
  end
  if state.fragment_index < #state.fragments then
    state.fragment_index = state.fragment_index + 1
    render_current()
    return
  end
  if state.current < #state.slides then
    cancel_execution()
    state.current = state.current + 1
    state.fragment_index = 1
    state.output_lines = nil
    update_fragments()
    render_current()
  end
end

--- Go to the previous fragment or slide.
function M.prev_slide()
  if not state.active then
    return
  end
  if state.fragment_index > 1 then
    state.fragment_index = state.fragment_index - 1
    render_current()
    return
  end
  if state.current > 1 then
    cancel_execution()
    state.current = state.current - 1
    state.output_lines = nil
    update_fragments()
    state.fragment_index = #state.fragments
    render_current()
  end
end

return M
