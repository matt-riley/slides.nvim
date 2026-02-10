local M = {}

local notified = {}
local render_generation = 0

local function notify_once(key, message)
  if notified[key] then return end
  notified[key] = true
  vim.schedule(function()
    vim.notify(message, vim.log.levels.WARN, { title = "slides.nvim" })
  end)
end

local function parse_image_line(line)
  return line:match("^%s*!%[([^%]]*)%]%(([^%)]+)%)%s*$")
end

local function normalize_path(raw)
  local trimmed = vim.trim(raw)
  local angled = trimmed:match("^<(.+)>$")
  if angled then return angled end
  local quoted = trimmed:match('^"(.+)"$') or trimmed:match("^'(.+)'$")
  if quoted then return quoted end
  return trimmed:match("^([^%s]+)") or ""
end

local function is_url(path)
  return path:match("^https?://") ~= nil
end

local function is_absolute(path)
  return path:match("^/") or path:match("^%a:[/\\]")
end

local function resolve_local_path(doc_path, image_path)
  local expanded = vim.fn.expand(image_path)
  if doc_path and doc_path ~= "" and not is_absolute(expanded) then
    local base = vim.fn.fnamemodify(doc_path, ":p:h")
    expanded = base .. "/" .. expanded
  end
  return vim.fn.fnamemodify(expanded, ":p")
end

local function placeholder_text(alt, path)
  local label = (alt and alt ~= "") and alt or path or "image"
  return ("[image: %s]"):format(label)
end

local function image_api()
  local ok, api = pcall(require, "image")
  if ok then return api end
  return nil
end

function M.is_available()
  return image_api() ~= nil
end

function M.notify_missing()
  notify_once("image_missing", "slides.nvim: image.nvim not found; install 3rd/image.nvim to render images")
end

function M.prepare(lines, source_buf, opts, render_images)
  local output = {}
  local images = {}
  local source_path = ""
  if source_buf and vim.api.nvim_buf_is_valid(source_buf) then
    source_path = vim.api.nvim_buf_get_name(source_buf)
  end

  local allow_remote = not (opts and opts.download_remote == false)
  local can_render = render_images == true

  for _, line in ipairs(lines) do
    local alt, raw = parse_image_line(line)
    if not raw then
      table.insert(output, line)
    else
      local path = normalize_path(raw)
      if path == "" then
        table.insert(output, line)
      else
        local placeholder = placeholder_text(alt, path)
        if is_url(path) then
          if not allow_remote then
            if can_render then
              notify_once("remote_disabled", "slides.nvim: remote image downloads are disabled")
            end
            table.insert(output, placeholder)
          elseif not can_render then
            table.insert(output, placeholder)
          elseif vim.fn.executable("curl") ~= 1 then
            notify_once("curl_missing", "slides.nvim: curl is required to download remote images")
            table.insert(output, placeholder)
          else
            table.insert(output, "")
            table.insert(images, { path = path, line = #output, alt = alt, is_url = true })
          end
        else
          local resolved = resolve_local_path(source_path, path)
          if can_render and vim.fn.filereadable(resolved) == 1 then
            table.insert(output, "")
            table.insert(images, { path = resolved, line = #output, alt = alt })
          else
            if can_render and vim.fn.filereadable(resolved) ~= 1 then
              notify_once("missing:" .. resolved, "slides.nvim: image not found: " .. resolved)
            end
            table.insert(output, placeholder)
          end
        end
      end
    end
  end

  return { lines = output, images = images }
end

function M.render(entries, opts)
  if not entries or #entries == 0 then return nil end
  local api = image_api()
  if not api then return nil end
  opts = opts or {}

  render_generation = render_generation + 1
  local gen = render_generation
  local handles = {}
  local row_offset = opts.row_offset or 0
  local base_opts = {
    window = opts.window,
    buffer = opts.buffer,
    inline = true,
    with_virtual_padding = true,
    max_width_window_percentage = opts.max_width_window_percentage,
    max_height_window_percentage = opts.max_height_window_percentage,
  }

  local function render_image(image)
    if not image then
      notify_once("image_render_failed", "slides.nvim: image.nvim failed to load an image")
      return
    end
    if gen ~= render_generation then
      pcall(image.clear, image, true)
      return
    end
    image:render()
    table.insert(handles, image)
  end

  for _, entry in ipairs(entries) do
    local options = vim.tbl_deep_extend("force", base_opts, {
      x = entry.col or 0,
      y = row_offset + entry.line - 1,
    })

    if entry.is_url then
      api.from_url(entry.path, options, function(image)
        render_image(image)
      end)
    else
      render_image(api.from_file(entry.path, options))
    end
  end

  return handles
end

function M.clear(handles)
  render_generation = render_generation + 1
  if not handles then return end
  for _, image in ipairs(handles) do
    pcall(image.clear, image)
  end
end

return M
