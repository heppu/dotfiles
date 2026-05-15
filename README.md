# Dotfiles

My dotfiles for various programs in wayland environment and in Win11.

## Installation

Backup old configs and install new ones by running:
```sh
mv ~/.config ~/old_config
cd $HOME
git clone https://github.com/heppu/dotfiles.git .config
```
### ZSH

To make zsh use .config dir run:
```sh
echo "ZDOTDIR=~/.config/zsh" >> ~/.zshenv
```

### PowerShell

To make powershell use .config dir run:
```powershell
New-Item -Path ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 -ItemType SymbolicLink -Value $HOME\.config\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
```

### Workspace-aware browser (Sway)

Routes URL opens to a Firefox window on the currently focused workspace
instead of pulling you to whichever workspace last had Firefox focus. If no
Firefox window is on the current workspace, a new one is opened there.

Requires `sway`, `firefox`, `jq`, and `xdg-utils`. Run:
```sh
~/.config/init/browser.sh
```

## Adding new configs
To avoid adding anything sensitive all files are gitignored by default.
To add a new config files into the repository add the exclude rule into .gitignore file.
