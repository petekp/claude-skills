#!/bin/bash
input=$(cat)
stop_hook_active=$(echo "$input" | jq -r '.stop_hook_active // false')

if [ "$stop_hook_active" = "true" ]; then
  exit 0
fi

lockfile="/tmp/say-ready-$(basename "$PWD" | tr -cs '[:alnum:]' '-').lock"
now=$(date +%s)

if [ -f "$lockfile" ]; then
  last=$(cat "$lockfile")
  if [ $((now - last)) -lt 10 ]; then
    exit 0
  fi
fi

echo "$now" > "$lockfile"

project_name=$(basename "$PWD" | tr -cs '[:alnum:]' ' ')
say -r 250 "$project_name ready"
