#!/usr/bin/env python3
"""
CAVEMAN BONK TOOL - Me smash process good.

Usage:
    python terminate_process.py <pid> [--force]

Me try gentle tap first. If process no listen, ME USE BIG CLUB.
"""

import subprocess
import sys
import time
import signal
import os
import argparse


def get_process_name(pid: int) -> str | None:
    """Me look up name of creature."""
    try:
        result = subprocess.run(
            ["ps", "-p", str(pid), "-o", "comm="],
            capture_output=True, text=True
        )
        return result.stdout.strip() or None
    except Exception:
        return None


def is_running(pid: int) -> bool:
    """Me check if creature still breathing."""
    try:
        os.kill(pid, 0)
        return True
    except OSError:
        return False


def terminate(pid: int, force: bool = False) -> tuple[bool, str]:
    """
    ME BONK PROCESS.

    Return (success, grunt message)
    """
    name = get_process_name(pid)
    if not name:
        return False, f"🦴 Ugh! Process {pid} already gone. Maybe mammoth step on it?"

    if force:
        try:
            os.kill(pid, signal.SIGKILL)
            return True, f"💥 OOGA BOOGA! Me use BIG CLUB on {name} (PID {pid})! Process flat now."
        except PermissionError:
            return False, f"🚫 Grunt! Cave spirits say no touch {name} (PID {pid}). Need more shaman power."
        except OSError as e:
            return False, f"😵 Ugh! Something go wrong bonking {name}: {e}"

    # First try gentle tap, then BIG CLUB
    try:
        os.kill(pid, signal.SIGTERM)
        print(f"    👋 Me tap {name} (PID {pid}) gentle... 'Hey. You go now.'")
        print(f"    ⏳ Me wait...")

        for _ in range(6):
            time.sleep(0.5)
            if not is_running(pid):
                return True, f"    ✨ {name} listen to caveman! Walk away peaceful. Good process."

        # Still there? TIME FOR BIG CLUB
        print(f"    😤 Process no listen! ME GET BIG CLUB!")
        os.kill(pid, signal.SIGKILL)
        time.sleep(0.5)

        if not is_running(pid):
            return True, f"    💥 BONK! {name} (PID {pid}) no more. Should have listened first time!"
        else:
            return False, f"    😱 Impossible! {name} still alive after big club! Must be spirit!"

    except PermissionError:
        return False, f"    🚫 Cave spirits protect {name} (PID {pid}). Me not strong enough."
    except OSError as e:
        return False, f"    😵 Ugh! Me club hit rock instead: {e}"


def main():
    parser = argparse.ArgumentParser(description="Caveman bonk process")
    parser.add_argument("pid", type=int, help="Which creature to bonk")
    parser.add_argument("--force", action="store_true",
                        help="Skip gentle tap. Go straight to BIG CLUB.")
    args = parser.parse_args()

    print("")
    print("    🏏 CAVEMAN BONK TOOL")
    print("    " + "=" * 40)

    success, message = terminate(args.pid, args.force)
    print(message)
    print("")
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
