-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

config.hide_tab_bar_if_only_one_tab = true

-- Colors taken from
-- https://github.com/AlexvZyl/nordic.nvim/blob/2e060bda700365af5ce936bec6bb2b8ff2daeb19/platforms/wezterm/nordic.toml
config.colors = {
	foreground = "#D8DEE9",
	background = "#242933",
	cursor_bg = "#D8DEE9",
	cursor_border = "#D8DEE9",
	cursor_fg = "#242933",
	selection_fg = "#D8DEE9",
	selection_bg = "#2E3440",
	ansi = { "#191D24", "#BF616A", "#A3BE8C", "#EBCB8B", "#81A1C1", "#B48EAD", "#8FBCBB", "#D8DEE9" },
	brights = { "#3B4252", "#D06F79", "#B1D196", "#F0D399", "#88C0D0", "#C895BF", "#93CCDC", "#E5E9F0" },
}
config.font = wezterm.font("DejaVuSansM Nerd Font Mono")
config.font_size = 11
config.window_decorations = "RESIZE"

-- Default shell
config.default_domain = "WSL:archlinux"

-- and finally, return the configuration to wezterm
return config
