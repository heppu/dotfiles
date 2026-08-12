#!/bin/sh

pkgs=$(apk list -u 2>/dev/null | awk '{print $1}')
pkg_count=$(echo $pkgs | wc -w)
pkg_list=$(echo $pkgs | sed 's/ /\\r/g')

echo "{\"text\":\"$pkg_count\", \"tooltip\":\"$pkg_list\"}"
