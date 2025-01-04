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

# Share history between open terminals
setopt share_history

# Show history search automatically without Ctrl+R
#zstyle ':autocomplete:*' default-context history-incremental-search-backward
#zstyle ':autocomplete:history-incremental-search-backward:*' min-input 1
#source $ZDOTDIR/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh


#Include completions from user dir
fpath=(~/.config/zsh/site-functions $fpath)

# Go stuff
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN
zstyle ':completion:*:mage:*' hash-fast true

# Node stuff
export N_PREFIX=$HOME/.n
export PATH=$N_PREFIX/bin:$PATH

# User binaries
export PATH=$HOME/.local/bin:$PATH

autoload -Uz compinit promptinit bashcompinit select-word-style
compinit
promptinit
bashcompinit
# Breaks word at slashes
select-word-style bash

# Allow completion for sudo
zstyle ':completion::complete:*' gain-privileges 1

# Enable Ctrl+arrow key bindings for word jumping
bindkey '^[[1;5C' forward-word     # Ctrl+right arrow
bindkey '^[[1;5D' backward-word    # Ctrl+left arrow

# Scroll history with arrow keys
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down


# Bind Ctrl+f to fg command
function _fg() { echo "fg"; fg; zle reset-prompt; zle redisplay}
zle -N _fg
bindkey '^f' _fg 

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source $ZDOTDIR/plugins/dirhistory.plugin.zsh

# Starship prompt
eval "$(starship init zsh)"

# Node version manager
eval "$(fnm env --use-on-cd)"

# Aliases
alias cat='bat -p --theme=base16-256' 
alias svi='sudo -E vi'
alias kssh='kitten ssh'
