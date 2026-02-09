-- plugin/slides.lua
-- Auto-loaded by Neovim. Registers the :Slides user command.

vim.api.nvim_create_user_command("Slides", function()
  require("slides").toggle()
end, { desc = "Toggle slide presentation mode" })
