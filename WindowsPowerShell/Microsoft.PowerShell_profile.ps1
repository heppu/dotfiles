# ENV config
$ENV:XDG_CONFIG_HOME = "$HOME/.config"
$ENV:STARSHIP_CONFIG = "$HOME/.config/starship/starship.toml"
$ENV:BAT_CONFIG_DIR = "$HOME/.config/bat"
$ENV:EDITOR = "nvim"

# git autocomplete
Import-Module posh-git

# Autocomplete stuff
Import-Module -Name PSReadLine
Import-Module -Name CompletionPredictor
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows

# Starship stuff
Invoke-Expression (&starship init powershell)

# Alias
Set-Alias cat bat
New-Alias g git
New-Alias vi nvim
New-Alias vim nvim

# Start vscode on ALT+C
Set-PSReadlineKeyHandler -Key alt+c -ScriptBlock { code-insiders . }

# Exit on CTRL+D
Set-PSReadlineKeyHandler -Key ctrl+d -Function ViExit
