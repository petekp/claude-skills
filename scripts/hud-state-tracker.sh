#!/bin/bash
# Claude HUD State Tracker Hook v2.0.0
# Writes session state to ~/.capacitor/sessions.json
#
# This hook is called by Claude Code on session lifecycle events.
# It receives JSON via stdin containing session info and event details.
#
# Required dependency: jq (brew install jq)

set -e

STATE_FILE="$HOME/.capacitor/sessions.json"
mkdir -p "$(dirname "$STATE_FILE")"

# Read JSON from stdin (Claude Code hook format)
INPUT=$(cat)

# Parse required fields from JSON
EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

# cwd may be missing in some events - fallback to env var
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
CWD="${CWD:-$CLAUDE_PROJECT_DIR}"

# Parse event-specific fields for conditional state transitions
TRIGGER=$(echo "$INPUT" | jq -r '.trigger // empty')
NOTIFICATION_TYPE=$(echo "$INPUT" | jq -r '.notification_type // empty')

# Skip if essential data missing
[ -z "$SESSION_ID" ] && exit 0
[ -z "$CWD" ] && exit 0
[ -z "$EVENT" ] && exit 0

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Map hook events to states per transition.rs
case "$EVENT" in
    "SessionStart")
        STATE="ready"
        ;;
    "UserPromptSubmit")
        STATE="working"
        ;;
    "PreToolUse")
        STATE="working"
        ;;
    "PostToolUse")
        STATE="working"
        ;;
    "PermissionRequest")
        STATE="blocked"
        ;;
    "PreCompact")
        # Only auto-triggered compaction shows compacting state
        if [ "$TRIGGER" = "auto" ]; then
            STATE="compacting"
        else
            # Manual compaction - maintain current state
            exit 0
        fi
        ;;
    "Stop")
        STATE="ready"
        ;;
    "Notification")
        # Only idle_prompt notification resets to ready
        if [ "$NOTIFICATION_TYPE" = "idle_prompt" ]; then
            STATE="ready"
        else
            exit 0
        fi
        ;;
    "SessionEnd")
        # Remove session entry instead of setting state
        STATE=""
        ;;
    *)
        # Unknown event - skip
        exit 0
        ;;
esac

# Initialize state file if missing
if [ ! -f "$STATE_FILE" ]; then
    echo '{"version":2,"sessions":{}}' > "$STATE_FILE"
fi

# Update state file atomically
TEMP_FILE=$(mktemp)

if [ -z "$STATE" ]; then
    # SessionEnd: Delete the session entry
    jq --arg sid "$SESSION_ID" \
       'del(.sessions[$sid])' \
       "$STATE_FILE" > "$TEMP_FILE" 2>/dev/null || echo '{"version":2,"sessions":{}}' > "$TEMP_FILE"
else
    # All other events: Update or create session
    jq --arg sid "$SESSION_ID" \
       --arg path "$CWD" \
       --arg state "$STATE" \
       --arg ts "$TIMESTAMP" \
       '.version = 2 | .sessions[$sid] = {session_id: $sid, cwd: $path, state: $state, updated_at: $ts}' \
       "$STATE_FILE" > "$TEMP_FILE" 2>/dev/null || echo '{"version":2,"sessions":{}}' > "$TEMP_FILE"
fi

mv "$TEMP_FILE" "$STATE_FILE"
