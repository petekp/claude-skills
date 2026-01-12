#!/bin/bash

logfile="/tmp/say-ready-debug.log"
echo "$(date '+%H:%M:%S') - Hook triggered" >> "$logfile"

input=$(cat)
echo "$(date '+%H:%M:%S') - Input received: $input" >> "$logfile"

stop_hook_active=$(echo "$input" | jq -r '.stop_hook_active // false')

if [ "$stop_hook_active" = "true" ]; then
  echo "$(date '+%H:%M:%S') - Exiting: stop_hook_active=true" >> "$logfile"
  exit 0
fi

lockfile="/tmp/say-ready-$(basename "$PWD" | tr -cs '[:alnum:]' '-').lock"
now=$(date +%s)

if [ -f "$lockfile" ]; then
  last=$(cat "$lockfile")
  if [ $((now - last)) -lt 10 ]; then
    echo "$(date '+%H:%M:%S') - Exiting: within 10s cooldown" >> "$logfile"
    exit 0
  fi
fi

echo "$now" > "$lockfile"

project_name=$(basename "$PWD" | tr -cs '[:alnum:]' ' ')
echo "$(date '+%H:%M:%S') - About to say: $project_name ready" >> "$logfile"
say -r 250 "$project_name ready"
echo "$(date '+%H:%M:%S') - Done" >> "$logfile"
