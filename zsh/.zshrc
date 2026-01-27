# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000000
SAVEHIST=100000000
HISTDUP=erase

bindkey -e
# End of lines configured by zsh-newuser-install

# Push cd in stack automatically
setopt auto_pushd

# Enable extented globbing
setopt EXTENDED_GLOB

# History setup
setopt share_history
setopt appendhistory
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

# Autocomplete setup
zstyle ':completion::complete:*' gain-privileges 1
zstyle ':completion:*' matcher-list 'm:{a-z}={A_Za-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' switch-group '<' '>'
# preview directory's content with eza when completing cd
#zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

#Include completions from user dir
fpath=(~/.config/zsh/site-functions $fpath)

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

# Scroll history with arrow keys
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Bind Ctrl+f to fg command
function _fg() { echo "fg"; fg; zle reset-prompt; zle redisplay}
zle -N _fg
bindkey '^f' _fg

source $ZDOTDIR/plugins/fzf-tab/fzf-tab.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $ZDOTDIR/plugins/dirhistory.plugin.zsh

# fzf integration
eval "$(fzf --zsh)"

# Starship prompt
eval "$(starship init zsh)"

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

# Aliases
alias g='git'
alias k='kubectl'
alias cat='bat'
alias svi='sudo -E vi'
alias kssh='kitten ssh'
alias ls='eza'
alias la='eza -la --octal-permissions'
alias oc='opencode'
