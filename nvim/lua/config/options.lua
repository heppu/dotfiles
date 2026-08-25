-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Follow system dark/light toggle (theme-toggle.sh sets 'background' over RPC);
-- registered here instead of autocmds.lua so it exists before VeryLazy
vim.api.nvim_create_autocmd("OptionSet", {
  pattern = "background",
  nested = true, -- lazy.nvim loads colorscheme plugins via its own autocmd
  callback = function()
    vim.cmd.colorscheme(vim.o.background == "light" and "onenord-light" or "nordic")
  end,
})
