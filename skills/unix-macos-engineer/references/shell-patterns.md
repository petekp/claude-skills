# Shell Script Patterns

Robust patterns for Bash/Zsh scripts.

## Script Header

Always start scripts with:

```bash
#!/usr/bin/env bash
set -euo pipefail

# -e: Exit on error
# -u: Error on undefined variables
# -o pipefail: Pipeline fails if any command fails
```

## Argument Parsing

### Simple positional args

```bash
#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <filename>" >&2
    exit 1
fi

filename="$1"
```

### Named arguments with getopts

```bash
#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $0 [-v] [-o output] <input>" >&2
    exit 1
}

verbose=false
output=""

while getopts ":vo:" opt; do
    case $opt in
        v) verbose=true ;;
        o) output="$OPTARG" ;;
        \?) echo "Invalid option: -$OPTARG" >&2; usage ;;
        :) echo "Option -$OPTARG requires an argument" >&2; usage ;;
    esac
done
shift $((OPTIND - 1))

[[ $# -lt 1 ]] && usage
input="$1"
```

## Defensive Checks

### Command existence

```bash
command -v git &>/dev/null || {
    echo "Error: git is not installed" >&2
    exit 1
}
```

### File/directory checks

```bash
[[ -f "$file" ]] || { echo "File not found: $file" >&2; exit 1; }
[[ -d "$dir" ]] || { echo "Directory not found: $dir" >&2; exit 1; }
[[ -r "$file" ]] || { echo "File not readable: $file" >&2; exit 1; }
[[ -w "$file" ]] || { echo "File not writable: $file" >&2; exit 1; }
[[ -x "$file" ]] || { echo "File not executable: $file" >&2; exit 1; }
```

### Running as root

```bash
# Require root
[[ $EUID -eq 0 ]] || { echo "Must run as root" >&2; exit 1; }

# Prevent running as root
[[ $EUID -ne 0 ]] || { echo "Do not run as root" >&2; exit 1; }
```

## Variable Defaults

```bash
# Default value if unset
name="${NAME:-default_value}"

# Default value if unset or empty
name="${NAME:-default_value}"

# Error if unset
name="${NAME:?NAME environment variable required}"
```

## String Operations

```bash
# Check if string is empty
[[ -z "$str" ]] && echo "Empty"

# Check if string is non-empty
[[ -n "$str" ]] && echo "Not empty"

# String comparison
[[ "$str" == "value" ]]
[[ "$str" != "value" ]]

# Pattern matching (glob)
[[ "$str" == *.txt ]]

# Regex matching
[[ "$str" =~ ^[0-9]+$ ]]

# Case-insensitive comparison
[[ "${str,,}" == "value" ]]  # Bash 4+
```

## Arrays

```bash
# Define array
files=("one.txt" "two.txt" "three.txt")

# Add element
files+=("four.txt")

# Iterate
for file in "${files[@]}"; do
    echo "$file"
done

# Length
echo "${#files[@]}"

# Index access
echo "${files[0]}"
```

## Loops

### Process lines from file

```bash
while IFS= read -r line; do
    echo "$line"
done < "$file"
```

### Process command output

```bash
while IFS= read -r line; do
    echo "$line"
done < <(some_command)
```

### Process find results safely

```bash
while IFS= read -r -d '' file; do
    echo "$file"
done < <(find . -name "*.txt" -print0)
```

## Temporary Files

```bash
# Create temp file
tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT

# Create temp directory
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
```

## Error Handling

### Trap on exit

```bash
cleanup() {
    rm -f "$tmpfile"
    echo "Cleanup complete"
}
trap cleanup EXIT
```

### Trap on error

```bash
on_error() {
    echo "Error on line $1" >&2
}
trap 'on_error $LINENO' ERR
```

## Logging

```bash
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >&2
}

log "Starting script"
error "Something went wrong"
```

## User Interaction

### Confirm before proceeding

```bash
read -rp "Continue? [y/N] " response
[[ "$response" =~ ^[Yy]$ ]] || exit 0
```

### Prompt with default

```bash
read -rp "Enter name [default]: " name
name="${name:-default}"
```

## Path Manipulation

```bash
# Get directory of script
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get filename from path
filename="${path##*/}"

# Get directory from path
dirname="${path%/*}"

# Get extension
ext="${filename##*.}"

# Remove extension
basename="${filename%.*}"
```

## Process Management

```bash
# Run in background
long_running_command &
pid=$!

# Wait for completion
wait "$pid"

# Check if process exists
kill -0 "$pid" 2>/dev/null && echo "Running"

# Kill process group
kill -- -"$pid"
```

## Common Pitfalls

- **Always quote variables**: `"$var"` not `$var`
- **Use `[[` not `[`**: `[[` is more powerful and safer
- **Avoid parsing `ls`**: Use glob patterns or `find`
- **Don't use `cat file | grep`**: Use `grep pattern file`
- **Check exit codes**: `if command; then ...` or `command || handle_error`
