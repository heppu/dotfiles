#!/bin/bash

pkgs=$(xbps-install -nuM | awk '{print $1}')
pkg_count=$(echo $pkgs | wc -w)
pkg_list=$(echo $pkgs | sed 's/ /\\r/g')

echo "{\"text\":\"$pkg_count\", \"tooltip\":\"$pkg_list\"}"
