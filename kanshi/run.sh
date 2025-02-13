#!/bin/sh
set +x

# Wait until XDG_RUNTIME_DIR is set
while [ -z "$XDG_RUNTIME_DIR" ] || [ -z "$WAYLAND_DISPLAY" ]; do
  sleep 1
done

kanshi -c ~/.config/kanshi/$(hostname)
