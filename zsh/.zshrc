# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000000
SAVEHIST=100000000
bindkey -e
# End of lines configured by zsh-newuser-install

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

# Code server
export PATH=$HOME/.local/bin:$PATH

autoload -Uz compinit promptinit
compinit
promptinit

# Allow completion for sudo
zstyle ':completion::complete:*' gain-privileges 1

# Enable Ctrl+arrow key bindings for word jumping
bindkey '^[[1;5C' forward-word     # Ctrl+right arrow
bindkey '^[[1;5D' backward-word    # Ctrl+left arrow

# Scroll history with arrow keys
bindkey '\e[A' history-beginning-search-backward
bindkey '\e[B' history-beginning-search-forward

# Bind Ctrl+f to fg command
function _fg() { echo "fg"; fg; zle reset-prompt; zle redisplay}
zle -N _fg
bindkey '^f' _fg 

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# Starship prompt
eval "$(starship init zsh)"

# Node version manager
eval "$(fnm env --use-on-cd)"

autoload bashcompinit

# Aliases
alias cat='bat -p --theme=base16-256' 
alias svi='sudo -E vi'
