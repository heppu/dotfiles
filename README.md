# Dotfiles

My dotfiles for various programs in wayland environment.

## Installation

To backup old configs and install new ones run the following command:
```sh
mv .config old_config && git clone https://github.com/heppu/dotfiles.git .config
echo "ZDOTDIR=~/.config/zsh" >> ~/.zshenv
```

## Adding new configs
To avoid adding anything sensitive all files are gitignored by default.
To add a new config files into the repository add the exclude rule into .gitignore file.
