#!/bin/bash

# Claude HUD State Tracker
# Tracks session state for all Claude Code projects in a centralized file
# Handles: SessionStart, UserPromptSubmit, PermissionRequest, PostToolUse, Stop, SessionEnd, PreCompact

# Skip if this is a summary generation subprocess (prevents recursive hook pollution)
if [ "$HUD_SUMMARY_GEN" = "1" ]; then
  cat > /dev/null  # consume stdin
  exit 0
fi

STATE_FILE="$HOME/.claude/hud-session-states.json"
LOG_FILE="$HOME/.claude/hud-hook-debug.log"

input=$(cat)

# Log every hook call
echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") | $(echo "$input" | jq -c '{event: .hook_event_name, cwd: .cwd, stop_hook_active: .stop_hook_active}')" >> "$LOG_FILE"

event=$(echo "$input" | jq -r '.hook_event_name // empty')
cwd=$(echo "$input" | jq -r '.cwd // empty')
session_id=$(echo "$input" | jq -r '.session_id // empty')
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')
stop_hook_active=$(echo "$input" | jq -r '.stop_hook_active // false')
source=$(echo "$input" | jq -r '.source // empty')
trigger=$(echo "$input" | jq -r '.trigger // empty')

if [ "$event" = "Stop" ] && [ "$stop_hook_active" = "true" ]; then
  exit 0
fi

if [ -z "$cwd" ] || [ -z "$event" ]; then
  exit 0
fi

# Ensure jq is available
if ! command -v jq &>/dev/null; then
  echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") | ERROR: jq not found" >> "$LOG_FILE"
  exit 0
fi

# Initialize or repair state file if missing or corrupted
if [ ! -f "$STATE_FILE" ] || ! jq -e . "$STATE_FILE" &>/dev/null; then
  echo '{"version":1,"projects":{}}' > "$STATE_FILE"
  echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") | Initialized/repaired state file" >> "$LOG_FILE"
fi

case "$event" in
  "SessionStart")
    new_state="ready"
    ;;
  "UserPromptSubmit")
    new_state="working"

    # Spawn background lock holder for reliable session detection
    # This holds a flock while Claude is running, auto-releases on exit/crash
    LOCK_DIR="$HOME/.claude/sessions"
    mkdir -p "$LOCK_DIR"

    # Use md5 hash of cwd as lock file name
    if command -v md5 &>/dev/null; then
      LOCK_HASH=$(echo -n "$cwd" | md5)
    elif command -v md5sum &>/dev/null; then
      LOCK_HASH=$(echo -n "$cwd" | md5sum | cut -d' ' -f1)
    else
      # Fallback: simple hash using cksum
      LOCK_HASH=$(echo -n "$cwd" | cksum | cut -d' ' -f1)
    fi
    LOCK_FILE="$LOCK_DIR/${LOCK_HASH}.lock"
    CLAUDE_PID=$PPID

    # Spawn lock holder in background using mkdir-based locking (works on macOS)
    # mkdir is atomic - only one process can create a directory
    (
      # Try to create lock directory (atomic operation)
      if ! mkdir "$LOCK_FILE" 2>/dev/null; then
        # Lock exists - check if the holding process is still alive
        if [ -f "$LOCK_FILE/pid" ]; then
          OLD_PID=$(cat "$LOCK_FILE/pid" 2>/dev/null)
          if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
            # Process still running - exit
            exit 0
          fi
          # Stale lock - remove and retry
          rm -rf "$LOCK_FILE"
          if ! mkdir "$LOCK_FILE" 2>/dev/null; then
            exit 0  # Another process grabbed it
          fi
        else
          exit 0  # Lock dir exists but no pid file - race condition, exit
        fi
      fi

      # We got the lock - write metadata
      echo "$CLAUDE_PID" > "$LOCK_FILE/pid"
      echo "{\"pid\": $CLAUDE_PID, \"started\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\", \"path\": \"$cwd\"}" > "$LOCK_FILE/meta.json"

      # Hold lock while Claude runs - check every second
      while kill -0 $CLAUDE_PID 2>/dev/null; do
        sleep 1
      done

      # Claude exited - release lock
      rm -rf "$LOCK_FILE"
    ) &
    disown 2>/dev/null
    echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") | Lock holder spawned for $cwd (PID $CLAUDE_PID)" >> "$LOG_FILE"
    ;;
  "PermissionRequest")
    # Stay in current state - permissions happen during active work
    # Don't want to flicker between working/waiting
    exit 0
    ;;
  "PostToolUse")
    # Check if we're coming out of compacting - tool use means work resumed
    current_state=$(jq -r --arg cwd "$cwd" '.projects[$cwd].state // "idle"' "$STATE_FILE" 2>/dev/null)
    if [ "$current_state" = "compacting" ]; then
      new_state="working"
      # Flag to trigger publish after updating state
      should_publish=true
    elif [ "$current_state" = "working" ]; then
      # Update heartbeat timestamp and ensure thinking=true during active work
      timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
      tmp_file=$(mktemp)
      jq --arg cwd "$cwd" \
         --arg ts "$timestamp" \
         '.projects[$cwd].context.updated_at = $ts | .projects[$cwd].thinking = true | .projects[$cwd].thinking_updated_at = $ts' "$STATE_FILE" > "$tmp_file" && mv "$tmp_file" "$STATE_FILE"
      exit 0
    else
      exit 0
    fi
    ;;
  "Notification")
    # idle_prompt means Claude is waiting for user input (handles interrupt case)
    notification_type=$(echo "$input" | jq -r '.notification_type // empty')
    if [ "$notification_type" = "idle_prompt" ]; then
      new_state="ready"
    else
      exit 0
    fi
    ;;
  "Stop")
    new_state="ready"
    ;;
  "SessionEnd")
    # Set to idle when session ends - this is the correct final state
    # Even though it fires after Stop, "idle" is correct when Claude is closed
    new_state="idle"
    ;;
  "PreCompact")
    if [ "$trigger" = "auto" ]; then
      new_state="compacting"
    else
      exit 0
    fi
    ;;
  *)
    exit 0
    ;;
esac

timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

update_state() {
  local tmp_file
  tmp_file=$(mktemp)

  # Determine thinking state based on new_state
  local thinking_val="false"
  if [ "$new_state" = "working" ]; then
    thinking_val="true"
  fi

  if [ "$new_state" = "idle" ]; then
    jq --arg cwd "$cwd" \
       --arg state "$new_state" \
       --arg ts "$timestamp" \
       '.projects[$cwd] = {
         state: $state,
         state_changed_at: $ts,
         session_id: null,
         working_on: null,
         next_step: null,
         thinking: false,
         thinking_updated_at: $ts
       }' "$STATE_FILE" > "$tmp_file" && mv "$tmp_file" "$STATE_FILE"
  else
    # Update state, thinking, and context.updated_at for fresh heartbeat
    jq --arg cwd "$cwd" \
       --arg state "$new_state" \
       --arg session "$session_id" \
       --arg ts "$timestamp" \
       --argjson thinking "$thinking_val" \
       '.projects[$cwd] = ((.projects[$cwd] // {}) + {
         state: $state,
         state_changed_at: $ts,
         session_id: $session,
         thinking: $thinking,
         thinking_updated_at: $ts
       }) | .projects[$cwd].context.updated_at = $ts' "$STATE_FILE" > "$tmp_file" && mv "$tmp_file" "$STATE_FILE"
  fi
}

update_state

# Publish state if transitioning from compacting → working
if [ "$should_publish" = "true" ]; then
  "$HOME/.claude/hooks/publish-state.sh" &>/dev/null &
  disown 2>/dev/null
fi

if [ "$event" = "Stop" ] && [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  (
    context=$(tail -100 "$transcript_path" | grep -E '"type":"(user|assistant)"' | tail -20)

    if [ -z "$context" ]; then
      exit 0
    fi

    claude_cmd=$(command -v claude || echo "/opt/homebrew/bin/claude")

    # Run from $HOME with HUD_SUMMARY_GEN=1 to prevent recursive hook triggers
    # The hook will skip processing when this env var is set
    response=$(cd "$HOME" && HUD_SUMMARY_GEN=1 "$claude_cmd" -p \
      --no-session-persistence \
      --output-format json \
      --model haiku \
      "Extract from this coding session context. Return ONLY valid JSON, no markdown: {\"working_on\": \"brief description\", \"next_step\": \"what to do next\"}. Context: $context" 2>/dev/null)

    if ! echo "$response" | jq -e . >/dev/null 2>&1; then
      exit 0
    fi

    result=$(echo "$response" | jq -r '.result // empty')

    working_on=$(echo "$result" | jq -r '.working_on // empty' 2>/dev/null)
    next_step=$(echo "$result" | jq -r '.next_step // empty' 2>/dev/null)

    if [ -z "$working_on" ]; then
      working_on=$(echo "$result" | sed -n 's/.*"working_on"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
      next_step=$(echo "$result" | sed -n 's/.*"next_step"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
    fi

    if [ -n "$working_on" ]; then
      tmp_file=$(mktemp)
      jq --arg cwd "$cwd" \
         --arg working_on "$working_on" \
         --arg next_step "${next_step:-}" \
         '.projects[$cwd].working_on = $working_on | .projects[$cwd].next_step = $next_step' \
         "$STATE_FILE" > "$tmp_file" && mv "$tmp_file" "$STATE_FILE"
    fi
  ) &>/dev/null &
  disown 2>/dev/null
fi

exit 0
