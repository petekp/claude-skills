# Data Modeling

Patterns for Serde serialization, FFI boundaries, and type safety.

## Table of Contents

- [Strong Types Over Strings](#strong-types-over-strings)
- [Serde Patterns](#serde-patterns)
- [UniFFI Boundaries](#uniffi-boundaries)
- [Lookup by Primary Key](#lookup-by-primary-key)

---

## Strong Types Over Strings

Strings for status/effort/triage lead to case-mismatch bugs. Use enums:

```rust
#[derive(Clone, Debug, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "snake_case")]
pub enum Status { Open, InProgress, Done, Dismissed }

#[derive(Clone, Debug, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "snake_case")]
pub enum Priority { P0, P1, P2, P3 }
```

**Naming convention**: `rename_all = "snake_case"` serializes `InProgress` as `"in_progress"`. For JSON APIs expecting camelCase, use `rename_all = "camelCase"`.

---

## Serde Patterns

### Versioned Data

When adding fields to serialized structures, old data won't have them:

```rust
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LockInfo {
    pub pid: u32,
    pub path: String,

    #[serde(default)]
    pub proc_started: Option<u64>,  // New field - absent in old data

    #[serde(default, alias = "started")]
    pub created: Option<u64>,       // Supports old field name
}
```

**Key patterns**:

| Attribute | Purpose | Read/Write |
|-----------|---------|------------|
| `#[serde(default)]` | Missing fields deserialize as `Default::default()` | Read |
| `#[serde(alias = "old")]` | Accept old field name | Read only |
| `#[serde(rename = "new")]` | Write as different name | Write |
| `#[serde(skip_serializing_if = "Option::is_none")]` | Omit `None` values | Write |

**Important**: `alias` is **read-only**. If writing data that old code will read, use `rename`:

```rust
// Old code expects "started", new code uses "created"
#[serde(default, rename = "started")]  // Writes as "started"
pub created: Option<u64>,

// Or be explicit about asymmetry
#[serde(default, alias = "started", rename = "created")]
pub created: Option<u64>,  // Reads both, writes as "created"
```

### Strict External Input

For data from untrusted sources, use `deny_unknown_fields` to catch typos:

```rust
#[derive(Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct ExternalConfig {
    pub api_key: String,
    pub endpoint: String,
    // Typo like "endpont" will error instead of silently using default
}
```

### Sentinel Values

If spec uses sentinel strings (e.g., `Related: None`) but your type is `Option<String>`:

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

For serde integration, use a custom deserializer:

```rust
fn deserialize_optional_sentinel<'de, D>(deserializer: D) -> Result<Option<String>, D::Error>
where
    D: serde::Deserializer<'de>,
{
    let s: Option<String> = Option::deserialize(deserializer)?;
    Ok(s.and_then(|v| {
        let t = v.trim();
        if t.is_empty() || t.eq_ignore_ascii_case("none") {
            None
        } else {
            Some(t.to_string())
        }
    }))
}
```

---

## UniFFI Boundaries

UniFFI works best with flat, stable types. Keep DTOs separate from domain models.

### Basic DTO Pattern

```rust
// Internal domain model (expressive)
pub struct Idea {
    pub id: Uuid,
    pub created_at: DateTime<Utc>,
    pub status: Status,
    pub priority: Option<Priority>,
}

// FFI DTO (flat, stable)
#[derive(Clone, Debug, uniffi::Record)]
pub struct IdeaDto {
    pub id: String,           // Uuid → String at boundary
    pub created_at_ms: i64,   // DateTime → epoch ms
    pub status: String,       // Or use uniffi::Enum
    pub priority: Option<String>,
}

impl From<Idea> for IdeaDto {
    fn from(idea: Idea) -> Self {
        Self {
            id: idea.id.to_string(),
            created_at_ms: idea.created_at.timestamp_millis(),
            status: format!("{:?}", idea.status).to_lowercase(),
            priority: idea.priority.map(|p| format!("{:?}", p).to_lowercase()),
        }
    }
}
```

### Enums vs Strings

**Use `uniffi::Enum`** for closed sets where type safety matters:

```rust
#[derive(Clone, Debug, uniffi::Enum)]
pub enum StatusDto {
    Open,
    InProgress,
    Done,
    Dismissed,
    #[uniffi(default)]
    Unknown { value: String },  // Forward-compatible
}
```

The `#[uniffi(default)]` variant handles unknown values gracefully—foreign code receives `Unknown` instead of crashing on new variants.

**Use strings** when:
- The set is truly open-ended
- You can't regenerate bindings when adding variants
- Stability trumps type safety

### What to Avoid in FFI

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| `Uuid` | Not FFI-friendly | `String` |
| `DateTime<Utc>` | Complex type | `i64` (epoch ms) |
| Enums with data | Limited support | Flat enums or separate fields |
| Nested structs | Harder to maintain | Flatten or separate calls |
| `HashMap` | Limited in some targets | `Vec<(K, V)>` |

---

## Lookup by Primary Key

Use the resolved record's **primary key** for subsequent lookups, not secondary attributes:

```rust
// BAD: Secondary lookup could return different record
let resolved = resolve_state(&store, project_path)?;
let record = store.find_by_cwd(&resolved.cwd);  // Could match Session B!

// GOOD: Use the resolved session_id
let resolved = resolve_state(&store, project_path)?;
let record = resolved.session_id
    .as_deref()
    .and_then(|id| store.get_by_session_id(id));
```

**Why this matters**: Secondary attributes (like `cwd`) can match multiple records. After resolving to a specific record, always use its unique identifier for subsequent operations to avoid TOCTOU (time-of-check-to-time-of-use) bugs.
