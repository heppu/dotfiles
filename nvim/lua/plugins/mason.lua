return {
  -- Alpine (musl) workarounds for Mason: skip packages with no musl build.
  -- lua-language-server is pinned to 3.15.0 (manually installed); do NOT
  -- run :MasonUpdate on it — newer releases dropped musl tarballs.
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      opts.ensure_installed = vim.tbl_filter(function(name)
        return name ~= "codelldb"
      end, opts.ensure_installed)
    end,
  },
}
