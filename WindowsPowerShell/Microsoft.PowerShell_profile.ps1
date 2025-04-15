# ENV config
$ENV:XDG_CONFIG_HOME = "$HOME/.config"
$ENV:STARSHIP_CONFIG = "$HOME/.config/starship/starship.toml"

# git autocomplete
Import-Module posh-git

# Starship stuff
Invoke-Expression (&starship init powershell)

# Alias
New-Alias g git
New-Alias vi nvim
New-Alias vim nvim

# Start vscode on ALT+C
Set-PSReadlineKeyHandler -Key alt+c -ScriptBlock { code-insiders . }

# Exit on CTRL+D
Set-PSReadlineKeyHandler -Key ctrl+d -Function ViExit
