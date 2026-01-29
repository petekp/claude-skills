#!/bin/bash
# Claude HUD State Tracker Hook v3.0.2
# Writes session state to ~/.capacitor/sessions.json
#
# This hook is called by Claude Code on session lifecycle events.
# It receives JSON via stdin containing session info and event details.
#
# Required dependency: jq (brew install jq)
# Optional dependency: python3 (JSON parsing fallback)

set -o pipefail

STATE_FILE="$HOME/.capacitor/sessions.json"
STATE_DIR="$(dirname "$STATE_FILE")"
mkdir -p "$STATE_DIR"
EVENT_LOG_FILE="${HUD_HOOK_LOG_FILE:-$HOME/.capacitor/hud-hook-events.jsonl}"
EVENT_LOG_MAX_BYTES="${HUD_HOOK_LOG_MAX_BYTES:-5242880}"

log_rotate_if_needed() {
    [ -z "$EVENT_LOG_FILE" ] && return
    [ ! -f "$EVENT_LOG_FILE" ] && return
    local size=""
    size=$(stat -f%z "$EVENT_LOG_FILE" 2>/dev/null || stat -c%s "$EVENT_LOG_FILE" 2>/dev/null || echo "0")
    if [ -n "$EVENT_LOG_MAX_BYTES" ] && [ "$size" -gt "$EVENT_LOG_MAX_BYTES" ]; then
        mv "$EVENT_LOG_FILE" "${EVENT_LOG_FILE}.1" 2>/dev/null || true
        : > "$EVENT_LOG_FILE" 2>/dev/null || true
    fi
}

append_event_log() {
    [ -z "$EVENT_LOG_FILE" ] && return
    log_rotate_if_needed

    local log_line=""
    if [ -n "$HAVE_JQ" ]; then
        log_line=$(jq -n \
            --arg ts "$TIMESTAMP" \
            --arg sid "$SESSION_ID" \
            --arg event "$EVENT" \
            --arg action "$ACTION" \
            --arg state "$STATE" \
            --arg cwd "$CWD" \
            --arg project_dir "$PROJECT_DIR" \
            --arg trigger "$TRIGGER" \
            --arg notification_type "$NOTIFICATION_TYPE" \
            --arg stop_hook_active "$STOP_HOOK_ACTIVE" \
            --arg tool_name "$TOOL_NAME" \
            --arg tool_use_id "$TOOL_USE_ID" \
            --arg source "$SOURCE" \
            --arg reason "$REASON" \
            --arg transcript_path "$TRANSCRIPT_PATH" \
            --arg permission_mode "$PERMISSION_MODE" \
            --arg agent_id "$AGENT_ID" \
            --arg agent_transcript_path "$AGENT_TRANSCRIPT_PATH" \
            --arg write_status "$WRITE_STATUS" \
            --arg skip_reason "$SKIP_REASON" \
            --argjson subagent_delta "$SUBAGENT_DELTA" \
            '
            def nonempty($s): ($s|type=="string") and (($s|length) > 0);
            def optstr($s): if nonempty($s) then $s else null end;
            def optbool($s):
              if $s == "true" then true
              elif $s == "false" then false
              else null end;

            {
              ts: $ts,
              session_id: $sid,
              event: $event,
              action: $action,
              state: (if $action == "upsert" then $state else null end),
              cwd: optstr($cwd),
              project_dir: optstr($project_dir),
              trigger: optstr($trigger),
              notification_type: optstr($notification_type),
              stop_hook_active: optbool($stop_hook_active),
              tool_name: optstr($tool_name),
              tool_use_id: optstr($tool_use_id),
              source: optstr($source),
              reason: optstr($reason),
              transcript_path: optstr($transcript_path),
              permission_mode: optstr($permission_mode),
              agent_id: optstr($agent_id),
              agent_transcript_path: optstr($agent_transcript_path),
              subagent_delta: $subagent_delta,
              write_status: optstr($write_status),
              skip_reason: optstr($skip_reason)
            }'
        )
    elif [ -n "$HAVE_PY" ]; then
        log_line=$(TIMESTAMP="$TIMESTAMP" \
            SESSION_ID="$SESSION_ID" \
            EVENT="$EVENT" \
            ACTION="$ACTION" \
            STATE="$STATE" \
            CWD="$CWD" \
            PROJECT_DIR="$PROJECT_DIR" \
            TRIGGER="$TRIGGER" \
            NOTIFICATION_TYPE="$NOTIFICATION_TYPE" \
            STOP_HOOK_ACTIVE="$STOP_HOOK_ACTIVE" \
            TOOL_NAME="$TOOL_NAME" \
            TOOL_USE_ID="$TOOL_USE_ID" \
            SOURCE="$SOURCE" \
            REASON="$REASON" \
            TRANSCRIPT_PATH="$TRANSCRIPT_PATH" \
            PERMISSION_MODE="$PERMISSION_MODE" \
            AGENT_ID="$AGENT_ID" \
            AGENT_TRANSCRIPT_PATH="$AGENT_TRANSCRIPT_PATH" \
            SUBAGENT_DELTA="$SUBAGENT_DELTA" \
            WRITE_STATUS="$WRITE_STATUS" \
            SKIP_REASON="$SKIP_REASON" \
            python3 - <<'PY'
import json
import os
import sys

def optstr(value):
    if isinstance(value, str) and value:
        return value
    return None

def optbool(value):
    if value == "true":
        return True
    if value == "false":
        return False
    return None

ts = os.environ.get("TIMESTAMP", "")
action = os.environ.get("ACTION", "")
state = os.environ.get("STATE", "")

payload = {
    "ts": ts,
    "session_id": os.environ.get("SESSION_ID", ""),
    "event": os.environ.get("EVENT", ""),
    "action": action,
    "state": state if action == "upsert" else None,
    "cwd": optstr(os.environ.get("CWD", "")),
    "project_dir": optstr(os.environ.get("PROJECT_DIR", "")),
    "trigger": optstr(os.environ.get("TRIGGER", "")),
    "notification_type": optstr(os.environ.get("NOTIFICATION_TYPE", "")),
    "stop_hook_active": optbool(os.environ.get("STOP_HOOK_ACTIVE", "")),
    "tool_name": optstr(os.environ.get("TOOL_NAME", "")),
    "tool_use_id": optstr(os.environ.get("TOOL_USE_ID", "")),
    "source": optstr(os.environ.get("SOURCE", "")),
    "reason": optstr(os.environ.get("REASON", "")),
    "transcript_path": optstr(os.environ.get("TRANSCRIPT_PATH", "")),
    "permission_mode": optstr(os.environ.get("PERMISSION_MODE", "")),
    "agent_id": optstr(os.environ.get("AGENT_ID", "")),
    "agent_transcript_path": optstr(os.environ.get("AGENT_TRANSCRIPT_PATH", "")),
    "subagent_delta": int(os.environ.get("SUBAGENT_DELTA", "0") or "0"),
    "write_status": optstr(os.environ.get("WRITE_STATUS", "")),
    "skip_reason": optstr(os.environ.get("SKIP_REASON", "")),
}

sys.stdout.write(json.dumps(payload))
PY
        )
    fi

    [ -z "$log_line" ] && return
    printf '%s\n' "$log_line" >> "$EVENT_LOG_FILE" 2>/dev/null || true
}

# Read JSON from stdin (Claude Code hook format)
INPUT=$(cat)
[ -z "$INPUT" ] && exit 0

HAVE_JQ=""
HAVE_PY=""
command -v jq >/dev/null 2>&1 && HAVE_JQ="1"
command -v python3 >/dev/null 2>&1 && HAVE_PY="1"
[ -z "$HAVE_JQ" ] && [ -z "$HAVE_PY" ] && exit 0

json_get() {
    local jq_expr="$1"
    local py_key="$2"
    if [ -n "$HAVE_JQ" ]; then
        printf '%s' "$INPUT" | jq -r "$jq_expr" 2>/dev/null
        return 0
    fi
    if [ -n "$HAVE_PY" ]; then
        printf '%s' "$INPUT" | python3 -c $'import sys, json\nkey = sys.argv[1]\ntry:\n    data = json.load(sys.stdin)\nexcept Exception:\n    sys.exit(0)\nval = data.get(key, "")\nval = "" if val is None else val\nif isinstance(val, bool):\n    print("true" if val else "false")\nelif isinstance(val, (dict, list)):\n    print(json.dumps(val))\nelse:\n    print(val)' "$py_key"
        return 0
    fi
    echo ""
}

normalize_path() {
    local path="$1"
    if [ -z "$path" ]; then
        echo ""
        return
    fi
    while [ "$path" != "/" ] && [ "${path%/}" != "$path" ]; do
        path="${path%/}"
    done
    if [ -z "$path" ]; then
        echo "/"
    else
        echo "$path"
    fi
}

infer_project_dir_from_transcript_path() {
    local tp="$1"
    [ -z "$tp" ] && echo "" && return

    # Expand ~/ prefix if present
    if [[ "$tp" == "~/"* ]]; then
        tp="${HOME}/${tp#~/}"
    fi

    # Extract the encoded project directory name from:
    #   ~/.claude/projects/<encoded>/<session_id>.jsonl
    local encoded
    encoded=$(echo "$tp" | sed -n 's|.*/\\.claude/projects/\\([^/]*\\)/.*|\\1|p')
    [ -z "$encoded" ] && echo "" && return

    # Claude Code encodes paths by replacing "/" with "-" (lossy but sufficient here).
    # Example: -Users-pete-Code-proj -> /Users/pete/Code/proj
    if [[ "$encoded" == "-"* ]]; then
        local without_leading="${encoded#-}"
        echo "/${without_leading//-/\\/}"
        return
    fi

    echo ""
}

# Parse required fields from JSON
EVENT=$(json_get '.hook_event_name // empty' 'hook_event_name')
SESSION_ID=$(json_get '.session_id // empty' 'session_id')

# cwd may be missing in some events - fallback to PWD, then env var
CWD=$(json_get '.cwd // empty' 'cwd')
CWD="${CWD:-${CLAUDE_PROJECT_DIR:-}}"
CWD="$(normalize_path "$CWD")"

# Parse event-specific fields for conditional state transitions
TRIGGER=$(json_get '.trigger // empty' 'trigger')
NOTIFICATION_TYPE=$(json_get '.notification_type // empty' 'notification_type')
STOP_HOOK_ACTIVE=$(json_get '.stop_hook_active // empty' 'stop_hook_active')
SOURCE=$(json_get '.source // empty' 'source')
REASON=$(json_get '.reason // empty' 'reason')

# Common fields (capture-only; denylist-first: do NOT store prompt/tool IO/message bodies)
PERMISSION_MODE=$(json_get '.permission_mode // empty' 'permission_mode')
TRANSCRIPT_PATH=$(json_get '.transcript_path // empty' 'transcript_path')
TOOL_NAME=$(json_get '.tool_name // empty' 'tool_name')
TOOL_USE_ID=$(json_get '.tool_use_id // empty' 'tool_use_id')

# Best-effort subagent metadata (field names are not guaranteed; captured only if present)
AGENT_ID=$(json_get '.agent_id // empty' 'agent_id')
AGENT_TRANSCRIPT_PATH=$(json_get '.agent_transcript_path // empty' 'agent_transcript_path')

# Project root (if provided by Claude Code env); stored separately from cwd
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-}"
PROJECT_DIR="$(normalize_path "$PROJECT_DIR")"

# If project dir isn't available, try to infer it from the transcript path
if [ -z "$PROJECT_DIR" ] && [ -n "$TRANSCRIPT_PATH" ]; then
    PROJECT_DIR="$(infer_project_dir_from_transcript_path "$TRANSCRIPT_PATH")"
    PROJECT_DIR="$(normalize_path "$PROJECT_DIR")"
fi

# If cwd is still missing, fall back to inferred project_dir (more stable than PWD)
if [ -z "$CWD" ] && [ -n "$PROJECT_DIR" ]; then
    CWD="$PROJECT_DIR"
fi

# Skip if essential data missing
[ -z "$SESSION_ID" ] && exit 0
[ -z "$EVENT" ] && exit 0

# Map hook events to states (v3 canonical mapping; see core/hud-core/src/state/types.rs)
ACTION="touch" # upsert|touch|delete
STATE=""       # only used when ACTION=upsert
SUBAGENT_DELTA=0

case "$EVENT" in
    "SessionStart")
        ACTION="upsert"
        STATE="ready"
        ;;
    "UserPromptSubmit")
        ACTION="upsert"
        STATE="working"
        ;;
    "PreToolUse")
        ACTION="upsert"
        STATE="working"
        # Proxy: a Task tool call spawns a subagent; count is best-effort.
        if [ "$TOOL_NAME" = "Task" ]; then
            SUBAGENT_DELTA=1
        fi
        ;;
    "PostToolUse")
        ACTION="upsert"
        STATE="working"
        # Pair with PreToolUse(Task): when the Task tool completes, the subagent is done.
        if [ "$TOOL_NAME" = "Task" ]; then
            SUBAGENT_DELTA=-1
        fi
        ;;
    "PermissionRequest")
        ACTION="upsert"
        STATE="waiting"
        ;;
    "PreCompact")
        # Both manual and auto compaction should show compacting state.
        ACTION="upsert"
        STATE="compacting"
        ;;
    "Stop")
        # stop_hook_active=true means Claude is already continuing due to a stop hook;
        # do not flicker to Ready in that case.
        if [ "$STOP_HOOK_ACTIVE" = "true" ]; then
            ACTION="touch"
        else
            ACTION="upsert"
            STATE="ready"
        fi
        ;;
    "Notification")
        if [ "$NOTIFICATION_TYPE" = "idle_prompt" ]; then
            ACTION="upsert"
            STATE="ready"
        elif [ "$NOTIFICATION_TYPE" = "permission_prompt" ] || [ "$NOTIFICATION_TYPE" = "elicitation_dialog" ]; then
            ACTION="upsert"
            STATE="waiting"
        else
            # Capture notification metadata but don't change state
            ACTION="touch"
        fi
        ;;
    "SubagentStop")
        # Capture metadata; state impact can be added later.
        ACTION="touch"
        SUBAGENT_DELTA=0
        ;;
    "SessionEnd")
        # Remove session entry instead of setting state
        ACTION="delete"
        ;;
    *)
        # Unknown event - capture metadata only
        ACTION="touch"
        ;;
esac

# Some events (e.g. Stop with stop_hook_active=true) may omit cwd.
# Only require cwd when we'd otherwise create a new session record via ACTION=upsert.
if [ -z "$CWD" ] && [ "$ACTION" = "upsert" ]; then
    # If we already have a record for this session_id, allow the upsert to proceed
    # (jq/python writers will keep existing cwd). Otherwise, skip to avoid creating
    # a record with an empty cwd.
    if [ -f "$STATE_FILE" ]; then
        if [ -n "$HAVE_JQ" ]; then
            EXISTS=$(jq -r --arg sid "$SESSION_ID" '.sessions[$sid] != null' "$STATE_FILE" 2>/dev/null || echo "false")
        else
            EXISTS=$(python3 - "$STATE_FILE" "$SESSION_ID" <<'PY'
import json, sys
path, sid = sys.argv[1], sys.argv[2]
try:
    with open(path, "r", encoding="utf-8") as fh:
        data = json.load(fh)
    sessions = data.get("sessions", {}) if isinstance(data, dict) else {}
    print("true" if isinstance(sessions, dict) and sid in sessions else "false")
except Exception:
    print("false")
PY
)
        fi
        if [ "$EXISTS" != "true" ]; then
            SKIP_REASON="missing_cwd_no_record"
            WRITE_STATUS="skipped"
            TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
            append_event_log
            exit 0
        fi
    else
        SKIP_REASON="missing_cwd_no_state_file"
        WRITE_STATUS="skipped"
        TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        append_event_log
        exit 0
    fi
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
WRITE_STATUS="skipped"
SKIP_REASON=""

# Initialize or reset state file (no backward compatibility; enforce v3)
if [ ! -f "$STATE_FILE" ]; then
    echo '{"version":3,"sessions":{}}' > "$STATE_FILE"
else
    if [ -n "$HAVE_JQ" ]; then
        V=$(jq -r '.version // 0' "$STATE_FILE" 2>/dev/null || echo "0")
    else
        V=$(python3 - "$STATE_FILE" <<'PY'
import json, sys
path = sys.argv[1]
try:
    with open(path, "r", encoding="utf-8") as fh:
        data = json.load(fh)
    v = data.get("version", 0) if isinstance(data, dict) else 0
    print(v)
except Exception:
    print(0)
PY
)
    fi
    if [ "$V" != "3" ]; then
        echo '{"version":3,"sessions":{}}' > "$STATE_FILE"
    fi
fi

# Serialize updates under an optional file lock to avoid clobbering
LOCK_FD=""
LOCK_FILE="${STATE_FILE}.lock"
if command -v flock >/dev/null 2>&1; then
    exec 9>"$LOCK_FILE"
    if flock -x 9; then
        LOCK_FD="9"
    fi
fi

TEMP_FILE="$(mktemp "${STATE_FILE}.tmp.XXXXXX")"
cleanup() {
    [ -n "$LOCK_FD" ] && flock -u "$LOCK_FD" 2>/dev/null || true
    [ -f "$TEMP_FILE" ] && rm -f "$TEMP_FILE"
}
trap cleanup EXIT

write_with_jq() {
    jq --arg sid "$SESSION_ID" \
       --arg cwd "$CWD" \
       --arg state "$STATE" \
       --arg ts "$TIMESTAMP" \
       --arg action "$ACTION" \
       --arg event "$EVENT" \
       --arg trigger "$TRIGGER" \
       --arg notification_type "$NOTIFICATION_TYPE" \
       --arg stop_hook_active "$STOP_HOOK_ACTIVE" \
       --arg tool_name "$TOOL_NAME" \
       --arg tool_use_id "$TOOL_USE_ID" \
       --arg source "$SOURCE" \
       --arg reason "$REASON" \
       --arg transcript_path "$TRANSCRIPT_PATH" \
       --arg permission_mode "$PERMISSION_MODE" \
       --arg project_dir "$PROJECT_DIR" \
       --arg agent_id "$AGENT_ID" \
       --arg agent_transcript_path "$AGENT_TRANSCRIPT_PATH" \
       --argjson subagent_delta "$SUBAGENT_DELTA" \
       '
        def nonempty($s): ($s|type=="string") and (($s|length) > 0);
        def optstr($s): if nonempty($s) then $s else null end;
        def optbool($s):
          if $s == "true" then true
          elif $s == "false" then false
          else null end;

        .version = 3
        | .sessions = (.sessions // {})
        | if $action == "delete" then
            del(.sessions[$sid])
          else
            (.sessions[$sid] // {}) as $prev
            | ($prev.state // "ready") as $current_state
            | ($prev.state_changed_at // $ts) as $current_sca
            | ($prev.active_subagent_count // 0) as $current_subs
            | (if $action == "upsert" then $state else $current_state end) as $new_state
            | (if $action == "upsert"
                then (if $current_state == $state then $current_sca else $ts end)
                else $current_sca
              end) as $new_sca
            | ((($current_subs + $subagent_delta) | floor) | if . < 0 then 0 else . end) as $new_subs
            | .sessions[$sid] = (
                $prev
                + {
                    session_id: $sid,
                    cwd: (if nonempty($cwd) then $cwd else ($prev.cwd // "") end),
                    state: $new_state,
                    updated_at: $ts,
                    state_changed_at: $new_sca,
                    active_subagent_count: $new_subs,
                    last_event: {
                      hook_event_name: $event,
                      at: $ts,
                      tool_name: optstr($tool_name),
                      tool_use_id: optstr($tool_use_id),
                      notification_type: optstr($notification_type),
                      trigger: optstr($trigger),
                      source: optstr($source),
                      reason: optstr($reason),
                      stop_hook_active: optbool($stop_hook_active),
                      agent_id: optstr($agent_id),
                      agent_transcript_path: optstr($agent_transcript_path)
                    }
                  }
                + (if nonempty($transcript_path) then {transcript_path: $transcript_path} else {} end)
                + (if nonempty($permission_mode) then {permission_mode: $permission_mode} else {} end)
                + (if nonempty($project_dir) then {project_dir: $project_dir} else {} end)
              )
          end
       ' \
       "$STATE_FILE" > "$TEMP_FILE" 2>/dev/null
    return $?
}

write_with_python() {
    python3 - \
      "$STATE_FILE" \
      "$TEMP_FILE" \
      "$SESSION_ID" \
      "$CWD" \
      "$STATE" \
      "$TIMESTAMP" \
      "$ACTION" \
      "$EVENT" \
      "$TRIGGER" \
      "$NOTIFICATION_TYPE" \
      "$STOP_HOOK_ACTIVE" \
      "$TOOL_NAME" \
      "$TOOL_USE_ID" \
      "$SOURCE" \
      "$REASON" \
      "$TRANSCRIPT_PATH" \
      "$PERMISSION_MODE" \
      "$PROJECT_DIR" \
      "$AGENT_ID" \
      "$AGENT_TRANSCRIPT_PATH" \
      "$SUBAGENT_DELTA" <<'PY'
import json
import sys

(
    state_file,
    temp_file,
    sid,
    cwd,
    state,
    ts,
    action,
    event,
    trigger,
    notification_type,
    stop_hook_active,
    tool_name,
    tool_use_id,
    source,
    reason,
    transcript_path,
    permission_mode,
    project_dir,
    agent_id,
    agent_transcript_path,
    subagent_delta,
) = sys.argv[1:22]

def nonempty(s: str) -> bool:
    return isinstance(s, str) and len(s) > 0

def optstr(s: str):
    return s if nonempty(s) else None

def optbool(s: str):
    if s == "true":
        return True
    if s == "false":
        return False
    return None

try:
    subagent_delta_int = int(subagent_delta)
except Exception:
    subagent_delta_int = 0

data = {"version": 3, "sessions": {}}
try:
    with open(state_file, "r", encoding="utf-8") as fh:
        loaded = json.load(fh)
        if isinstance(loaded, dict) and loaded.get("version") == 3:
            data.update(loaded)
except Exception:
    pass

sessions = data.get("sessions")
if not isinstance(sessions, dict):
    sessions = {}
data["sessions"] = sessions

if action == "delete":
    sessions.pop(sid, None)
else:
    existing = sessions.get(sid)
    if not isinstance(existing, dict):
        existing = {}

    current_state = existing.get("state", "ready")
    current_sca = existing.get("state_changed_at", ts)
    try:
        current_subs = int(existing.get("active_subagent_count", 0))
    except Exception:
        current_subs = 0

    if action == "upsert":
        new_state = state
        new_sca = current_sca if current_state == state else ts
    else:
        new_state = current_state
        new_sca = current_sca

    new_subs = current_subs + subagent_delta_int
    if new_subs < 0:
        new_subs = 0

    if nonempty(cwd):
        existing["cwd"] = cwd

    existing.update(
        {
            "session_id": sid,
            "state": new_state,
            "updated_at": ts,
            "state_changed_at": new_sca,
            "active_subagent_count": new_subs,
            "last_event": {
                "hook_event_name": event,
                "at": ts,
                "tool_name": optstr(tool_name),
                "tool_use_id": optstr(tool_use_id),
                "notification_type": optstr(notification_type),
                "trigger": optstr(trigger),
                "source": optstr(source),
                "reason": optstr(reason),
                "stop_hook_active": optbool(stop_hook_active),
                "agent_id": optstr(agent_id),
                "agent_transcript_path": optstr(agent_transcript_path),
            },
        }
    )

    if nonempty(transcript_path):
        existing["transcript_path"] = transcript_path
    if nonempty(permission_mode):
        existing["permission_mode"] = permission_mode
    if nonempty(project_dir):
        existing["project_dir"] = project_dir

    sessions[sid] = existing

data["version"] = 3

with open(temp_file, "w", encoding="utf-8") as fh:
    json.dump(data, fh, indent=2)
PY
}

if [ -n "$HAVE_JQ" ]; then
    if ! write_with_jq; then
        if [ -n "$HAVE_PY" ]; then
            if write_with_python; then
                WRITE_STATUS="ok"
            else
                WRITE_STATUS="failed"
            fi
        else
            WRITE_STATUS="failed"
        fi
    else
        WRITE_STATUS="ok"
    fi
else
    if write_with_python; then
        WRITE_STATUS="ok"
    else
        WRITE_STATUS="failed"
    fi
fi

if [ "$WRITE_STATUS" = "ok" ]; then
    mv "$TEMP_FILE" "$STATE_FILE" 2>/dev/null || true
fi

append_event_log
