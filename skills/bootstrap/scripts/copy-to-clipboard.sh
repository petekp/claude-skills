#!/bin/bash
# Copy file contents to system clipboard
# Usage: copy-to-clipboard.sh <filepath>

set -e

if [ -z "$1" ]; then
    echo "Usage: copy-to-clipboard.sh <filepath>"
    exit 1
fi

FILEPATH="$1"

if [ ! -f "$FILEPATH" ]; then
    echo "Error: File not found: $FILEPATH"
    exit 1
fi

# Detect OS and use appropriate clipboard command
if command -v pbcopy >/dev/null 2>&1; then
    # macOS
    cat "$FILEPATH" | pbcopy
    echo "Copied to clipboard (pbcopy)"
elif command -v xclip >/dev/null 2>&1; then
    # Linux with xclip
    cat "$FILEPATH" | xclip -selection clipboard
    echo "Copied to clipboard (xclip)"
elif command -v xsel >/dev/null 2>&1; then
    # Linux with xsel
    cat "$FILEPATH" | xsel --clipboard --input
    echo "Copied to clipboard (xsel)"
elif command -v clip.exe >/dev/null 2>&1; then
    # WSL
    cat "$FILEPATH" | clip.exe
    echo "Copied to clipboard (clip.exe)"
else
    echo "Warning: No clipboard command found. Contents saved to: $FILEPATH"
    exit 0
fi
