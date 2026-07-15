#!/bin/sh
kanshictl reload 2>/dev/null && exit 0
exec kanshi -c ~/.config/kanshi/"$(hostname)"
