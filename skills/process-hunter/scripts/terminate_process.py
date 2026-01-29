#!/usr/bin/env python3
"""
Terminate a process gracefully, with fallback to force kill.

Usage:
    python terminate_process.py <pid> [--force]

Sends SIGTERM first, waits 3 seconds, then SIGKILL if still running.
"""

import subprocess
import sys
import time
import signal
import os
import argparse


def get_process_name(pid: int) -> str | None:
    """Get process name for a PID."""
    try:
        result = subprocess.run(
            ["ps", "-p", str(pid), "-o", "comm="],
            capture_output=True, text=True
        )
        return result.stdout.strip() or None
    except Exception:
        return None


def is_running(pid: int) -> bool:
    """Check if a process is still running."""
    try:
        os.kill(pid, 0)  # Signal 0 just checks existence
        return True
    except OSError:
        return False


def terminate(pid: int, force: bool = False) -> tuple[bool, str]:
    """
    Terminate a process.

    Returns (success, message)
    """
    name = get_process_name(pid)
    if not name:
        return False, f"Process {pid} not found or already terminated"

    if force:
        try:
            os.kill(pid, signal.SIGKILL)
            return True, f"Force killed {name} (PID {pid})"
        except PermissionError:
            return False, f"Permission denied killing {name} (PID {pid})"
        except OSError as e:
            return False, f"Error killing {name}: {e}"

    # Graceful termination: SIGTERM, wait, then SIGKILL
    try:
        os.kill(pid, signal.SIGTERM)
        print(f"Sent SIGTERM to {name} (PID {pid}), waiting...")

        # Wait up to 3 seconds for graceful shutdown
        for _ in range(6):
            time.sleep(0.5)
            if not is_running(pid):
                return True, f"Gracefully terminated {name} (PID {pid})"

        # Still running, force kill
        os.kill(pid, signal.SIGKILL)
        time.sleep(0.5)

        if not is_running(pid):
            return True, f"Force killed {name} (PID {pid}) after SIGTERM failed"
        else:
            return False, f"Failed to kill {name} (PID {pid})"

    except PermissionError:
        return False, f"Permission denied terminating {name} (PID {pid})"
    except OSError as e:
        return False, f"Error terminating {name}: {e}"


def main():
    parser = argparse.ArgumentParser(description="Terminate a process")
    parser.add_argument("pid", type=int, help="Process ID to terminate")
    parser.add_argument("--force", action="store_true",
                        help="Skip graceful shutdown, force kill immediately")
    args = parser.parse_args()

    success, message = terminate(args.pid, args.force)
    print(message)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
