#!/bin/bash
# Gather git repository state for bootstrap prompt
# Outputs structured information about current git state

set -e

# Check if in a git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not a git repository"
    exit 0
fi

echo "## Git State"
echo ""

# Current branch
BRANCH=$(git branch --show-current 2>/dev/null || echo "detached HEAD")
echo "**Branch:** \`$BRANCH\`"
echo ""

# Remote tracking
REMOTE=$(git config --get "branch.$BRANCH.remote" 2>/dev/null || echo "")
if [ -n "$REMOTE" ]; then
    REMOTE_URL=$(git remote get-url "$REMOTE" 2>/dev/null || echo "")
    if [ -n "$REMOTE_URL" ]; then
        echo "**Remote:** $REMOTE_URL"
        echo ""
    fi
fi

# Ahead/behind status
if [ -n "$REMOTE" ]; then
    AHEAD_BEHIND=$(git rev-list --left-right --count "$REMOTE/$BRANCH"...HEAD 2>/dev/null || echo "")
    if [ -n "$AHEAD_BEHIND" ]; then
        BEHIND=$(echo "$AHEAD_BEHIND" | cut -f1)
        AHEAD=$(echo "$AHEAD_BEHIND" | cut -f2)
        if [ "$AHEAD" -gt 0 ] || [ "$BEHIND" -gt 0 ]; then
            echo "**Status:** $AHEAD ahead, $BEHIND behind remote"
            echo ""
        fi
    fi
fi

# Recent commits (last 5)
echo "### Recent Commits"
echo ""
echo "\`\`\`"
git log --oneline -5 2>/dev/null || echo "No commits"
echo "\`\`\`"
echo ""

# Uncommitted changes summary
STAGED=$(git diff --cached --stat 2>/dev/null | tail -1)
UNSTAGED=$(git diff --stat 2>/dev/null | tail -1)
UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

if [ -n "$STAGED" ] || [ -n "$UNSTAGED" ] || [ "$UNTRACKED" -gt 0 ]; then
    echo "### Uncommitted Changes"
    echo ""

    if [ -n "$STAGED" ]; then
        echo "**Staged:** $STAGED"
    fi

    if [ -n "$UNSTAGED" ]; then
        echo "**Unstaged:** $UNSTAGED"
    fi

    if [ "$UNTRACKED" -gt 0 ]; then
        echo "**Untracked files:** $UNTRACKED"
    fi
    echo ""
fi

# Modified files list (if any)
MODIFIED_FILES=$(git diff --name-only HEAD 2>/dev/null)
if [ -n "$MODIFIED_FILES" ]; then
    echo "### Modified Files"
    echo ""
    echo "\`\`\`"
    echo "$MODIFIED_FILES"
    echo "\`\`\`"
    echo ""
fi
