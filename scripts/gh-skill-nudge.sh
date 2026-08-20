#!/bin/bash
#
# gh-skill-nudge.sh — PreToolUse/Bash hook.
#
# Fires only on the `gh` invocations that better-github-skill replaces, and
# injects a one-line pointer at the matching script. Raw `gh` for everything
# else is the skill's own advice, so a blanket nudge would fight it.
#
# Nudges once per category per session; a repeat of the same class of command
# stays silent so the reminder does not become wallpaper.
#
# Input:  hook JSON on stdin
# Output: {"hookSpecificOutput": {...}} when it matches, nothing otherwise
# Always exits 0 — a nudge is advice, never a block.

set -uo pipefail

INPUT=$(cat)
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
SESSION=$(printf '%s' "$INPUT" | jq -r '.session_id // "nosession"' 2>/dev/null)

# Not a gh command: leave immediately. The `if` clause in settings.json should
# already have filtered these out, but the hook must stand alone when tested.
case $CMD in
    *gh\ *) ;;
    *) exit 0 ;;
esac

SKILL_DIR="$HOME/.claude/skills/better-github-skill/scripts"
[ -d "$SKILL_DIR" ] || exit 0

STATE_DIR="${TMPDIR:-/tmp}/claude-gh-nudge/$SESSION"

# Print the nudge for a category, but only the first time this session.
nudge_once() {
    category=$1
    message=$2
    mkdir -p "$STATE_DIR" 2>/dev/null || return 0
    marker="$STATE_DIR/$category"
    [ -e "$marker" ] && return 0
    : > "$marker"
    printf '%s' "$message"
}

CONTEXT=""
append() { CONTEXT="${CONTEXT}${CONTEXT:+ }$1"; }

# PR state: `pr view --json <fields>` field-guessing, or a bare `pr checks`.
case $CMD in
    *"gh pr view"*--json*|*"gh pr checks"*)
        append "$(nudge_once snapshot \
            "better-github-skill: \`$SKILL_DIR/pr-snapshot.ts [pr] [-R o/r]\` returns PR meta, mergeability, checks, files, reviews and thread counts in one call.")"
        ;;
esac

# Review conversation: reviewThreads GraphQL, or comment listings.
case $CMD in
    *reviewThreads*|*"gh pr view"*--comments*|*"/pulls/"*comments*)
        append "$(nudge_once threads \
            "better-github-skill: \`$SKILL_DIR/pr-threads.ts [pr] [-R o/r]\` returns review bodies, comments and unresolved inline threads with resolution state, which raw gh cannot get.")"
        ;;
esac

# CI drilldown: run logs, job JSON, or run listings.
case $CMD in
    *"gh run view"*--log*|*"gh run view"*--json*|*"gh run list"*--json*|*"/actions/jobs/"*logs*)
        append "$(nudge_once ci \
            "better-github-skill: \`$SKILL_DIR/ci-failures.ts [run-id] [--pr N]\` returns failing jobs, failed steps and an error-anchored log snippet, and parks full logs on disk. \`--list\` finds the failing run id.")"
        ;;
esac

# SIGPIPE: gh piped into head can die mid-write or truncate silently.
case $CMD in
    *gh\ *\|*head*)
        append "$(nudge_once sigpipe \
            "Piping gh into head can kill gh mid-write or truncate output silently. Redirect to a file and read that, or trim with --jq '.[0:20]'.")"
        ;;
esac

[ -n "$CONTEXT" ] || exit 0

jq -nc --arg ctx "$CONTEXT" \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext: $ctx}}'
