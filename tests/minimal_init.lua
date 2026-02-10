vim.opt.runtimepath:prepend(vim.fn.getcwd())

local function add_plenary()
  local paths = {}
  if vim.env.PLENARY_PATH and vim.env.PLENARY_PATH ~= "" then
    table.insert(paths, vim.env.PLENARY_PATH)
  end

  local data_dir = vim.fn.stdpath("data")
  table.insert(paths, data_dir .. "/site/pack/packer/start/plenary.nvim")
  table.insert(paths, data_dir .. "/site/pack/lazy/start/plenary.nvim")

  for _, path in ipairs(paths) do
    if vim.loop.fs_stat(path) then
      vim.opt.runtimepath:append(path)
      return
    end
  end

  error("plenary.nvim not found. Set PLENARY_PATH or install plenary.nvim.")
end

add_plenary()
