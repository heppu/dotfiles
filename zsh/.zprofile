export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml

if [[ -z $DISPLAY && $TTY = /dev/tty1 ]]; then
    export SDL_VIDEODRIVER=wayland
    export XDG_SESSION_TYPE=wayland
    export MOZ_ENABLE_WAYLAND=1
    export QT_QPA_PLATFORM=wayland
    export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
    export _JAVA_AWT_WM_NONREPARENTING=1
    export XDG_SCREENSHOTS_DIR=$HOME/Pictures/Screenshots
    export XDG_CURRENT_DESKTOP=sway
    export XDG_CONFIG_HOME=$HOME/.config
    export WLR_DRM_DEVICES=/dev/dri/card1:/dev/dri/card0
    exec dbus-run-session sway
fi
