#!/bin/bash

# Claude HUD Status Generator
# Generates project status at end of each Claude session

input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd // empty')
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
stop_hook_active=$(echo "$input" | jq -r '.stop_hook_active // false')

if [ "$stop_hook_active" = "true" ]; then
  echo '{"ok": true}'
  exit 0
fi

if [ -z "$cwd" ] || [ -z "$transcript_path" ] || [ ! -f "$transcript_path" ]; then
  echo '{"ok": true}'
  exit 0
fi

echo '{"ok": true}'

(
  mkdir -p "$cwd/.claude"
  context=$(tail -100 "$transcript_path" | grep -E '"type":"(user|assistant)"' | tail -20)

  if [ -z "$context" ]; then
    exit 0
  fi

  claude_cmd=$(command -v claude || echo "/opt/homebrew/bin/claude")

  response=$("$claude_cmd" -p \
    --no-session-persistence \
    --output-format json \
    --model haiku \
    "Summarize this coding session as JSON with fields: working_on (string), next_step (string), status (in_progress/blocked/needs_review/paused/done), blocker (string or null). Context: $context" 2>/dev/null)

  if ! echo "$response" | jq -e . >/dev/null 2>&1; then
    exit 0
  fi

  result_text=$(echo "$response" | jq -r '.result // empty')
  if [ -z "$result_text" ]; then
    exit 0
  fi

  status=$(echo "$result_text" | jq -e . 2>/dev/null)
  if [ -z "$status" ] || [ "$status" = "null" ]; then
    status=$(echo "$result_text" | sed -n '/^```json/,/^```$/p' | sed '1d;$d' | jq -e . 2>/dev/null)
  fi
  if [ -z "$status" ] || [ "$status" = "null" ]; then
    status=$(echo "$result_text" | sed -n '/^```/,/^```$/p' | sed '1d;$d' | jq -e . 2>/dev/null)
  fi
  if [ -z "$status" ] || [ "$status" = "null" ]; then
    exit 0
  fi

  status=$(echo "$status" | jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '. + {updated_at: $ts}')
  echo "$status" > "$cwd/.claude/hud-status.json"
) &>/dev/null &

disown 2>/dev/null
exit 0
