# Testing & Quality

Testing strategies and quality tooling for robust Rust systems.

## Table of Contents

- [Unit Tests](#unit-tests)
- [Property and Fuzz Testing](#property-and-fuzz-testing)
- [Integration Tests](#integration-tests)
- [Essential Test Cases](#essential-test-cases)
- [Quality Tools](#quality-tools)

---

## Unit Tests

### Round-Trip Tests

Verify parse → serialize → parse produces identical data:

```rust
#[test]
fn round_trip_preserves_data() {
    let original = MyData {
        id: "abc123".to_string(),
        value: 42,
        optional: Some("test".to_string()),
    };

    let serialized = serde_json::to_string(&original).unwrap();
    let deserialized: MyData = serde_json::from_str(&serialized).unwrap();

    assert_eq!(original, deserialized);
}
```

### Mutation Tests

Verify updates only touch intended fields:

```rust
#[test]
fn update_preserves_other_fields() {
    let mut data = create_test_data();
    let original_id = data.id.clone();
    let original_created = data.created_at;

    data.update_status(Status::Done);

    assert_eq!(data.id, original_id, "ID should not change");
    assert_eq!(data.created_at, original_created, "created_at should not change");
    assert_eq!(data.status, Status::Done, "status should update");
}
```

### Normalization Tests

Verify case-insensitive values parse equivalently:

```rust
#[test]
fn status_parsing_case_insensitive() {
    assert_eq!(parse_status("open"), parse_status("OPEN"));
    assert_eq!(parse_status("in_progress"), parse_status("In_Progress"));
}
```

---

## Property and Fuzz Testing

### Property Tests with proptest

Generate random inputs and verify invariants:

```rust
use proptest::prelude::*;

proptest! {
    #[test]
    fn parser_never_panics(s in "\\PC*") {
        // Parser should handle any input without panicking
        let _ = parse_document(&s);
    }

    #[test]
    fn ids_preserved_through_round_trip(id in "[a-zA-Z0-9]{1,26}") {
        let doc = format!("### [#idea-{id}] Test\nStatus: open\n---\n");
        let parsed = parse_document(&doc).unwrap();
        assert!(parsed.blocks.iter().any(|b| b.id == id));
    }
}
```

### Fuzz Testing

For deeper coverage of parser edge cases:

```bash
cargo install cargo-fuzz
cargo fuzz init
cargo fuzz run parse_fuzz_target
```

A fuzz target:

```rust
#![no_main]
use libfuzzer_sys::fuzz_target;

fuzz_target!(|data: &[u8]| {
    if let Ok(s) = std::str::from_utf8(data) {
        // Should never panic
        let _ = my_crate::parse(s);
    }
});
```

Fuzz testing finds edge cases proptest may miss—particularly valuable for parsers and string processing.

---

## Integration Tests

### Golden Files

Store expected outputs in `tests/fixtures/`:

```rust
#[test]
fn transform_matches_golden() {
    let input = include_str!("fixtures/input.md");
    let expected = include_str!("fixtures/expected_output.md");

    let actual = transform(input);

    assert_eq!(actual, expected);
}
```

### Contract Tests

Create fixtures representing real-world scenarios:

```
tests/fixtures/
├── valid_complete.json      # All fields present
├── legacy_old_names.json    # Uses old field names (alias)
├── missing_timestamps.json  # Optional fields absent
├── corrupted.json           # Invalid JSON
└── unit_mismatch.json       # Timestamps in ms instead of sec
```

### Subprocess Tests

Don't depend on real external processes in CI:

```rust
#[test]
fn handles_subprocess_timeout() {
    // Create a fake executable that sleeps forever
    let fake_cmd = create_fake_command("sleep", "999");

    let result = run_subprocess(&fake_cmd, &[], "", Duration::from_millis(100));

    assert!(matches!(result, Err(SubprocessError::Timeout(_))));
}

#[test]
fn handles_subprocess_failure() {
    let fake_cmd = create_fake_command("exit", "1");

    let result = run_subprocess(&fake_cmd, &[], "", Duration::from_secs(5));

    assert!(matches!(result, Err(SubprocessError::NonZeroExit { .. })));
}
```

---

## Essential Test Cases

Each test case maps to a specific bug this guide prevents:

| Test Case | Bug Prevented | Related Pattern |
|-----------|---------------|-----------------|
| Version marker missing → error | Silent format mismatch | [text-and-parsing.md](text-and-parsing.md) |
| Empty file initializes properly | Crash on empty input | Graceful degradation |
| Metadata in body stays in body | Silent corruption | [Anchored updates](text-and-parsing.md#anchored-updates) |
| Update affects only target block | Wrong block modified | [State machine parsing](text-and-parsing.md#state-machine-parsing) |
| Duplicate IDs handled deterministically | Undefined behavior | [Duplicate ID handling](text-and-parsing.md#duplicate-id-handling) |
| Mismatched PID rejected | Ghost sessions | [PID verification](process-integration.md#pid-liveness-vs-identity) |
| Timestamp unit mismatch normalized | Age calculation bugs | [Timestamp handling](process-integration.md#timestamp-handling) |
| Old field names still work | Breaking old data | [Versioned data](data-modeling.md#versioned-data) |
| Concurrent updates don't lose data | Lost updates | [Mutex across operation](file-io.md#in-process-mutex-across-full-operation) |

### Example Test Suite

```rust
#[cfg(test)]
mod essential_tests {
    use super::*;

    #[test]
    fn rejects_missing_version_marker() {
        let content = "### [#idea-ABC] No version marker\nStatus: open\n---\n";
        let result = parse_document(content);
        assert!(matches!(result, Err(ParseError::UnsupportedFormat { .. })));
    }

    #[test]
    fn empty_file_returns_empty_result() {
        let result = parse_document("").unwrap();
        assert!(result.blocks.is_empty());
    }

    #[test]
    fn metadata_in_body_not_parsed_as_field() {
        let content = r#"
### [#idea-ABC] Test
Status: open
---
This body mentions Status: done but it's not metadata
"#;
        let parsed = parse_document(content).unwrap();
        let block = &parsed.blocks[0];

        assert_eq!(block.get_field("Status"), Some("open"));
        assert!(block.body.contains("Status: done"));
    }

    #[test]
    fn update_only_affects_target_block() {
        let content = r#"
### [#idea-AAA] First
Status: open
---

### [#idea-BBB] Second
Status: open
---
"#;
        let updated = update_block_field(content, "AAA", "Status", "done");
        let parsed = parse_document(&updated).unwrap();

        assert_eq!(parsed.blocks[0].get_field("Status"), Some("done"));
        assert_eq!(parsed.blocks[1].get_field("Status"), Some("open"));
    }
}
```

---

## Quality Tools

### Pre-Commit Checks

All code should pass before commit:

```bash
cargo fmt --check
cargo clippy -- -D warnings
cargo test
```

### Strict Clippy Lints

For library code, add to `Cargo.toml`:

```toml
[lints.clippy]
unwrap_used = "warn"
expect_used = "warn"
panic = "warn"
indexing_slicing = "warn"
```

**Note**: `unwrap_used` will warn on `Regex::new(...).unwrap()`. Use `#[allow(clippy::unwrap_used)]` locally for known-good cases, or use `.expect("reason")`:

```rust
use std::sync::LazyLock;
use regex::Regex;

static HEADING_RE: LazyLock<Regex> = LazyLock::new(|| {
    #[allow(clippy::unwrap_used)]  // Regex is compile-time constant
    Regex::new(r"^### \[#idea-([0-9A-Z]+)\]").unwrap()
});
```

### Test Edge Cases

Parsers and string processing should be tested with:

- Empty strings
- Strings that are all whitespace
- Very long lines (> 10KB)
- Mixed line endings (`\n`, `\r\n`, `\r`)
- UTF-8 edge cases (emoji, combining characters, RTL text)
- Embedded NUL bytes (if accepting `&[u8]`)
- BOM at start of file
