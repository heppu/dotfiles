#!/bin/sh
# System-wide dark/light switch: gsettings (chromium/GTK via portal), kitty, waybar.
# No args: print current mode icon for waybar. "toggle": switch mode.

CFG="$HOME/.config"

mode() {
	[ "$(gsettings get org.gnome.desktop.interface color-scheme)" = "'prefer-light'" ] && echo light || echo dark
}

apply() {
	if [ "$1" = light ]; then
		gsettings set org.gnome.desktop.interface color-scheme prefer-light
		gsettings set org.gnome.desktop.interface gtk-theme Adwaita
		echo "include light/light.conf" >"$CFG/kitty/colors/current.conf"
		cp "$CFG/waybar/colors-light.css" "$CFG/waybar/colors.css"
	else
		gsettings set org.gnome.desktop.interface color-scheme prefer-dark
		gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark
		echo "include nordic/nordic.conf" >"$CFG/kitty/colors/current.conf"
		cp "$CFG/waybar/colors-dark.css" "$CFG/waybar/colors.css"
	fi
	pkill -USR1 -x kitty
	for s in "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"/nvim.*.0; do
		[ -e "$s" ] && nvim --server "$s" --remote-expr "execute('set background=$1')" >/dev/null 2>&1 &
	done
	# reload_style_on_change picks up colors.css, RTMIN+8 refreshes the icon
	# never SIGUSR2 waybar from here: reloading from inside the click handler deadlocks it
	touch "$CFG/waybar/style.css"
	pkill "-RTMIN+8" -x waybar
}

case "$1" in
toggle)
	# detach so waybar's click handler returns instantly, else it deadlocks
	setsid "$0" do-toggle >/dev/null 2>&1 &
	;;
do-toggle)
	[ "$(mode)" = dark ] && apply light || apply dark
	;;
*)
	[ "$(mode)" = dark ] && echo "󰖔" || echo "󰖨"
	;;
esac
