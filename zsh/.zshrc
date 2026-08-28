# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000000
SAVEHIST=100000000

bindkey -e
# End of lines configured by zsh-newuser-install

# Push cd in stack automatically
setopt auto_pushd

# Enable extented globbing
setopt EXTENDED_GLOB

# History setup
setopt share_history
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups
setopt hist_ignore_space
setopt extended_history

# Autocomplete setup
zstyle ':completion::complete:*' gain-privileges 1
zstyle ':completion:*' matcher-list 'm:{a-z}={A_Za-Z}'
# No dircolors on Alpine, so define LS_COLORS by hand
export LS_COLORS='di=1;34:ln=1;36:so=1;35:pi=33:ex=1;32:bd=1;33:cd=1;33:or=1;31:mi=2;37:su=37;41:sg=30;43:tw=30;42:ow=1;34:st=37;44'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' switch-group '<' '>'

#Include completions from user dir + zsh-completions package
fpath=(~/.config/zsh/site-functions /usr/share/zsh/plugins/zsh-completions/src $fpath)

# Config files
export BAT_CONFIG_DIR=$HOME/.config/bat
export RIPGREP_CONFIG_PATH=$HOME/.config/ripgrep/ripgreprc

# Go stuff
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN
zstyle ':completion:*:mage:*' hash-fast true

# Rust stuff
source $HOME/.cargo/env

# Zig
export PATH=$HOME/.zvm/bin:$PATH

# Makefile autocomplete
zstyle ':completion:*:make:*:targets' call-command true
zstyle ':completion:*:*:make:*' tag-order 'targets'

# User binaries
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.opencode/bin:$PATH

autoload -Uz compinit promptinit bashcompinit select-word-style
compinit
promptinit
bashcompinit
# Breaks word at slashes
select-word-style bash

# Enable Ctrl+arrow key bindings for word jumping
bindkey '^[[1;5C' forward-word     # Ctrl+right arrow
bindkey '^[[1;5D' backward-word    # Ctrl+left arrow

# Bind Ctrl+f to fg command
function _fg() { echo "fg"; fg; zle reset-prompt; zle redisplay}
zle -N _fg
bindkey '^f' _fg

source $ZDOTDIR/plugins/fzf-tab/fzf-tab.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
# Without this autosuggestions rebinds widgets every prompt and ends up
# wrapping (and blanking) the reverse search list below
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# Live reverse search list while typing, down/up arrows select from it.
# Must come after autosuggestions, it chains onto its widgets.
source $ZDOTDIR/plugins/auto-reverse-search.zsh
source $ZDOTDIR/plugins/dirhistory.plugin.zsh

# fzf integration
eval "$(fzf --zsh)"

# Starship prompt
eval "$(starship init zsh)"

# Taskfile autocomplete
eval "$(task --completion zsh)"

# Node version manager
if [[ $(ldd /bin/ls 2>/dev/null | grep -c musl) -gt 0 ]]; then
  export FNM_NODE_DIST_MIRROR=https://unofficial-builds.nodejs.org/download/release
  export FNM_ARCH=x64-musl
fi
eval "$(fnm env --shell zsh --use-on-cd)"


unlock-keyring() {
  local pass
  read -rs "?Password: " pass
  print -n -- "$pass" | gnome-keyring-daemon --replace --unlock | source /dev/stdin
  unset pass
}

claude-pro() {
    CLAUDE_CONFIG_DIR=~/.claude-pro claude "$@"
}

# Aliases
alias g='git'
alias k='kubectl'
alias cat='bat'
alias svi='sudo -E vi'
alias kssh='kitten ssh'
alias ls='eza'
alias la='eza -la --octal-permissions'

# git worktree
gwt() {
  # Usage: gwt <branch> [base]
  #   gwt feat-foo              -> new branch feat-foo from HEAD
  #   gwt feat-foo origin/master -> new branch from given base
  local branch="$1"
  local base="${2:-HEAD}"
  if [[ -z "$branch" ]]; then
    echo "usage: gwt <branch> [base]" >&2
    return 1
  fi
  # Resolve repo root and derive sibling worktree path
  local root
  root=$(git rev-parse --show-toplevel) || return 1
  local repo_name=${root:t}                  # basename
  local parent=${root:h}                     # dirname
  local wt_path="$parent/${repo_name}-${branch//\//-}"
  git worktree add -b "$branch" "$wt_path" "$base" || return 1
  cd "$wt_path"
}

# Google Cloud SDK
export CLOUDSDK_PYTHON=/usr/bin/python3  # pin musl-safe python (bundled glibc python breaks on Alpine)
if [ -f '/home/heppu/google-cloud-sdk/path.zsh.inc' ]; then . '/home/heppu/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/home/heppu/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/heppu/google-cloud-sdk/completion.zsh.inc'; fi

# Must be sourced last, after everything that adds widgets
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
