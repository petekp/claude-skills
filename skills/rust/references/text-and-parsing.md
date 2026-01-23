# Text & Parsing

Patterns for UTF-8 safety, path normalization, state machine parsing, and round-trip preservation.

## Table of Contents

- [UTF-8 Safe Truncation](#utf-8-safe-truncation)
- [Path Normalization](#path-normalization)
- [Case Normalization](#case-normalization)
- [State Machine Parsing](#state-machine-parsing)
- [Anchored Updates](#anchored-updates)
- [Round-Trip Preservation](#round-trip-preservation)
- [Line Endings and BOM](#line-endings-and-bom)

---

## UTF-8 Safe Truncation

Indexing with byte offsets (`&s[..60]`) **panics** if the index isn't on a character boundary.

### When to Use Each Approach

| Use Case | Method | Example |
|----------|--------|---------|
| Display width limits | Grapheme clusters | UI truncation, terminal output |
| User-facing "character count" | Grapheme clusters | Twitter-like limits |
| Internal indexing | Byte offsets with snap-to-boundary | Text editors, search |
| Simple ASCII-heavy text | Characters (`.chars()`) | Config files, identifiers |

### By Characters (efficient)

```rust
fn truncate_chars(s: &str, max_chars: usize) -> String {
    let mut chars = s.chars();
    let truncated: String = chars.by_ref().take(max_chars).collect();

    // Check if there's more content (single iteration, not two)
    if chars.next().is_some() {
        format!("{truncated}...")
    } else {
        truncated
    }
}
```

### By Grapheme Clusters (emoji-safe)

```rust
use unicode_segmentation::UnicodeSegmentation;

fn truncate_graphemes(s: &str, max_graphemes: usize) -> String {
    let mut graphemes = s.graphemes(true);
    let truncated: String = graphemes.by_ref().take(max_graphemes).collect();

    if graphemes.next().is_some() {
        format!("{truncated}...")
    } else {
        s.to_string()
    }
}
```

**Note**: For terminal display width, neither chars nor graphemes is fully correct—you need East Asian width handling. Consider the `unicode-width` crate.

---

## Path Normalization

Use a single normalizer for all comparisons and hashing:

```rust
use std::path::{Path, PathBuf};

fn normalize_path(path: &str) -> String {
    let mut result = path.trim_end_matches(['/', '\\']).to_string();

    // Collapse consecutive slashes
    while result.contains("//") {
        result = result.replace("//", "/");
    }

    // Handle empty → root distinction
    if result.is_empty() {
        return "/".to_string();
    }

    result
}

fn child_prefix(query: &str) -> String {
    let q = normalize_path(query);
    if q == "/" { "/".to_string() } else { format!("{q}/") }
}
```

### Platform Considerations

| Platform | Issue | Solution |
|----------|-------|----------|
| Windows | Backslashes, drive letters | Normalize `\` → `/`, handle `C:` vs `C:\` |
| macOS (HFS+/APFS) | NFD Unicode normalization | Use `unicode-normalization` crate |
| Cross-platform | `\\?\` prefix on Windows | Use `dunce` crate for canonicalization |

For robust cross-platform paths, prefer `std::path::Path` and accept platform differences, or explicitly document which platform behavior you're targeting.

---

## Case Normalization

`to_ascii_lowercase()` handles only A-Z. For Unicode case folding, use `str::to_lowercase()` or the `unicode-casemapping` crate.

```rust
// ASCII-only (suitable for most config/spec keys)
fn norm_key(k: &str) -> String { k.trim().to_ascii_lowercase() }

// Unicode-aware (for user-facing text)
fn norm_key_unicode(k: &str) -> String { k.trim().to_lowercase() }
```

**Whitespace**: `trim()` uses Unicode whitespace. If your spec defines whitespace differently:

```rust
fn trim_spec(s: &str) -> &str {
    s.trim_matches(|c| c == ' ' || c == '\t')  // Only ASCII space/tab
}
```

---

## State Machine Parsing

For markdown-like formats, a state machine beats fragile regex.

```rust
use std::sync::LazyLock;
use regex::Regex;

// ULID character set (Crockford's Base32, excluding I, L, O, U)
static HEADING_RE: LazyLock<Regex> = LazyLock::new(|| {
    // (?m) enables multiline mode: ^ matches start of line, not just string
    Regex::new(r"(?m)^### \[#idea-([0-9A-HJKMNP-TV-Z]{26})\]\s*(.*)$")
        .expect("heading regex is valid")
});

#[derive(Debug, Clone, PartialEq)]
enum ParseState {
    OutsideBlock,
    InHeader { id: String },
    InMetadata { id: String },
    InBody { id: String },
}

#[derive(Debug)]
enum ParseEvent {
    BlockStart { id: String, title: String },
    MetadataField { key: String, value: String },
    BodyLine(String),
    BlockEnd,
}

fn parse_line(state: &mut ParseState, line: &str) -> Option<ParseEvent> {
    match state {
        ParseState::OutsideBlock => {
            if let Some(caps) = HEADING_RE.captures(line) {
                let id = caps.get(1).unwrap().as_str().to_string();
                let title = caps.get(2).map(|m| m.as_str()).unwrap_or("").to_string();
                *state = ParseState::InHeader { id: id.clone() };
                return Some(ParseEvent::BlockStart { id, title });
            }
            None
        }

        ParseState::InHeader { id } => {
            // Transition to metadata on first non-empty line
            if line.trim().is_empty() {
                return None;
            }
            let id = id.clone();
            *state = ParseState::InMetadata { id };
            parse_line(state, line)  // Re-process as metadata
        }

        ParseState::InMetadata { id } => {
            // Delimiter ends metadata, starts body
            if line.trim() == "---" {
                *state = ParseState::InBody { id: id.clone() };
                return None;
            }
            // New heading ends block
            if HEADING_RE.is_match(line) {
                let event = ParseEvent::BlockEnd;
                *state = ParseState::OutsideBlock;
                return Some(event);
            }
            // Parse "Key: Value" lines
            if let Some((key, value)) = line.split_once(':') {
                return Some(ParseEvent::MetadataField {
                    key: key.trim().to_string(),
                    value: value.trim().to_string(),
                });
            }
            None
        }

        ParseState::InBody { id } => {
            // New heading ends block
            if HEADING_RE.is_match(line) {
                let event = ParseEvent::BlockEnd;
                *state = ParseState::OutsideBlock;
                return Some(event);
            }
            Some(ParseEvent::BodyLine(line.to_string()))
        }
    }
}
```

---

## Anchored Updates

**Problem**: `line.contains("[#idea-123]")` matches references in body text, causing silent corruption.

**Solution**: Only match headings at line start:

```rust
fn update_block_field(content: &str, target_id: &str, key: &str, new_value: &str) -> String {
    let mut result = Vec::new();
    let mut in_target_block = false;
    let mut in_metadata = false;
    let mut field_updated = false;

    for line in content.lines() {
        if let Some(caps) = HEADING_RE.captures(line) {
            let id = caps.get(1).unwrap().as_str();
            in_target_block = id == target_id;
            in_metadata = in_target_block;
            field_updated = false;
        }

        if in_target_block && in_metadata {
            if line.trim() == "---" {
                // End of metadata—insert field if not updated
                if !field_updated {
                    result.push(format!("{key}: {new_value}"));
                }
                in_metadata = false;
            } else if let Some((k, _)) = line.split_once(':') {
                if k.trim().eq_ignore_ascii_case(key) {
                    result.push(format!("{key}: {new_value}"));
                    field_updated = true;
                    continue;
                }
            }
        }

        result.push(line.to_string());
    }

    result.join("\n")
}
```

---

## Round-Trip Preservation

Parse into an AST that preserves formatting for lossless round-trips:

```rust
#[derive(Debug)]
pub struct ParsedFile {
    pub format_version: u32,
    pub blocks: Vec<Block>,
    pub trailing_text: String,
}

#[derive(Debug)]
pub struct Block {
    pub id: String,
    pub header_line: String,        // Preserve original formatting
    pub header_span: Span,          // Byte offsets for error reporting
    pub fields: Vec<Field>,
    pub body: String,
    pub body_span: Span,
    pub separator: String,          // e.g., "\n---\n"
}

#[derive(Debug)]
pub struct Field {
    pub key: String,
    pub value: String,
    pub span: Span,
}

#[derive(Debug, Clone, Copy)]
pub struct Span {
    pub start: usize,  // Byte offset
    pub end: usize,
}
```

**Why spans matter**: For error reporting with line/column numbers, and for incremental re-parsing after edits.

---

## Line Endings and BOM

### Line Endings

Preserve original line endings for round-trip fidelity:

```rust
#[derive(Debug, Clone, Copy, PartialEq)]
enum LineEnding {
    Lf,      // Unix: \n
    CrLf,    // Windows: \r\n
    Cr,      // Classic Mac: \r (rare)
}

fn detect_line_ending(content: &str) -> LineEnding {
    if content.contains("\r\n") {
        LineEnding::CrLf
    } else if content.contains('\r') {
        LineEnding::Cr
    } else {
        LineEnding::Lf
    }
}
```

If normalizing instead of preserving, document the choice explicitly.

### BOM Handling

UTF-8 files sometimes have a BOM (U+FEFF, encoded as `EF BB BF`):

```rust
fn strip_bom(content: &str) -> &str {
    content.strip_prefix('\u{FEFF}').unwrap_or(content)
}

fn preserve_bom(original: &str, new_content: &str) -> String {
    if original.starts_with('\u{FEFF}') {
        format!("\u{FEFF}{new_content}")
    } else {
        new_content.to_string()
    }
}
```

---

## Duplicate ID Handling

External edits can create duplicate IDs. Use a deterministic policy (first-wins or error):

```rust
use std::collections::HashSet;

fn dedupe_by_id<T: HasId>(items: Vec<T>) -> Vec<T> {
    let mut seen = HashSet::new();
    items.into_iter()
        .filter(|item| seen.insert(item.id().to_string()))
        .collect()
}
```

For error reporting instead of silent dedupe:

```rust
fn validate_unique_ids<T: HasId>(items: &[T]) -> Result<(), Vec<String>> {
    let mut seen = HashSet::new();
    let duplicates: Vec<_> = items.iter()
        .filter(|item| !seen.insert(item.id()))
        .map(|item| item.id().to_string())
        .collect();

    if duplicates.is_empty() {
        Ok(())
    } else {
        Err(duplicates)
    }
}
```
