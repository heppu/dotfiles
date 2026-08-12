#!/bin/sh

set -- /sys/class/net/*/wireless
dev=$(basename "${1%/wireless}")

if iwctl device "$dev" show | grep -q 'Powered.*on'; then
    iwctl device "$dev" set-property Powered off
else
    iwctl device "$dev" set-property Powered on
fi
