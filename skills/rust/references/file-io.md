# File I/O & Persistence

Patterns for durable writes, concurrency, and file watching.

## Table of Contents

- [Atomic Writes](#atomic-writes)
- [Concurrency Control](#concurrency-control)
- [File Watching](#file-watching)
- [When NOT to Use Atomic Writes](#when-not-to-use-atomic-writes)

---

## Atomic Writes

Write to temp file, sync to disk, then rename:

```rust
use std::{io::Write, path::Path};
use tempfile::NamedTempFile;

fn atomic_write(path: &Path, contents: &str) -> std::io::Result<()> {
    // Create temp file in SAME directory as target.
    // Why: rename() fails across filesystem boundaries.
    let dir = path.parent().unwrap_or_else(|| Path::new("."));
    let mut tmp = NamedTempFile::new_in(dir)?;

    tmp.write_all(contents.as_bytes())?;
    tmp.flush()?;

    // Critical: ensure OS flushes to disk BEFORE rename.
    // Without this, power loss after rename could leave truncated file.
    tmp.as_file().sync_all()?;

    tmp.persist(path).map(|_| ()).map_err(|e| e.error)
}
```

**Durable-First Invariant**: Never gate persistence on validation or subprocess output:

1. Write raw data to storage (e.g., `status: pending`)
2. Return control immediately
3. Async enrichment updates later (or not at all)

---

## Concurrency Control

### In-Process: Mutex Across Full Operation

A `Mutex` protects the in-memory state, but the lock must span the **entire** read-modify-write cycle:

```rust
use std::sync::Mutex;
use std::path::Path;

struct FileState {
    data: MyData,
}

static STATE: Mutex<FileState> = Mutex::new(FileState { data: MyData::default() });

fn update_file(path: &Path, change: Change) -> std::io::Result<()> {
    // Lock held from read through write
    let mut state = STATE.lock().unwrap();

    // Re-read file to get latest (another process may have changed it)
    let current = std::fs::read_to_string(path)?;
    let mut data: MyData = serde_json::from_str(&current)?;

    // Apply change
    data.apply(change);

    // Write back atomically
    atomic_write(path, &serde_json::to_string_pretty(&data)?)?;

    // Update in-memory state
    state.data = data;

    Ok(())
    // Lock released here
}
```

**Bug this prevents**: Without holding the lock across the full operation:

1. Thread A reads file, releases lock
2. Thread B reads file, releases lock
3. Thread A writes changes
4. Thread B writes changes → **Thread A's changes lost**

### Out-of-Process: Advisory Locking

For coordination between separate processes, use advisory locks via `fs2`:

```rust
use fs2::FileExt;
use std::fs::File;

fn with_file_lock<T>(path: &Path, f: impl FnOnce() -> T) -> std::io::Result<T> {
    let lock_file = File::create(path.with_extension("lock"))?;
    lock_file.lock_exclusive()?;  // Blocks until lock acquired

    let result = f();

    lock_file.unlock()?;
    Ok(result)
}
```

**Platform caveats** (document if using advisory locks):

| Platform | Caveat |
|----------|--------|
| NFS | Advisory locks unreliable or unsupported depending on configuration |
| macOS | `flock` locks are per-process, not per-file-descriptor |
| Windows | Different locking semantics; consider `LockFileEx` |

If advisory locking is too complex, prefer merge-friendly designs:

1. Re-read file immediately before write
2. Apply patch to latest parsed model
3. Write back atomically
4. Accept that last-writer-wins on conflicts

---

## File Watching

Use debounced file watchers for external edit detection:

```rust
use notify::{Watcher, RecursiveMode, watcher};
use std::sync::mpsc::channel;
use std::time::Duration;

fn watch_file(path: &Path) -> notify::Result<()> {
    let (tx, rx) = channel();

    // Debounce: editors save via multiple quick writes (temp + rename)
    let mut watcher = watcher(tx, Duration::from_millis(200))?;
    watcher.watch(path, RecursiveMode::NonRecursive)?;

    loop {
        match rx.recv() {
            Ok(event) => {
                // Re-parse file and compute diff
                // Send "data changed" notification (avoid huge payloads)
            }
            Err(e) => break,
        }
    }
    Ok(())
}
```

**Threading model**: The watcher thread should only push events. A separate model thread owns the data and processes events via channel. This avoids shared mutable state.

---

## When NOT to Use Atomic Writes

Atomic writes aren't always the right choice:

| Scenario | Better Approach |
|----------|-----------------|
| Append-only logs | Direct append with `fsync` |
| Large files, small updates | In-place modification with record locking |
| Write-ahead logs | Append + checkpoint |
| Streaming data | Buffered writes with periodic sync |

For append-only patterns:

```rust
use std::fs::OpenOptions;
use std::io::Write;

fn append_log(path: &Path, entry: &str) -> std::io::Result<()> {
    let mut file = OpenOptions::new()
        .create(true)
        .append(true)
        .open(path)?;

    writeln!(file, "{}", entry)?;
    file.sync_all()?;  // Ensure durability
    Ok(())
}
```
