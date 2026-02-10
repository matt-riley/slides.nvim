local MiniTest = require("mini.test")
local T = MiniTest.new_set()

local images = require("slides.images")

local function setup_temp_paths()
  local dir = vim.fn.tempname()
  local img_dir = dir .. "/assets"
  vim.fn.mkdir(img_dir, "p")

  local doc = dir .. "/slides.md"
  local img = img_dir .. "/pic.png"
  vim.fn.writefile({ "# Slides" }, doc)
  vim.fn.writefile({ "img" }, img)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, doc)
  return buf, img
end

local prepare_set = MiniTest.new_set()

prepare_set["resolves local paths when rendering"] = function()
  local buf, img = setup_temp_paths()

  local prepared = images.prepare({ "![Alt](assets/pic.png)" }, buf, { download_remote = true }, true)

  MiniTest.expect.equality(prepared.lines, { "" })
  MiniTest.expect.equality(#prepared.images, 1)
  MiniTest.expect.equality(prepared.images[1].path, vim.fn.fnamemodify(img, ":p"))
end

prepare_set["uses placeholder when rendering disabled"] = function()
  local buf = setup_temp_paths()

  local prepared = images.prepare({ "![Alt](assets/pic.png)" }, buf, { download_remote = true }, false)

  MiniTest.expect.equality(prepared.lines, { "[image: Alt]" })
  MiniTest.expect.equality(#prepared.images, 0)
end

prepare_set["leaves non-image lines alone"] = function()
  local buf = vim.api.nvim_create_buf(false, true)

  local prepared = images.prepare({ "Hello world" }, buf, { download_remote = true }, true)

  MiniTest.expect.equality(prepared.lines, { "Hello world" })
  MiniTest.expect.equality(#prepared.images, 0)
end

T["images.prepare"] = prepare_set

return T
