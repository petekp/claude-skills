#!/bin/bash
# Claude HUD State Tracker Hook v4.0.0 (Rust)
#
# Thin wrapper that delegates to the Rust binary for Claude Code hook handling.
# The Rust binary handles all state tracking, lock management, and file activity.
#
# STORAGE:
#   ~/.capacitor/sessions.json        State file (session records)
#   ~/.capacitor/sessions/            Lock directories (liveness detection)
#   ~/.capacitor/ended-sessions/      Tombstones (prevents post-end event races)
#   ~/.capacitor/file-activity.json   File activity tracking
#   ~/.capacitor/hud-hook-heartbeat   Health monitoring (touched on every event)
#   ~/.capacitor/hud-hook-debug.log   Debug log
#
# STATE MACHINE (handled by Rust binary):
#   SessionStart           → ready    (+ creates lock)
#   UserPromptSubmit       → working  (+ creates lock if missing)
#   PreToolUse/PostToolUse → working  (heartbeat)
#   PermissionRequest      → waiting
#   Notification           → ready    (only idle_prompt type)
#   PreCompact             → compacting
#   Stop                   → ready    (unless stop_hook_active=true)
#   SessionEnd             → removes session record
#
# DEBUGGING:
#   tail -f ~/.capacitor/hud-hook-debug.log     # Watch events live
#   cat ~/.capacitor/sessions.json | jq .       # View session states
#   ls ~/.capacitor/sessions/                   # Check active locks

# Skip if this is a summary generation subprocess (prevents recursive hook pollution)
if [ "${HUD_SUMMARY_GEN:-}" = "1" ]; then
  cat > /dev/null
  exit 0
fi

# Try the installed binary location
HUD_HOOK="${HOME}/.local/bin/hud-hook"

# Fallback to checking if it's in PATH (for development)
if [ ! -x "$HUD_HOOK" ]; then
  if command -v hud-hook >/dev/null 2>&1; then
    HUD_HOOK="hud-hook"
  else
    # Binary not found - drain stdin and log error
    cat > /dev/null
    mkdir -p "${HOME}/.capacitor"
    echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") | ERROR: hud-hook binary not found at $HUD_HOOK" >> "${HOME}/.capacitor/hud-hook-debug.log"
    exit 1
  fi
fi

# Execute the Rust binary, passing stdin through
exec "$HUD_HOOK" handle
