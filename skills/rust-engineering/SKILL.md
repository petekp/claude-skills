---
name: rust-engineering
description: Robust Rust patterns for file-backed data, parsing, persistence, FFI boundaries, and system integration. Use when writing Rust that handles file formats, subprocess integration, PID/process management, Serde serialization, or UniFFI boundaries. Covers UTF-8 safety, atomic writes, state machines, and defensive error handling.
---

# Rust Engineering Guide

Patterns for building reliable Rust systems that handle file-backed data, external process integration, and cross-language boundaries.

## Core Philosophy

### Conservative by Default

Inputs from files, subprocesses, and external systems are potentially untrusted (corrupt, half-written, out of date). Rust code should be:

- **Conservative**: Prefer false negatives over false positives
- **Deterministic**: Same input → same output
- **Resilient**: Never panic on user machines due to bad input

### Canonical Model Ownership

If Rust is the source of truth, treat the Rust model as canonical. Everything else adapts to it:

- **Internal domain model**: Expressive, ergonomic for your logic
- **FFI DTOs**: Boring, stable, language-friendly
- **File format model**: Stable, versioned, round-trippable
- **External input model**: Strictly validated, never trusted blindly

---

## Data Modeling

### Strong Types Over Strings

Strings for status/effort/triage lead to case-mismatch bugs and invalid values. Prefer enums:

```rust
#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Status { Open, InProgress, Done, Dismissed }

#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Priority { P0, P1, P2, P3 }

#[derive(Clone, Debug, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Effort { Small, Medium, Large, Xl }
```

### Versioned Data With Serde

When adding fields to serialized structures, old data won't have them. Model explicitly:

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LockInfo {
    pub pid: u32,
    pub path: String,

    #[serde(default)]
    pub proc_started: Option<u64>,  // new field - absent in old data

    #[serde(default, alias = "started")]
    pub created: Option<u64>,       // supports old field name
}
```

Key patterns:
- `#[serde(default)]` ensures missing fields deserialize cleanly
- `alias = "old_name"` reads older formats without rewriting them
- Never repurpose field meanings in-place—add new fields instead

### Sentinel Values

If the spec uses sentinel strings (e.g., `Related: None`) but your type is `Option<String>`:

```rust
fn parse_optional_field(raw: &str) -> Option<String> {
    let t = raw.trim();
    if t.is_empty() || t.eq_ignore_ascii_case("none") {
        None
    } else {
        Some(t.to_string())
    }
}
```

### UniFFI Boundaries

UniFFI works best with flat, stable types:

- `String` for IDs and timestamps (convert `Uuid`/`DateTime` at the boundary)
- Flat enums (no associated data) or string representations
- `Vec<T>` and `Option<T>` where `T` is FFI-friendly
- Records with stable fields

```rust
#[derive(Clone, Debug, uniffi::Record)]
pub struct IdeaDto {
    pub id: String,
    pub created_at_ms: i64,
    pub status: String,        // "open" | "in_progress" | "done"
    pub priority: Option<String>,
}
```

Why strings for enums in DTOs? Extremely stable across languages and avoids edge cases when adding variants.

---

## String & Text Safety

### UTF-8 Slicing Can Panic

In Rust, `String`/`&str` are UTF-8. Indexing with byte offsets (`&s[..60]`) **panics** if the index isn't on a character boundary.

### Safe Truncation by Characters

```rust
fn truncate_chars(s: &str, max_chars: usize) -> String {
    let out: String = s.chars().take(max_chars).collect();
    if s.chars().count() > max_chars {
        format!("{out}...")
    } else {
        out
    }
}
```

### Emoji-Safe Truncation (Grapheme Clusters)

For UI-facing text, use `unicode-segmentation`:

```rust
use unicode_segmentation::UnicodeSegmentation;

fn truncate_graphemes(s: &str, max_graphemes: usize) -> String {
    let graphemes: Vec<&str> = s.graphemes(true).collect();
    if graphemes.len() > max_graphemes {
        format!("{}...", graphemes[..max_graphemes].concat())
    } else {
        s.to_string()
    }
}
```

### Path Normalization

Path strings arrive from many sources with inconsistent formatting. Use a single normalizer for all comparisons and hashing:

```rust
fn normalize_path(path: &str) -> String {
    let trimmed = path.trim_end_matches('/');
    if trimmed.is_empty() {
        "/".to_string()
    } else {
        trimmed.to_string()
    }
}
```

Special-case root for child-of logic:

```rust
fn child_prefix(query: &str) -> String {
    let q = normalize_path(query);
    if q == "/" { "/".to_string() } else { format!("{}/", q) }
}
```

### Case Normalization

If spec says values are case-insensitive, normalize early:

```rust
fn norm_key(k: &str) -> String {
    k.trim().to_ascii_lowercase()
}

fn norm_value(v: &str) -> String {
    v.trim().to_ascii_lowercase()
}
```

---

## Parsing & Serialization

### State Machine Parsing

For markdown-like formats with predictable structure, a state machine beats fragile regex:

**States:**
- `OutsideBlock`
- `InBlockHeader`
- `InMetadataBlock`
- `InDescription`

**Rules:**
- Match block start only on the heading line (e.g., `### [#idea-<id>] <title>`)
- Parse metadata only within a contiguous region after the heading
- Treat everything else as content until delimiter (`---`) or next heading

### Anchored Updates

**Problem:** `line.contains("[#idea-123]")` can match references in descriptions, causing silent corruption.

**Solution:** Anchor on the heading line with precise patterns:

```rust
use once_cell::sync::Lazy;
use regex::Regex;

static IDEA_HEADING_RE: Lazy<Regex> = Lazy::new(|| {
    Regex::new(r"^### \[#idea-([0-9A-HJKMNP-TV-Z]{26})\]\s*(.*)$").unwrap()
});
```

Update logic:
1. Scan lines for heading that exactly matches target ID → `in_target_block = true`
2. While in block, update only the metadata key you care about
3. Stop when you hit delimiter (`---`) or new heading

### Round-Trip Preservation

Parse into an AST that preserves formatting for lossless round-trips:

```rust
pub struct ParsedFile {
    pub format_version: u32,
    pub sections: Vec<Section>,
    pub trailing_text: String,  // preserve unknown text/comments
}

pub struct Block {
    pub id: String,
    pub header_line: String,        // preserve original formatting
    pub fields: Vec<(String, String)>,
    pub body: String,
    pub separator: String,          // e.g., "\n---\n"
}
```

### Version Markers

If the format spec mandates a version marker, parsing should be strict:

```rust
#[derive(thiserror::Error, Debug)]
pub enum ParseError {
    #[error("Unsupported format. Expected {expected}, found {found:?}")]
    UnsupportedFormat { expected: String, found: Option<String> },

    #[error("Item not found: {0}")]
    NotFound(String),
}
```

### Duplicate ID Handling

External edits can create duplicate IDs. Pick a deterministic policy:

```rust
use std::collections::HashSet;

fn dedupe_by_id<T: HasId>(items: Vec<T>) -> Vec<T> {
    let mut seen = HashSet::new();
    items.into_iter()
        .filter(|item| seen.insert(item.id().to_string()))
        .collect()
}
```

---

## File I/O & Persistence

### Durable-First Invariant

**Never** gate persistence on validation or subprocess output:

1. Write raw data to storage (e.g., `status: pending`)
2. Return control immediately
3. Async enrichment updates later (or not at all)

### Atomic Writes

Write to temp file, then rename (atomic on same filesystem):

```rust
use std::{io::Write, path::Path};
use tempfile::NamedTempFile;

fn atomic_write(path: &Path, contents: &str) -> std::io::Result<()> {
    let dir = path.parent().unwrap_or_else(|| Path::new("."));
    let mut tmp = NamedTempFile::new_in(dir)?;
    tmp.write_all(contents.as_bytes())?;
    tmp.flush()?;
    tmp.persist(path).map(|_| ()).map_err(|e| e.error)
}
```

### Concurrency Control

Two things might write: your app and external processes (Claude, human edits).

**In-process:** `Mutex` works
**Out-of-process:** Make writes merge-friendly:
1. Re-read file before write
2. Apply patch to latest parsed model
3. Write back atomically

Advisory locking (`fs2::FileExt`) is an option for stronger guarantees.

### File Watching

Use debounced file watchers for external edit detection:

- Watcher thread pushes events into a channel
- Model thread parses and computes diffs
- UI receives "data changed for X" (avoid huge payloads)

---

## Process & System Integration

### PID Liveness vs Identity

`kill(pid, 0)` detects if a PID exists, not if it's the same process. PID reuse creates "ghost" sessions.

**Solution:** Store and verify process start time:

```rust
fn is_pid_alive_verified(pid: u32, expected_start: Option<u64>) -> bool {
    let Some(expected) = expected_start else {
        return is_pid_alive_legacy(pid);
    };

    match get_process_start_time(pid) {
        Some(actual) => actual == expected,
        None => false,
    }
}
```

### Process Start Time With sysinfo

Cache `sysinfo::System` to avoid repeated expensive allocations:

```rust
use sysinfo::{Pid, ProcessRefreshKind, RefreshKind, System};

thread_local! {
    static SYSTEM_CACHE: std::cell::RefCell<Option<System>> =
        std::cell::RefCell::new(None);
}

pub fn get_process_start_time(pid: u32) -> Option<u64> {
    SYSTEM_CACHE.with(|cache| {
        let mut cache = cache.borrow_mut();
        let sys = cache.get_or_insert_with(|| {
            System::new_with_specifics(
                RefreshKind::new().with_processes(ProcessRefreshKind::new()),
            )
        });
        sys.refresh_processes_specifics(ProcessRefreshKind::new());
        sys.process(Pid::from(pid as usize)).map(|p| p.start_time())
    })
}
```

### Legacy Mitigation

For legacy data without process verification:

1. PID exists (`kill(pid, 0)`)
2. Process identity heuristic (e.g., "claude" in process name)
3. Age expiry (e.g., 24h) for unverified entries

### Subprocess Integration

Treat subprocess output as hostile input:

```rust
use std::process::{Command, Stdio};
use std::io::Write;

pub fn run_subprocess(prompt: &str, stdin_payload: &str) -> anyhow::Result<String> {
    let mut child = Command::new("claude")
        .args(["--print", "--output-format", "json", prompt])
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()?;

    {
        let stdin = child.stdin.as_mut()
            .ok_or_else(|| anyhow::anyhow!("no stdin"))?;
        stdin.write_all(stdin_payload.as_bytes())?;
    }

    let output = child.wait_with_output()?;
    if !output.status.success() {
        return Err(anyhow::anyhow!(
            "subprocess failed: {}",
            String::from_utf8_lossy(&output.stderr)
        ));
    }

    Ok(String::from_utf8(output.stdout)?)
}
```

**Validation:** Parse JSON strictly with `serde_json`. If invalid, mark as failed but keep data intact.

**Timeouts:** Enforce timeouts for background operations. On timeout, kill process and record failure.

### Timestamp Handling

The number-one timestamp bug: unit mismatch (seconds vs milliseconds).

```rust
fn normalize_epoch_to_secs(v: u64) -> u64 {
    if v >= 1_000_000_000_000 { v / 1000 } else { v }
}

fn normalize_epoch_to_ms(v: u64) -> u64 {
    if v < 1_000_000_000_000 { v * 1000 } else { v }
}
```

Use `saturating_sub` for age computations to prevent underflow:

```rust
let age = now.saturating_sub(created);
```

Parse ISO timestamps for legacy data:

```rust
fn parse_rfc3339_to_secs(s: &str) -> Option<u64> {
    chrono::DateTime::parse_from_rfc3339(s)
        .ok()
        .map(|dt| dt.timestamp() as u64)
}
```

---

## Performance

### Cache Compiled Regex

Compiling regex during every parse is wasteful:

```rust
use once_cell::sync::Lazy;
use regex::Regex;

static HEADING_RE: Lazy<Regex> = Lazy::new(|| {
    Regex::new(r"^### \[#item-([A-Z0-9]+)\]").unwrap()
});
```

### Cache Parse Results

Re-parsing files repeatedly hits scaling issues. Cache by `(mtime, size)` or content hash:

```rust
struct CachedParse {
    mtime: SystemTime,
    size: u64,
    result: ParsedData,
}
```

### Deterministic Selection

Directory iteration order is unstable. When selecting from multiple candidates, be deterministic:

```rust
fn prefer_newer(a: &Info, b: &Info) -> bool {
    let a_c = a.created.unwrap_or(0);
    let b_c = b.created.unwrap_or(0);
    a_c > b_c || (a_c == b_c && a.path > b.path)  // tie-breaker
}
```

### Avoid N×Filter Patterns

Maintain indexed structures for frequent lookups:

```rust
// Instead of filtering Vec on every access
HashMap<ProjectPath, Vec<ItemId>>
```

Update incrementally on change events.

---

## Error Handling

### Never Panic on Bad Input

File I/O and JSON parsing must never panic on user machines:

- If metadata can't be parsed → ignore that entry (don't crash, don't guess)
- If timestamps are missing → treat conservatively (older for selection, unverified for safety)
- Use `Option` and early returns liberally

### Explicit Error Types

Define a single error type for the module with `thiserror`:

```rust
#[derive(thiserror::Error, Debug)]
pub enum DataError {
    #[error("I/O error: {0}")]
    Io(#[from] std::io::Error),

    #[error("Parse error: {0}")]
    Parse(String),

    #[error("Not found: {0}")]
    NotFound(String),

    #[error("Subprocess failed: {0}")]
    SubprocessFailed(String),

    #[error("Timeout after {0}ms")]
    Timeout(u64),

    #[error("Unsupported format: expected {expected}, found {found:?}")]
    UnsupportedFormat { expected: String, found: Option<String> },
}
```

### Graceful Degradation

Errors should degrade to "core functionality still works":
- Capture succeeds even if validation fails
- Data is preserved even if enrichment times out

---

## Testing

### Unit Tests

- **Round-trip tests**: parse → serialize → parse again → same data
- **Mutation tests**: updates only touch intended fields
- **Normalization tests**: case-insensitive values parse equivalently

### Golden Files

Store sample fixtures in `tests/fixtures/` and assert exact output after transformations.

### Contract Tests

Create fixture files representing real-world scenarios:
- Verified data with all fields
- Legacy data with old field names
- Missing timestamps
- Corrupted JSON
- Unit mismatches (ms vs seconds)

### Property Tests

Use `proptest` to generate random inputs and ensure:
- Parser doesn't panic
- IDs are preserved through round-trips

### Subprocess Integration Tests

Don't depend on real external processes in CI:
- Provide a fake executable in PATH that returns deterministic output
- Verify timeout and parsing logic

### Essential Test Cases

- [ ] Version marker: missing/wrong → error
- [ ] Empty file: initializes properly
- [ ] Metadata injection: description resembling metadata stays in description
- [ ] Anchored updates: update affects only intended block
- [ ] Duplicate IDs: deterministic dedupe enforced
- [ ] PID correlation: mismatched PID rejected

---

## Quick Reference

### Do

- ✅ Truncate strings with `chars()` or graphemes
- ✅ Anchor identification to heading lines (`^### [#item-...]`)
- ✅ Parse metadata only within defined regions
- ✅ Normalize keys/values early per spec
- ✅ Cache compiled regex and parse results
- ✅ Write files atomically
- ✅ Verify PID identity with process start time
- ✅ Use `saturating_sub` for time arithmetic
- ✅ Use explicit error variants
- ✅ Test edge cases and known failure modes

### Don't

- ❌ Slice strings with `&s[..N]` without checking char boundaries
- ❌ Use `.contains()` to decide which block to update
- ❌ Treat metadata patterns anywhere as real metadata
- ❌ Ignore version markers if spec requires enforcement
- ❌ Recompile regex each parse
- ❌ Assume IDs are unique with external edits
- ❌ Trust subprocess output without validation
- ❌ Mix timestamp units without normalization
- ❌ Panic on malformed input

### Change Checklist

When modifying these systems, verify:

**Schema / Serde**
- [ ] New fields are `Option` + `#[serde(default)]`
- [ ] Old field names supported via `alias`
- [ ] No field meaning repurposed in-place

**Paths**
- [ ] All comparisons use shared normalizer
- [ ] Root handled explicitly (no accidental `//`)
- [ ] Hashing uses normalized paths

**PID Safety**
- [ ] Existence ≠ identity unless legacy mode
- [ ] Verified entries check `proc_started`
- [ ] Legacy mode has mitigations + age expiry

**Timestamps**
- [ ] Units consistent or normalized on read
- [ ] Selection deterministic on ties
- [ ] Age checks immune to unit mismatch

**Robustness**
- [ ] No panics on file I/O or parse errors
- [ ] Unreadable data ignored, not guessed
- [ ] Performance stable under frequent refresh
