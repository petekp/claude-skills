#!/bin/bash
# HUD Relay State Publisher
# Uses debounce pattern: waits for state to stabilize before publishing
#
# Configuration via ~/.claude/hud-relay.json

DEBUG_LOG="$HOME/.claude/hud-publish-debug.log"
DEBOUNCE_FILE="$HOME/.claude/hud-publish-pending"
STATUS_FILE="$HOME/.claude/hud-session-states.json"
PINNED_FILE="$HOME/.claude/hud.json"

log_debug() {
    echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") | $1" >> "$DEBUG_LOG"
}

# Read config
CONFIG_FILE="$HOME/.claude/hud-relay.json"
if [ -f "$CONFIG_FILE" ]; then
    HUD_RELAY_URL=$(jq -r '.relayUrl // empty' "$CONFIG_FILE")
    HUD_DEVICE_ID=$(jq -r '.deviceId // empty' "$CONFIG_FILE")
    HUD_SECRET_KEY=$(jq -r '.secretKey // empty' "$CONFIG_FILE")
fi

if [ -z "$HUD_DEVICE_ID" ] || [ -z "$HUD_SECRET_KEY" ]; then
    exit 0
fi

# Ensure jq is available
if ! command -v jq &>/dev/null; then
    log_debug "ERROR: jq not found"
    exit 0
fi

# Consume stdin
cat > /dev/null

# Generate unique ID for this invocation
INVOCATION_ID="$$-$(od -An -N4 -tu4 /dev/urandom | tr -d ' ')"
echo "$INVOCATION_ID" > "$DEBOUNCE_FILE"

# Debounce: wait for state to stabilize, then check if we're still the most recent
sleep 0.4

# If another invocation started after us, let it handle the publish
if [ -f "$DEBOUNCE_FILE" ]; then
    PENDING_ID=$(cat "$DEBOUNCE_FILE" 2>/dev/null)
    if [ "$PENDING_ID" != "$INVOCATION_ID" ]; then
        exit 0
    fi
fi

# We're the most recent - proceed with publish

if [ ! -f "$STATUS_FILE" ]; then
    rm -f "$DEBOUNCE_FILE"
    exit 0
fi

# Get pinned project paths
PINNED_PATHS=""
if [ -f "$PINNED_FILE" ]; then
    PINNED_PATHS=$(jq -r '.pinned_projects[]' "$PINNED_FILE" 2>/dev/null)
fi

# Build aggregated state
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
PROJECTS_JSON="{}"

for PROJECT_PATH in $PINNED_PATHS; do
    if [ -z "$PROJECT_PATH" ]; then continue; fi

    PROJECT_STATUS=$(jq --arg prefix "$PROJECT_PATH" '
        .projects | to_entries
        | map(select(.key | startswith($prefix)))
        | map(select(.value.state | . and . != "null"))
        | sort_by(.value.state_changed_at)
        | last
        | .value // null
    ' "$STATUS_FILE" 2>/dev/null)

    if [ "$PROJECT_STATUS" != "null" ] && [ -n "$PROJECT_STATUS" ]; then
        STATE=$(echo "$PROJECT_STATUS" | jq -r '.state // "idle"')
        WORKING_ON=$(echo "$PROJECT_STATUS" | jq -r '.working_on // empty')
        NEXT_STEP=$(echo "$PROJECT_STATUS" | jq -r '.next_step // empty')

        PROJECTS_JSON=$(echo "$PROJECTS_JSON" | jq \
            --arg path "$PROJECT_PATH" \
            --arg state "$STATE" \
            --arg workingOn "$WORKING_ON" \
            --arg nextStep "$NEXT_STEP" \
            --arg ts "$TIMESTAMP" \
            '. + {($path): {
                state: $state,
                workingOn: (if $workingOn == "" then null else $workingOn end),
                nextStep: (if $nextStep == "" then null else $nextStep end),
                lastUpdated: $ts
            }}')

        log_debug "Publish $PROJECT_PATH: $STATE"
    fi
done

# Build and send payload
STATE_JSON=$(jq -n \
    --argjson projects "$PROJECTS_JSON" \
    --arg updatedAt "$TIMESTAMP" \
    '{projects: $projects, updatedAt: $updatedAt}')

NONCE=$(openssl rand -base64 24)
CIPHERTEXT=$(echo "$STATE_JSON" | base64)

ENCRYPTED_MSG=$(jq -n \
    --arg nonce "$NONCE" \
    --arg ciphertext "$CIPHERTEXT" \
    '{nonce: $nonce, ciphertext: $ciphertext}')

/usr/bin/curl -4 -s -X POST \
    -H "Content-Type: application/json" \
    -d "$ENCRYPTED_MSG" \
    "${HUD_RELAY_URL}/api/v1/state/${HUD_DEVICE_ID}" \
    --max-time 5 \
    >> "$DEBUG_LOG" 2>&1

rm -f "$DEBOUNCE_FILE"
exit 0
