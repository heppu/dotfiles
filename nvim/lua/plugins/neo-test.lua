return {
  "nvim-neotest/neotest",
  optional = true,
  dependencies = {
    "fredrikaverpil/neotest-golang",
    "leoluz/nvim-dap-go",
  },
  opts = {
    adapters = {
      ["neotest-golang"] = {
        dap_go_enabled = true, -- requires leoluz/nvim-dap-go
        runner = "gotestsum",
        go_test_args = {
          "-v",
          "-race",
          "-tags=integratio,applicationtest",
          -- "-coverprofile=" .. vim.fn.getcwd() .. "/coverage.out",
        },
      },
    },
  },
}
