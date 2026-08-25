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

# Live type-ahead history search: new command lines start in ctrl-r mode
source $ZDOTDIR/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
zstyle ':autocomplete:*' min-input 1
zstyle ':autocomplete:*' default-context history-incremental-search-backward
# Tab: force a fresh normal completion, ignoring the history-search context/listing
.autocomplete-tab__completion-widget() {
  unset curcontext
  local +h curcontext=complete-word:::
  local +h -a comppostfuncs=( .autocomplete__complete-word__post "$comppostfuncs[@]" )
  compstate[old_list]=
  autocomplete:_main_complete:new
  [[ $_lastcomp[nmatches] -gt 0 && -n $compstate[insert] ]]
}
zle -C autocomplete-tab menu-select .autocomplete-tab__completion-widget
bindkey '^I' autocomplete-tab
# Tab/Shift-Tab cycle options inside the menu
bindkey -M menuselect '^I' menu-complete
bindkey -M menuselect "$terminfo[kcbt]" reverse-menu-complete

# Autocomplete setup
zstyle ':completion::complete:*' gain-privileges 1
# No dircolors on Alpine, so define LS_COLORS by hand
export LS_COLORS='di=1;34:ln=1;36:so=1;35:pi=33:ex=1;32:bd=1;33:cd=1;33:or=1;31:mi=2;37:su=37;41:sg=30;43:tw=30;42:ow=1;34:st=37;44'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" 'ma=30;42'
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format $'%{\e[1;33m%}[%d]%{\e[0m%}'

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

# compinit is run by zsh-autocomplete
autoload -Uz bashcompinit select-word-style
bashcompinit
# Breaks word at slashes
select-word-style bash

# Enable Ctrl+arrow key bindings for word jumping
bindkey '^[[1;5C' forward-word     # Ctrl+right arrow
bindkey '^[[1;5D' backward-word    # Ctrl+left arrow

# Arrow keys: zsh-autocomplete uses up for history menu, down for listing

# Bind Ctrl+f to fg command
function _fg() { echo "fg"; fg; zle reset-prompt; zle redisplay}
zle -N _fg
bindkey '^f' _fg

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_IGNORE_WIDGETS+=(autocomplete-tab)
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

# Aliases
alias g='git'
alias k='kubectl'
alias cat='bat'
alias kssh='kitten ssh'
alias ls='eza'
alias la='eza -la --octal-permissions'

# Google Cloud SDK
export CLOUDSDK_PYTHON=/usr/bin/python3  # pin musl-safe python (bundled glibc python breaks on Alpine)
if [ -f '/home/heppu/google-cloud-sdk/path.zsh.inc' ]; then . '/home/heppu/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/home/heppu/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/heppu/google-cloud-sdk/completion.zsh.inc'; fi

# Must be sourced last, after everything that adds widgets
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
