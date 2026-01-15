#!/bin/bash

# Hook Testing Script
# Tests all hook event handlers with sample payloads to verify correct behavior

set -euo pipefail

HOOK_SCRIPT="$HOME/.claude/scripts/hud-state-tracker.sh"
STATE_FILE="$HOME/.claude/hud-session-states-v2.json"
TEST_SESSION_ID="test-$(date +%s)"
TEST_CWD="/tmp/test-project"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=== Hook Testing Suite ==="
echo "Testing hook script: $HOOK_SCRIPT"
echo "State file: $STATE_FILE"
echo "Test session ID: $TEST_SESSION_ID"
echo ""

# Backup state file
if [ -f "$STATE_FILE" ]; then
  cp "$STATE_FILE" "${STATE_FILE}.backup-$(date +%s)"
  echo "✓ Backed up existing state file"
fi

test_count=0
pass_count=0
fail_count=0

run_test() {
  local test_name="$1"
  local event_json="$2"
  local expected_state="$3"

  test_count=$((test_count + 1))
  echo -n "Test $test_count: $test_name... "

  # Send event to hook
  echo "$event_json" | bash "$HOOK_SCRIPT" 2>/dev/null

  # Check resulting state
  if [ "$expected_state" = "REMOVED" ]; then
    # Session should be removed from state file
    actual_state=$(jq -r --arg sid "$TEST_SESSION_ID" '.sessions[$sid] // "null"' "$STATE_FILE" 2>/dev/null)
    if [ "$actual_state" = "null" ]; then
      echo -e "${GREEN}PASS${NC}"
      pass_count=$((pass_count + 1))
      return 0
    else
      echo -e "${RED}FAIL${NC} (expected session removed, got: $actual_state)"
      fail_count=$((fail_count + 1))
      return 1
    fi
  else
    actual_state=$(jq -r --arg sid "$TEST_SESSION_ID" '.sessions[$sid].state // "null"' "$STATE_FILE" 2>/dev/null)
    if [ "$actual_state" = "$expected_state" ]; then
      echo -e "${GREEN}PASS${NC}"
      pass_count=$((pass_count + 1))
      return 0
    else
      echo -e "${RED}FAIL${NC} (expected: $expected_state, got: $actual_state)"
      fail_count=$((fail_count + 1))
      return 1
    fi
  fi
}

# Test 1: SessionStart
run_test "SessionStart creates ready state" \
  '{"hook_event_name":"SessionStart","session_id":"'$TEST_SESSION_ID'","cwd":"'$TEST_CWD'","transcript_path":"~/.claude/test.jsonl"}' \
  "ready"

# Test 2: UserPromptSubmit
run_test "UserPromptSubmit transitions to working" \
  '{"hook_event_name":"UserPromptSubmit","session_id":"'$TEST_SESSION_ID'","cwd":"'$TEST_CWD'","transcript_path":"~/.claude/test.jsonl"}' \
  "working"

# Test 3: PermissionRequest
run_test "PermissionRequest transitions to blocked" \
  '{"hook_event_name":"PermissionRequest","session_id":"'$TEST_SESSION_ID'","cwd":"'$TEST_CWD'"}' \
  "blocked"

# Test 4: PostToolUse (from blocked to working)
run_test "PostToolUse (blocked->working)" \
  '{"hook_event_name":"PostToolUse","session_id":"'$TEST_SESSION_ID'","cwd":"'$TEST_CWD'"}' \
  "working"

# Test 5: Stop
run_test "Stop transitions to ready" \
  '{"hook_event_name":"Stop","session_id":"'$TEST_SESSION_ID'","cwd":"'$TEST_CWD'","stop_hook_active":false}' \
  "ready"

# Test 6: PreCompact (manual)
run_test "PreCompact (manual) transitions to compacting" \
  '{"hook_event_name":"PreCompact","session_id":"'$TEST_SESSION_ID'","cwd":"'$TEST_CWD'","trigger":"manual"}' \
  "compacting"

# Test 7: PreCompact (auto)
run_test "PreCompact (auto) transitions to compacting" \
  '{"hook_event_name":"PreCompact","session_id":"'$TEST_SESSION_ID'","cwd":"'$TEST_CWD'","trigger":"auto"}' \
  "compacting"

# Test 8: PreCompact (no trigger field)
run_test "PreCompact (no trigger) transitions to compacting" \
  '{"hook_event_name":"PreCompact","session_id":"'$TEST_SESSION_ID'","cwd":"'$TEST_CWD'"}' \
  "compacting"

# Test 9: PostToolUse (compacting->working)
run_test "PostToolUse (compacting->working)" \
  '{"hook_event_name":"PostToolUse","session_id":"'$TEST_SESSION_ID'","cwd":"'$TEST_CWD'"}' \
  "working"

# Test 10: Notification (idle_prompt)
run_test "Notification (idle_prompt) transitions to ready" \
  '{"hook_event_name":"Notification","session_id":"'$TEST_SESSION_ID'","cwd":"'$TEST_CWD'","notification_type":"idle_prompt"}' \
  "ready"

# Test 11: SessionEnd
run_test "SessionEnd removes session" \
  '{"hook_event_name":"SessionEnd","session_id":"'$TEST_SESSION_ID'","cwd":"'$TEST_CWD'"}' \
  "REMOVED"

# Summary
echo ""
echo "=== Test Results ==="
echo "Total: $test_count"
echo -e "Passed: ${GREEN}$pass_count${NC}"
echo -e "Failed: ${RED}$fail_count${NC}"

if [ $fail_count -eq 0 ]; then
  echo -e "\n${GREEN}✓ All tests passed!${NC}"
  exit 0
else
  echo -e "\n${RED}✗ Some tests failed${NC}"
  exit 1
fi
