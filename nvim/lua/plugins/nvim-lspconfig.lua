return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        golangci_lint_ls = {
          cmd = { "golangci-lint-langserver" },
          filetypes = { "go", "gomod" },
          root_dir = require("lspconfig.util").root_pattern("go.mod", ".git"),
          init_options = {
            command = {
              vim.fn.expand("~/go/bin/golangci-lint"),
              "run",
              "--output.json.path",
              "stdout",
              "--show-stats=false",
              "--issues-exit-code=1",
            },
          },
          on_attach = function(client, bufnr)
            require("workspace-diagnostics").populate_workspace_diagnostics(client, bufnr)
          end,
        },
      },
    },
  },
}
