#!/bin/sh
# usage: zfs-status.sh [pool] -- no arg = all pools joined

WARN_CAP=80
CRIT_CAP=90
SCRUB_ICON="󰑐"

pool="$1"

if [ -n "$pool" ]; then
	info=$(zpool list -H -o name,health,capacity "$pool" 2>/dev/null)
else
	info=$(zpool list -H -o name,health,capacity 2>/dev/null)
fi

if [ -z "$info" ]; then
	echo "{\"text\":\"?\", \"class\":\"critical\", \"tooltip\":\"no pool ${pool:-found}\"}"
	exit 0
fi

rank=0
text=""
tip=""

bump() {
	[ "$1" -gt "$rank" ] && rank="$1"
	return 0
}

while IFS='	' read -r name health cap; do
	st=$(zpool status "$name" 2>&1)
	mark=""
	suffix=""

	case "$health" in
		ONLINE) ;;
		DEGRADED | OFFLINE) mark="!"; bump 2 ;;
		*) mark="!!"; bump 2 ;;
	esac

	pct=${cap%\%}
	case "$pct" in '' | *[!0-9]*) pct=0 ;; esac
	if [ "$pct" -ge "$CRIT_CAP" ]; then
		bump 2
	elif [ "$pct" -ge "$WARN_CAP" ]; then
		bump 1
	fi

	# health stays ONLINE through cksum errors, so check the counts too
	if printf '%s\n' "$st" | grep -q '^errors:[[:space:]]*Permanent'; then
		suffix="${suffix} E"
		bump 2
	elif printf '%s\n' "$st" | awk '
		NF >= 5 && $2 ~ /^(ONLINE|DEGRADED|FAULTED|OFFLINE|UNAVAIL|REMOVED)$/ &&
		($3 != "0" || $4 != "0" || $5 != "0") { found = 1 }
		END { exit !found }'; then
		suffix="${suffix} E"
		bump 1
	fi

	printf '%s\n' "$st" | grep -q 'in progress' && suffix="${suffix} ${SCRUB_ICON}"

	text="${text}${text:+/}${mark}${cap}${suffix}"
	tip="${tip}${tip:+
}${st}"
done <<EOF
$info
EOF

case "$rank" in
	2) class="critical" ;;
	1) class="warning" ;;
	*) class="good" ;;
esac

# tooltip is pango markup inside JSON: escape markup, then the raw tabs zpool emits
tooltip=$(printf '%s' "$tip" | sed \
	-e 's/\\/\\\\/g' \
	-e 's/&/\&amp;/g' \
	-e 's/</\&lt;/g' \
	-e 's/"/\\"/g' \
	-e 's/\t/\\t/g' \
	| sed ':a;N;$!ba;s/\n/\\n/g')

echo "{\"text\":\"$text\", \"class\":\"$class\", \"tooltip\":\"$tooltip\"}"
