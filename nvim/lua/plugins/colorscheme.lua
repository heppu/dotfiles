-- Initial mode comes from the system dark/light state (~/.config/waybar/custom/theme-toggle.sh)
local function system_background()
  local f = io.open(vim.fn.expand("~/.config/kitty/colors/current.conf"))
  if not f then
    return "dark"
  end
  local s = f:read("*a")
  f:close()
  return s:find("light") and "light" or "dark"
end

return {
  -- { "folke/tokyonight.nvim", lazy = true,opts = { style = "storm" }},
  -- { "jacoborus/tender.vim" },
  -- { "tomasiser/vim-code-dark" },
  { "rmehri01/onenord.nvim", lazy = true },
  { "AlexvZyl/nordic.nvim" },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        vim.o.background = system_background()
        vim.cmd.colorscheme(vim.o.background == "light" and "onenord-light" or "nordic")
      end,
    },
  },
}
