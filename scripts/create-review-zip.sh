#!/bin/bash
#
# create-review-zip.sh
#
# Creates a review package zip and copies it to clipboard.
#
# Usage: create-review-zip.sh <project_root> <readme_file> <filelist_file> [output_name]
#
# Arguments:
#   project_root  - Root directory of the project
#   readme_file   - Path to the README.md to include
#   filelist_file - Path to file containing list of files to include (one per line)
#   output_name   - Optional name for the zip (default: review-package-TIMESTAMP)
#

set -euo pipefail

PROJECT_ROOT="${1:-}"
README_FILE="${2:-}"
FILELIST_FILE="${3:-}"
OUTPUT_NAME="${4:-review-package-$(date +%Y%m%d-%H%M%S)}"

if [[ -z "$PROJECT_ROOT" || -z "$README_FILE" || -z "$FILELIST_FILE" ]]; then
    echo "Usage: create-review-zip.sh <project_root> <readme_file> <filelist_file> [output_name]" >&2
    exit 1
fi

if [[ ! -d "$PROJECT_ROOT" ]]; then
    echo "Error: Project root not found: $PROJECT_ROOT" >&2
    exit 1
fi

if [[ ! -f "$README_FILE" ]]; then
    echo "Error: README file not found: $README_FILE" >&2
    exit 1
fi

if [[ ! -f "$FILELIST_FILE" ]]; then
    echo "Error: File list not found: $FILELIST_FILE" >&2
    exit 1
fi

TEMP_DIR=$(mktemp -d)
PACKAGE_DIR="$TEMP_DIR/$OUTPUT_NAME"
mkdir -p "$PACKAGE_DIR"

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

cp "$README_FILE" "$PACKAGE_DIR/README.md"

file_count=0
skipped_count=0

while IFS= read -r file || [[ -n "$file" ]]; do
    [[ -z "$file" ]] && continue
    [[ "$file" =~ ^[[:space:]]*# ]] && continue

    file=$(echo "$file" | xargs)
    [[ -z "$file" ]] && continue

    src="$PROJECT_ROOT/$file"

    if [[ -f "$src" ]]; then
        dest="$PACKAGE_DIR/$file"
        mkdir -p "$(dirname "$dest")"
        cp "$src" "$dest"
        ((file_count++))
    else
        echo "Skipped (not found): $file" >&2
        ((skipped_count++))
    fi
done < "$FILELIST_FILE"

if [[ $file_count -eq 0 ]]; then
    echo "Error: No files were copied. Check the file list." >&2
    exit 1
fi

ZIP_PATH="/tmp/$OUTPUT_NAME.zip"

rm -f "$ZIP_PATH"

(cd "$TEMP_DIR" && zip -rq "$ZIP_PATH" "$OUTPUT_NAME")

if [[ "$(uname)" == "Darwin" ]]; then
    osascript -e "set the clipboard to (POSIX file \"$ZIP_PATH\")"
fi

echo ""
echo "Review package created successfully!"
echo ""
echo "  Location: $ZIP_PATH"
echo "  Files:    $file_count included"
[[ $skipped_count -gt 0 ]] && echo "  Skipped:  $skipped_count (not found)"
echo ""
if [[ "$(uname)" == "Darwin" ]]; then
    echo "Copied to clipboard - paste into Finder or upload dialog."
fi
