#!/bin/bash
#
# Syncs skills from this repository to ~/.claude/skills user directory.
#
# Usage:
#   ./sync-skills.sh          # Sync all skills
#   ./sync-skills.sh --prune  # Sync and remove orphaned skills from target
#
# Behavior:
#   - Skills in repo overwrite matching skills in target (files added, updated, or removed)
#   - .local* files in target are always preserved (user-specific configs not tracked in git)
#   - Skills only in target are reported as orphaned but left untouched (use --prune to remove)
#   - Can be run manually or via the post-commit git hook
#

set -e

REPO_SKILLS="$(cd "$(dirname "$0")" && pwd)/skills"
TARGET_DIR="$HOME/.claude/skills"

if [[ ! -d "$REPO_SKILLS" ]]; then
    echo "Error: Source directory not found: $REPO_SKILLS"
    exit 1
fi

mkdir -p "$TARGET_DIR"

echo "Syncing skills from $REPO_SKILLS to $TARGET_DIR"

for skill_dir in "$REPO_SKILLS"/*/; do
    skill_name=$(basename "$skill_dir")
    target_skill_dir="$TARGET_DIR/$skill_name"

    mkdir -p "$target_skill_dir"

    # Sync skill files, excluding local configs and macOS metadata
    rsync -av --delete \
        --exclude '.local*' \
        --exclude '*.local*' \
        --exclude '.DS_Store' \
        "$skill_dir" "$target_skill_dir/"

    echo "  ✓ $skill_name"
done

# Detect skills in target that don't exist in repo
repo_skills=$(ls -1 "$REPO_SKILLS" 2>/dev/null | sort)
target_skills=$(ls -1 "$TARGET_DIR" 2>/dev/null | grep -v '^\.' | sort)

orphaned=$(comm -13 <(echo "$repo_skills") <(echo "$target_skills"))

if [[ -n "$orphaned" ]]; then
    echo ""
    echo "Orphaned skills in target (not in repo):"
    for skill in $orphaned; do
        echo "  - $skill"
    done
    echo ""
    echo "Run with --prune to remove orphaned skills"

    if [[ "$1" == "--prune" ]]; then
        for skill in $orphaned; do
            echo "Removing $TARGET_DIR/$skill"
            rm -rf "$TARGET_DIR/$skill"
        done
    fi
fi

echo ""
echo "Sync complete."
