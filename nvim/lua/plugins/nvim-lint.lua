return {
  "mfussenegger/nvim-lint",
  opts = function(_, opts)
    require("lint").linters.golangcilint.cmd = vim.fn.expand("~/go/bin/golangci-lint")
    return opts
  end,
}
