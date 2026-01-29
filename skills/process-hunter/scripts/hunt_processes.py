#!/usr/bin/env python3
"""
CAVEMAN PROCESS HUNTER - Me find bad process. Me tell you which bonk.

Usage:
    python hunt_processes.py [--cpu-threshold PCT] [--mem-threshold MB] [--json]

Output:
    Me sort process into pile:
    - BONK_NOW: Safe bonk. No ask. Just smash.
    - ASK_FIRST: Me not sure. You decide bonk or no bonk.
    - NO_TOUCH: Sacred spirit process. Touch bring bad juju.
"""

import subprocess
import re
import json
import argparse
from dataclasses import dataclass
from typing import Literal

# Process me know safe to bonk
AUTO_KILL_PATTERNS = [
    # Next.js - these eat MANY fire
    (r"next-server", "Next.js fire-eater"),
    (r"node.*next.*dev", "Next.js cave server"),
    (r"node.*webpack.*dev", "Webpack bundle-beast"),
    (r"node.*vite", "Vite speed-demon"),
    (r"node.*turbo", "Turbo thunder-lizard"),
    (r"npm.*run.*dev", "npm run-run process"),
    (r"yarn.*dev", "yarn spinny thing"),
    (r"pnpm.*dev", "pnpm tiny demon"),

    # React Native - also greedy
    (r"node.*react-native", "React Native bridge troll"),
    (r"node.*expo", "Expo magic box"),

    # Claude - too many clone bad
    (r"claude", "Claude brain-in-box"),

    # Build things
    (r"node.*esbuild", "esbuild fast-maker"),
    (r"node.*rollup", "Rollup bundle-roller"),
    (r"tsc.*--watch", "TypeScript watcher-eye"),
]

# SACRED PROCESSES - NEVER BONK OR BAD THING HAPPEN
IGNORE_PATTERNS = [
    r"^kernel_task$",
    r"^launchd$",
    r"^WindowServer$",
    r"^coreaudiod$",
    r"^loginwindow$",
    r"^Finder$",
    r"^Dock$",
    r"^SystemUIServer$",
    r"^mds_stores$",
    r"^mds$",
    r"^mdworker",
    r"^spotlight",
    r"^cfprefsd$",
    r"^distnoted$",
    r"^trustd$",
    r"^securityd$",
]

Category = Literal["AUTO_KILL", "ASK", "IGNORE"]


@dataclass
class ProcessInfo:
    pid: int
    name: str
    cpu_percent: float
    mem_mb: float
    command: str
    category: Category
    reason: str


def get_processes(cpu_threshold: float, mem_threshold: float) -> list[ProcessInfo]:
    """Me look at all process. Find greedy ones."""
    cmd = ["ps", "-eo", "pid,pcpu,rss,comm,args"]
    result = subprocess.run(cmd, capture_output=True, text=True)

    processes = []
    for line in result.stdout.strip().split("\n")[1:]:
        parts = line.split(None, 4)
        if len(parts) < 5:
            continue

        try:
            pid = int(parts[0])
            cpu = float(parts[1])
            mem_kb = float(parts[2])
            name = parts[3]
            command = parts[4] if len(parts) > 4 else name
        except (ValueError, IndexError):
            continue

        mem_mb = mem_kb / 1024

        if cpu < cpu_threshold and mem_mb < mem_threshold:
            continue

        if "hunt_processes" in command:
            continue

        category, reason = categorize_process(name, command)

        processes.append(ProcessInfo(
            pid=pid,
            name=name,
            cpu_percent=cpu,
            mem_mb=mem_mb,
            command=command[:100],
            category=category,
            reason=reason,
        ))

    processes.sort(key=lambda p: p.cpu_percent + (p.mem_mb / 100), reverse=True)
    return processes


def categorize_process(name: str, command: str) -> tuple[Category, str]:
    """Me decide: bonk, ask, or no touch."""
    full_str = f"{name} {command}".lower()

    for pattern in IGNORE_PATTERNS:
        if re.search(pattern, name, re.IGNORECASE):
            return "IGNORE", "Sacred spirit - NO TOUCH"

    for pattern, desc in AUTO_KILL_PATTERNS:
        if re.search(pattern, full_str, re.IGNORECASE):
            return "AUTO_KILL", desc

    return "ASK", "Mystery creature - me not know"


def format_output(processes: list[ProcessInfo], as_json: bool) -> str:
    """Make pretty output for human eye-holes."""
    if as_json:
        return json.dumps([{
            "pid": p.pid,
            "name": p.name,
            "cpu_percent": p.cpu_percent,
            "mem_mb": round(p.mem_mb, 1),
            "command": p.command,
            "category": p.category,
            "reason": p.reason,
        } for p in processes], indent=2)

    lines = []

    auto_kill = [p for p in processes if p.category == "AUTO_KILL"]
    ask = [p for p in processes if p.category == "ASK"]

    if auto_kill:
        lines.append("")
        lines.append("    🦴 BONK NOW! (me know these bad)")
        lines.append("    " + "~" * 50)
        for p in auto_kill:
            fire = "🔥" * min(int(p.cpu_percent / 20) + 1, 5)
            rocks = "🪨" * min(int(p.mem_mb / 500) + 1, 5)
            lines.append(f"      PID {p.pid:>6} │ Fire: {p.cpu_percent:>5.1f}% {fire}")
            lines.append(f"                  │ Rock: {p.mem_mb:>6.1f}MB {rocks}")
            lines.append(f"                  │ What: {p.reason}")
            lines.append(f"                  │ Name: {p.name}")
            lines.append("")

    if ask:
        lines.append("")
        lines.append("    🤔 ME NOT SURE! (you decide bonk)")
        lines.append("    " + "~" * 50)
        for p in ask:
            fire = "🔥" * min(int(p.cpu_percent / 20) + 1, 5)
            rocks = "🪨" * min(int(p.mem_mb / 500) + 1, 5)
            lines.append(f"      PID {p.pid:>6} │ Fire: {p.cpu_percent:>5.1f}% {fire}")
            lines.append(f"                  │ Rock: {p.mem_mb:>6.1f}MB {rocks}")
            lines.append(f"                  │ What: {p.command[:50]}")
            lines.append("")

    if not auto_kill and not ask:
        lines.append("")
        lines.append("    ✨ CAVE CLEAN! No greedy process found!")
        lines.append("    Me rest now. Zzzzz...")
        lines.append("")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="Caveman hunt bad process")
    parser.add_argument("--cpu-threshold", type=float, default=10.0,
                        help="How much fire before me notice (default: 10)")
    parser.add_argument("--mem-threshold", type=float, default=500.0,
                        help="How many rock before me notice (default: 500)")
    parser.add_argument("--json", action="store_true",
                        help="Fancy tribe format")
    args = parser.parse_args()

    print("")
    print("    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓")
    print("    ┃  🦣 CAVEMAN PROCESS HUNTER 🦣                    ┃")
    print("    ┃  ᕦ(ò_óˇ)ᕤ  Me find greedy process!              ┃")
    print("    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛")

    processes = get_processes(args.cpu_threshold, args.mem_threshold)
    visible = [p for p in processes if p.category != "IGNORE"]

    print(format_output(visible, args.json))


if __name__ == "__main__":
    main()
