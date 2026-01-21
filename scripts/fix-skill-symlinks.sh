#!/bin/bash
# fix-skill-symlinks.sh
# Automatically fixes broken symlinks in the skills directory that were
# created by `npx skills add` with incorrect relative paths.
#
# The issue: npx skills add creates relative symlinks like "../../.agents/skills/X"
# which break when ~/.claude/skills is itself a symlink to another location.
#
# The fix: Convert broken relative symlinks to absolute paths pointing to ~/.agents/skills/

SKILLS_DIR="$HOME/.claude/skills"
AGENTS_SKILLS_DIR="$HOME/.agents/skills"

if [[ ! -d "$SKILLS_DIR" ]]; then
    exit 0
fi

fixed_count=0

for symlink in "$SKILLS_DIR"/*; do
    [[ -L "$symlink" ]] || continue

    if [[ -e "$symlink" ]]; then
        continue
    fi

    skill_name=$(basename "$symlink")
    correct_target="$AGENTS_SKILLS_DIR/$skill_name"

    if [[ -d "$correct_target" ]]; then
        rm "$symlink"
        ln -s "$correct_target" "$symlink"
        ((fixed_count++))
    fi
done

if [[ $fixed_count -gt 0 ]]; then
    echo "Fixed $fixed_count broken skill symlink(s)"
fi
