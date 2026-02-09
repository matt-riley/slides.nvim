-- lua/slides/renderer.lua
local M = {}

local state = require("slides.state")

local counter_ns = vim.api.nvim_create_namespace("slides_counter")

local function ensure_bg_buf_height(buf, height)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then return end
  height = math.max(1, height)

  local cur = vim.api.nvim_buf_line_count(buf)
  if cur == height then return end

  vim.bo[buf].modifiable = true
  if cur < height then
    local pad = {}
    for _ = 1, (height - cur) do
      pad[#pad + 1] = ""
    end
    vim.api.nvim_buf_set_lines(buf, cur, cur, false, pad)
  else
    vim.api.nvim_buf_set_lines(buf, height, -1, false, {})
  end
  vim.bo[buf].modifiable = false
end

local function apply_header_winhl(win)
  local remaps = {}
  local function add(from, to)
    if vim.fn.hlexists(from) == 1 then remaps[from] = to end
  end

  for i = 1, 6 do
    add("markdownH" .. i, "Title")
    add("markdownH" .. i .. "Delimiter", "Title")
    add("markdownH" .. i .. "Line", "Title")
  end
  add("markdownHeadingDelimiter", "Title")

  add("@markup.heading", "Title")
  add("@markup.heading.marker", "Title")
  for i = 1, 6 do
    add("@markup.heading." .. i, "Title")
    add("@text.title." .. i, "Title")
  end
  add("@text.title", "Title")

  local cur = vim.wo[win].winhl
  local parts = {}
  if cur and cur ~= "" then
    for part in string.gmatch(cur, "[^,]+") do
      local from = part:match("^([^:]+):")
      if not (from and remaps[from]) then table.insert(parts, part) end
    end
  end

  local ordered = {
    "markdownHeadingDelimiter",
    "markdownH1",
    "markdownH1Delimiter",
    "markdownH1Line",
    "markdownH2",
    "markdownH2Delimiter",
    "markdownH2Line",
    "markdownH3",
    "markdownH3Delimiter",
    "markdownH3Line",
    "markdownH4",
    "markdownH4Delimiter",
    "markdownH4Line",
    "markdownH5",
    "markdownH5Delimiter",
    "markdownH5Line",
    "markdownH6",
    "markdownH6Delimiter",
    "markdownH6Line",
    "@markup.heading",
    "@markup.heading.marker",
    "@markup.heading.1",
    "@markup.heading.2",
    "@markup.heading.3",
    "@markup.heading.4",
    "@markup.heading.5",
    "@markup.heading.6",
    "@text.title",
    "@text.title.1",
    "@text.title.2",
    "@text.title.3",
    "@text.title.4",
    "@text.title.5",
    "@text.title.6",
  }

  for _, from in ipairs(ordered) do
    local to = remaps[from]
    if to then
      table.insert(parts, from .. ":" .. to)
      remaps[from] = nil
    end
  end
  for from, to in pairs(remaps) do
    table.insert(parts, from .. ":" .. to)
  end

  vim.wo[win].winhl = table.concat(parts, ",")
end

local function hide_cursor(win)
  local remaps = {}
  local function add(from, to)
    if vim.fn.hlexists(from) == 1 then remaps[from] = to end
  end

  add("Cursor", "Normal")
  add("CursorIM", "Normal")
  add("lCursor", "Normal")
  add("TermCursor", "Normal")
  add("TermCursorNC", "Normal")

  local cur = vim.wo[win].winhl
  local parts = {}
  if cur and cur ~= "" then
    for part in string.gmatch(cur, "[^,]+") do
      local from = part:match("^([^:]+):")
      if not (from and remaps[from]) then table.insert(parts, part) end
    end
  end

  local ordered = { "Cursor", "CursorIM", "lCursor", "TermCursor", "TermCursorNC" }
  for _, from in ipairs(ordered) do
    local to = remaps[from]
    if to then
      table.insert(parts, from .. ":" .. to)
      remaps[from] = nil
    end
  end
  for from, to in pairs(remaps) do
    table.insert(parts, from .. ":" .. to)
  end

  vim.wo[win].winhl = table.concat(parts, ",")
  vim.wo[win].cursorline = false
  vim.wo[win].cursorcolumn = false
end

--- Open the floating presentation window.
function M.open()
  local buf = vim.api.nvim_create_buf(false, true)

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].syntax = "markdown"

  if vim.treesitter and vim.treesitter.start then
    pcall(vim.treesitter.start, buf, "markdown")
  end

  local editor_width = vim.o.columns
  local editor_height = vim.o.lines - vim.o.cmdheight

  local slides_mod = package.loaded["slides"]
  local cfg = (slides_mod and slides_mod.config) or {}

  local fullscreen = cfg.fullscreen ~= false

  local win_width, win_height, col, row
  if fullscreen then
    local bg_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[bg_buf].buftype = "nofile"
    vim.bo[bg_buf].bufhidden = "wipe"
    vim.bo[bg_buf].swapfile = false

    ensure_bg_buf_height(bg_buf, editor_height)

    local bg_win = vim.api.nvim_open_win(bg_buf, false, {
      relative = "editor",
      width = editor_width,
      height = editor_height,
      col = 0,
      row = 0,
      style = "minimal",
      border = "none",
      focusable = false,
    })

    vim.wo[bg_win].fillchars = "eob: "

    state.bg_buf = bg_buf
    state.bg_win = bg_win

    win_width = editor_width
    win_height = editor_height
    col = 0
    row = 0
  else
    win_width = math.floor(editor_width * (cfg.width or 0.8))
    win_height = math.floor(editor_height * (cfg.height or 0.8))
    col = math.floor((editor_width - win_width) / 2)
    row = math.floor((editor_height - win_height) / 2)
  end

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = win_width,
    height = win_height,
    col = col,
    row = row,
    style = "minimal",
    border = fullscreen and "none" or (cfg.border or "rounded"),
  })

  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.wo[win].fillchars = "eob: "
  pcall(apply_header_winhl, win)
  if cfg.hide_cursor ~= false then
    pcall(hide_cursor, win)
  end

  state.buf = buf
  state.win = win
end

--- Render a slide in the floating window.
--- @param slide_lines string[] Lines of the current slide
--- @param current number Current slide number
--- @param total number Total number of slides
function M.render(slide_lines, current, total)
  local buf = state.buf
  local win = state.win

  if not buf or not vim.api.nvim_buf_is_valid(buf) then return end
  if not win or not vim.api.nvim_win_is_valid(win) then return end

  local slides_mod = package.loaded["slides"]
  local cfg = (slides_mod and slides_mod.config) or {}
  local fullscreen = cfg.fullscreen ~= false

  local editor_width = vim.o.columns
  local editor_height = vim.o.lines - vim.o.cmdheight

  if fullscreen and state.bg_win and vim.api.nvim_win_is_valid(state.bg_win) then
    pcall(vim.api.nvim_win_set_config, state.bg_win, {
      relative = "editor",
      width = editor_width,
      height = editor_height,
      col = 0,
      row = 0,
    })
  end

  -- Slide counter footer
  local counter_line = string.format("[%d/%d]", current, total)

  if fullscreen then
    if state.bg_buf and vim.api.nvim_buf_is_valid(state.bg_buf) then
      ensure_bg_buf_height(state.bg_buf, editor_height)

      vim.bo[state.bg_buf].modifiable = true
      vim.api.nvim_buf_set_lines(state.bg_buf, editor_height - 1, editor_height, false, { "" })
      vim.bo[state.bg_buf].modifiable = false

      vim.api.nvim_buf_clear_namespace(state.bg_buf, counter_ns, 0, -1)
      local ok = pcall(vim.api.nvim_buf_set_extmark, state.bg_buf, counter_ns, editor_height - 1, 0, {
        virt_text = { { counter_line, "Comment" } },
        virt_text_pos = "right_align",
      })

      if not ok then
        local pad = math.max(0, editor_width - vim.fn.strdisplaywidth(counter_line))
        vim.bo[state.bg_buf].modifiable = true
        vim.api.nvim_buf_set_lines(state.bg_buf, editor_height - 1, editor_height, false, { string.rep(" ", pad) .. counter_line })
        vim.bo[state.bg_buf].modifiable = false
      end
    end

    local max_w = 1
    for _, line in ipairs(slide_lines) do
      max_w = math.max(max_w, vim.fn.strdisplaywidth(line))
    end

    local content_height = math.max(1, #slide_lines)

    local win_width = math.min(editor_width, math.max(1, max_w))
    local win_height = math.min(editor_height, content_height)

    local col = math.floor((editor_width - win_width) / 2)
    local row = math.floor((editor_height - win_height) / 2)

    pcall(vim.api.nvim_win_set_config, win, {
      relative = "editor",
      width = win_width,
      height = win_height,
      col = col,
      row = row,
    })

    local output = (#slide_lines > 0) and slide_lines or { "" }

    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
    vim.bo[buf].modifiable = false

    return
  end

  local win_height = vim.api.nvim_win_get_height(win)

  -- Vertical centering: total content = slide lines + 2 (blank + counter)
  local content_height = #slide_lines + 2
  local v_pad = math.max(0, math.floor((win_height - content_height) / 2))

  -- Build final buffer content
  local output = {}
  for _ = 1, v_pad do
    table.insert(output, "")
  end
  for _, line in ipairs(slide_lines) do
    table.insert(output, line)
  end
  table.insert(output, "")
  table.insert(output, counter_line)

  -- Write to buffer
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
  vim.bo[buf].modifiable = false
end

--- Close the floating presentation window.
function M.close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    vim.api.nvim_buf_delete(state.buf, { force = true })
  end
  if state.bg_win and vim.api.nvim_win_is_valid(state.bg_win) then
    vim.api.nvim_win_close(state.bg_win, true)
  end
  if state.bg_buf and vim.api.nvim_buf_is_valid(state.bg_buf) then
    vim.api.nvim_buf_delete(state.bg_buf, { force = true })
  end
  state.win = nil
  state.buf = nil
  state.bg_win = nil
  state.bg_buf = nil
end

return M
