# Process & System Integration

Patterns for PID verification, subprocess handling, and timestamps.

## Table of Contents

- [PID Liveness vs Identity](#pid-liveness-vs-identity)
- [Process Start Time](#process-start-time)
- [Subprocess Integration](#subprocess-integration)
- [Timestamp Handling](#timestamp-handling)
- [Async Considerations](#async-considerations)

---

## PID Liveness vs Identity

`kill(pid, 0)` checks if a PID exists, **not** if it's the same process. PID reuse creates "ghost" sessions where you think you're talking to process A but the PID was recycled to process B.

**Solution**: Store and verify process start time alongside PID:

```rust
pub fn is_pid_alive_verified(pid: u32, expected_start: Option<u64>) -> bool {
    let Some(expected) = expected_start else {
        // Legacy data without start time—use fallback
        return is_pid_alive_legacy(pid);
    };

    match get_process_start_time(pid) {
        Some(actual) => actual == expected,
        None => false,  // Process doesn't exist
    }
}

fn is_pid_alive_legacy(pid: u32) -> bool {
    // Fallback: existence check only (prone to PID reuse bugs)
    unsafe { libc::kill(pid as i32, 0) == 0 }
}
```

### Legacy Mitigation

For legacy data without `proc_started`, use defense-in-depth:

1. **Existence check**: `kill(pid, 0)` as baseline
2. **Identity heuristic**: Process name contains expected string (e.g., "claude")
3. **Age expiry**: Expire unverified entries after 24h

```rust
fn is_legacy_pid_valid(pid: u32, expected_name: &str, max_age: Duration, created_at: u64) -> bool {
    if !is_pid_alive_legacy(pid) {
        return false;
    }

    // Check process name matches expected
    if let Some(name) = get_process_name(pid) {
        if !name.to_lowercase().contains(&expected_name.to_lowercase()) {
            return false;
        }
    }

    // Expire old entries
    let age = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs()
        .saturating_sub(created_at);

    age < max_age.as_secs()
}
```

---

## Process Start Time

Cache `sysinfo::System` to avoid repeated expensive allocations. Use shared state, not thread-local:

```rust
use std::sync::{LazyLock, Mutex};
use sysinfo::{Pid, ProcessRefreshKind, RefreshKind, System};

static SYSTEM_CACHE: LazyLock<Mutex<System>> = LazyLock::new(|| {
    Mutex::new(System::new_with_specifics(
        RefreshKind::new().with_processes(ProcessRefreshKind::new()),
    ))
});

pub fn get_process_start_time(pid: u32) -> Option<u64> {
    let mut sys = SYSTEM_CACHE.lock().unwrap();
    sys.refresh_processes_specifics(ProcessRefreshKind::new());
    sys.process(Pid::from(pid as usize)).map(|p| p.start_time())
}

pub fn get_process_name(pid: u32) -> Option<String> {
    let mut sys = SYSTEM_CACHE.lock().unwrap();
    sys.refresh_processes_specifics(ProcessRefreshKind::new());
    sys.process(Pid::from(pid as usize)).map(|p| p.name().to_string_lossy().into_owned())
}
```

**Note**: The cache accumulates process data that never clears. For long-running daemons processing many PIDs, consider periodic `sys.refresh_all()` or dropping/recreating the System.

---

## Subprocess Integration

Treat subprocess output as **hostile input**. Always:

1. Set timeouts
2. Handle non-UTF-8 output
3. Capture stderr for error context

### With Timeout (using wait-timeout crate)

```rust
use std::process::{Command, Stdio, Child};
use std::io::Write;
use std::time::Duration;
use wait_timeout::ChildExt;

#[derive(thiserror::Error, Debug)]
pub enum SubprocessError {
    #[error("failed to spawn: {0}")]
    Spawn(#[source] std::io::Error),

    #[error("failed to write stdin: {0}")]
    Stdin(#[source] std::io::Error),

    #[error("timed out after {0:?}")]
    Timeout(Duration),

    #[error("exited with {code:?}: {stderr}")]
    NonZeroExit { code: Option<i32>, stderr: String },

    #[error("output not valid UTF-8")]
    InvalidUtf8(#[source] std::str::Utf8Error),
}

pub fn run_subprocess(
    cmd: &str,
    args: &[&str],
    stdin_payload: &str,
    timeout: Duration,
) -> Result<String, SubprocessError> {
    let mut child = Command::new(cmd)
        .args(args)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .map_err(SubprocessError::Spawn)?;

    // Write stdin and close it
    if let Some(mut stdin) = child.stdin.take() {
        stdin.write_all(stdin_payload.as_bytes())
            .map_err(SubprocessError::Stdin)?;
    }

    // Wait with timeout
    match child.wait_timeout(timeout).map_err(SubprocessError::Spawn)? {
        Some(status) => {
            let output = child.wait_with_output().map_err(SubprocessError::Spawn)?;

            if !status.success() {
                return Err(SubprocessError::NonZeroExit {
                    code: status.code(),
                    stderr: String::from_utf8_lossy(&output.stderr).into_owned(),
                });
            }

            String::from_utf8(output.stdout)
                .map_err(|e| SubprocessError::InvalidUtf8(e.utf8_error()))
        }
        None => {
            // Timed out—kill the process
            let _ = child.kill();
            Err(SubprocessError::Timeout(timeout))
        }
    }
}
```

### Handling Non-UTF-8 Output

If the subprocess might emit non-UTF-8 (binary data, different encoding):

```rust
// Lossy: replace invalid sequences with replacement character
let output = String::from_utf8_lossy(&output.stdout).into_owned();

// Strict with context
let output = String::from_utf8(output.stdout)
    .map_err(|e| SubprocessError::InvalidUtf8(e.utf8_error()))?;
```

---

## Timestamp Handling

The #1 timestamp bug: **unit mismatch** (seconds vs milliseconds).

### Normalization

```rust
const MS_THRESHOLD: u64 = 1_000_000_000_000;  // ~31,688 years in ms

fn normalize_epoch_to_secs(v: u64) -> u64 {
    if v >= MS_THRESHOLD { v / 1000 } else { v }
}

fn normalize_epoch_to_ms(v: u64) -> u64 {
    if v < MS_THRESHOLD { v * 1000 } else { v }
}
```

### Safe Arithmetic

Use `saturating_sub` to prevent underflow:

```rust
let now = SystemTime::now()
    .duration_since(UNIX_EPOCH)
    .unwrap()
    .as_secs();

let age_secs = now.saturating_sub(created_at);
```

### ISO Timestamp Parsing

For legacy data with string timestamps:

```rust
fn parse_rfc3339_to_secs(s: &str) -> Option<u64> {
    chrono::DateTime::parse_from_rfc3339(s)
        .ok()
        .map(|dt| dt.timestamp() as u64)
}
```

---

## Async Considerations

This guide focuses on **synchronous** patterns. For async subprocess handling:

- Use `tokio::process::Command` instead of `std::process::Command`
- Timeout via `tokio::time::timeout`
- Consider `async-process` crate for async-std

Example with tokio:

```rust
use tokio::process::Command;
use tokio::time::{timeout, Duration};

async fn run_subprocess_async(
    cmd: &str,
    args: &[&str],
    timeout_duration: Duration,
) -> Result<String, SubprocessError> {
    let output = timeout(
        timeout_duration,
        Command::new(cmd)
            .args(args)
            .output()
    )
    .await
    .map_err(|_| SubprocessError::Timeout(timeout_duration))?
    .map_err(SubprocessError::Spawn)?;

    if !output.status.success() {
        return Err(SubprocessError::NonZeroExit {
            code: output.status.code(),
            stderr: String::from_utf8_lossy(&output.stderr).into_owned(),
        });
    }

    String::from_utf8(output.stdout)
        .map_err(|e| SubprocessError::InvalidUtf8(e.utf8_error()))
}
```

For async file I/O, see [tokio::fs](https://docs.rs/tokio/latest/tokio/fs/) or [async-std::fs](https://docs.rs/async-std/latest/async_std/fs/).
