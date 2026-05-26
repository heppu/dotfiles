#!/bin/sh
# Automatically enable passthrough mode when a focused window matches one of
# the configured rules and is fullscreen. Restores default mode otherwise.
#
# Rules are app_id regex + optional title regex. Empty title regex matches any.

# app_id_regex<TAB>title_regex
RULES=$(printf '%s\n' \
    '^(firefox|chromium|chrome-.*)$	NanoKVM' \
    '^org\.remmina\.Remmina$	' \
)

CURRENT_MODE="default"

set_mode() {
    if [ "$CURRENT_MODE" != "$1" ]; then
        swaymsg mode "$1"
        CURRENT_MODE="$1"
    fi
}

check_focused_window() {
    focused=$(swaymsg -t get_tree | jq -r '
        recurse(.nodes[], .floating_nodes[])
        | select(.focused == true)
        | "\(.app_id // "")\t\(.name // "")\t\(.fullscreen_mode // 0)"
    ')
    [ -z "$focused" ] && { echo "default"; return; }

    IFS="$(printf '\t')" read -r app_id name fullscreen <<EOF
$focused
EOF

    [ "$fullscreen" = "1" ] || { echo "default"; return; }

    echo "$RULES" | while IFS="$(printf '\t')" read -r app_re title_re; do
        [ -z "$app_re" ] && continue
        echo "$app_id" | grep -qiE "$app_re" || continue
        if [ -n "$title_re" ]; then
            echo "$name" | grep -qE "$title_re" || continue
        fi
        echo "passthrough"
        return
    done | grep -q passthrough && echo "passthrough" || echo "default"
}

mode=$(check_focused_window)
[ "$mode" = "passthrough" ] && set_mode "passthrough"

swaymsg -t subscribe '["window"]' -m | while read -r event; do
    change=$(echo "$event" | jq -r '.change')
    case "$change" in
        focus|fullscreen_mode|close)
            set_mode "$(check_focused_window)"
            ;;
    esac
done
