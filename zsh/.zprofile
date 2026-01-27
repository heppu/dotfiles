# Alpine only
command -v openrc >/dev/null 2>&1 && openrc -U

export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml

if [[ -z $DISPLAY && $TTY = /dev/tty1 ]]; then
    export SDL_VIDEODRIVER=wayland
    export XDG_SESSION_TYPE=wayland
    export MOZ_ENABLE_WAYLAND=1
    export QT_QPA_PLATFORM=wayland-egl
    export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
    export QT_WAYLAND_FORCE_DPI=physical
    export _JAVA_AWT_WM_NONREPARENTING=1
    export XDG_SCREENSHOTS_DIR=$HOME/Pictures/Screenshots
    export XDG_CURRENT_DESKTOP=sway
    export XDG_CONFIG_HOME=$HOME/.config
    exec dbus-run-session sway
fi

# Start a dbus session for SSH / TTY logins
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ] && [ -n "$SSH_CONNECTION" ]; then
    exec dbus-run-session "$SHELL"
fi
