return {
  -- Treesitter: add templ parser
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "templ" },
    },
  },

  -- LSP: add templ language server
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        templ = {},
      },
    },
  },

  -- Formatter: use templ fmt
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        templ = { "templ" },
      },
    },
  },
}
