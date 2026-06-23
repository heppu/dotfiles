return {
  "folke/snacks.nvim",
  opts = {
    scroll = { enabled = true },
    image = { enabled = true },
    styles = {
      terminal = {
        keys = {
          term_normal = {
            "<esc>",
            function()
              vim.cmd("stopinsert")
            end,
            mode = "t",
            desc = "Exit terminal mode",
          },
        },
      },
    },
  },
}
