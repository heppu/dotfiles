#!/bin/sh
# Automatically enable passthrough mode when a KVM window (NanoKVM in Firefox)
# is focused and fullscreen. Restores default mode otherwise.

MATCH_TITLE="NanoKVM"
MATCH_APP_ID="Firefox"
CURRENT_MODE="default"

set_mode() {
    if [ "$CURRENT_MODE" != "$1" ]; then
        swaymsg mode "$1"
        CURRENT_MODE="$1"
    fi
}

check_focused_window() {
    swaymsg -t get_tree | jq -r '
        recurse(.nodes[], .floating_nodes[])
        | select(.focused == true)
        | "\(.app_id // "")\t\(.name // "")\t\(.fullscreen_mode // 0)"
    ' | while IFS="$(printf '\t')" read -r app_id name fullscreen; do
        if [ "$app_id" = "$MATCH_APP_ID" ] \
            && echo "$name" | grep -q "$MATCH_TITLE" \
            && [ "$fullscreen" = "1" ]; then
            echo "passthrough"
        else
            echo "default"
        fi
    done
}

# Check on startup in case KVM is already focused and fullscreen
mode=$(check_focused_window)
[ "$mode" = "passthrough" ] && set_mode "passthrough"

# Listen for window events (focus, fullscreen, close, etc.)
swaymsg -t subscribe '["window"]' -m | while read -r event; do
    change=$(echo "$event" | jq -r '.change')
    case "$change" in
        focus|fullscreen_mode|close)
            mode=$(check_focused_window)
            if [ "$mode" = "passthrough" ]; then
                set_mode "passthrough"
            else
                set_mode "default"
            fi
            ;;
    esac
done
