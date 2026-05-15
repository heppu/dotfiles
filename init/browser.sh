#!/bin/sh
# Install a workspace-aware Firefox launcher for Sway.
#
# Behavior: when a URL is opened (via xdg-open / $BROWSER), if the focused
# Sway workspace already has a Firefox window, focus it and reuse it. Else
# open a new Firefox window on the current workspace.
#
# Idempotent — safe to re-run.

set -eu

bin="$HOME/.local/bin/browser"
desktop="$HOME/.local/share/applications/browser.desktop"

mkdir -p "$(dirname "$bin")" "$(dirname "$desktop")"

cat > "$bin" <<'EOF'
#!/bin/sh
# Open URLs in Firefox on the currently focused Sway workspace.

ws=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused) | .name')

ff_id=$(swaymsg -t get_tree | jq -r --arg ws "$ws" '
    [.. | objects | select(.type? == "workspace" and .name == $ws)][0]
    | [.. | objects | select(.app_id? == "firefox")][0]
    | .id // empty
')

if [ -n "$ff_id" ]; then
    swaymsg "[con_id=$ff_id] focus" >/dev/null
    exec firefox "$@"
else
    exec firefox --new-window "$@"
fi
EOF
chmod +x "$bin"

cat > "$desktop" <<EOF
[Desktop Entry]
Name=Firefox (workspace-aware)
Exec=$bin %u
Type=Application
Terminal=false
StartupNotify=true
Icon=firefox
MimeType=x-scheme-handler/unknown;x-scheme-handler/about;text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;application/x-xpinstall;application/pdf;application/json;
EOF

command -v update-desktop-database >/dev/null && \
    update-desktop-database "$(dirname "$desktop")" >/dev/null 2>&1 || true

xdg-mime default browser.desktop \
    x-scheme-handler/http \
    x-scheme-handler/https \
    x-scheme-handler/about \
    x-scheme-handler/unknown \
    text/html

xdg-settings set default-web-browser browser.desktop >/dev/null 2>&1 || true

echo "Installed $bin and registered $desktop as default browser."
