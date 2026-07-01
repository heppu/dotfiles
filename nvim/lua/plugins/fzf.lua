return {
  "ibhagwan/fzf-lua",
  opts = {
    files = { hidden = true, no_ignore = true },
    grep = {
      hidden = true,
      no_ignore = true,
      rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -g '!.git' -e",
    },
  },
}
