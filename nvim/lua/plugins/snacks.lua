return {
  "folke/snacks.nvim",
  opts = {
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
