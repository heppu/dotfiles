# posh stuff
oh-my-posh init pwsh | Invoke-Expression
Import-Module posh-git

# Alias
New-Alias g git
New-Alias vi nvim
New-Alias vim nvim

# Exit on CTRL+D
Set-PSReadlineKeyHandler -Key ctrl+d -Function ViExit
