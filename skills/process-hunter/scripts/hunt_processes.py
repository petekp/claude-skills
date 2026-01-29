#!/usr/bin/env python3
"""
Process Hunter - Find and categorize resource-hungry processes.

Usage:
    python hunt_processes.py [--cpu-threshold PCT] [--mem-threshold MB] [--json]

Output:
    Lists processes exceeding thresholds, categorized as:
    - AUTO_KILL: Known safe-to-terminate patterns
    - ASK: Suspicious but needs user confirmation
    - IGNORE: System processes that should not be touched
"""

import subprocess
import re
import json
import argparse
from dataclasses import dataclass
from typing import Literal

# Known patterns for auto-kill (orphan dev servers, duplicate instances)
AUTO_KILL_PATTERNS = [
    # Next.js / Node dev servers
    (r"node.*next.*dev", "Next.js dev server"),
    (r"node.*webpack.*dev", "Webpack dev server"),
    (r"node.*vite", "Vite dev server"),
    (r"node.*turbo", "Turbopack dev server"),
    (r"npm.*run.*dev", "npm dev script"),
    (r"yarn.*dev", "yarn dev script"),
    (r"pnpm.*dev", "pnpm dev script"),

    # React Native / Expo
    (r"node.*react-native", "React Native bundler"),
    (r"node.*expo", "Expo dev server"),

    # Multiple Claude instances (keep one, suggest killing others)
    (r"claude", "Claude Code session"),

    # Stale build processes
    (r"node.*esbuild", "esbuild process"),
    (r"node.*rollup", "Rollup bundler"),
    (r"tsc.*--watch", "TypeScript watch"),
]

# System processes - NEVER touch these
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
    """Get processes exceeding resource thresholds."""
    # ps command that works on macOS and Linux
    cmd = ["ps", "-eo", "pid,pcpu,rss,comm,args"]
    result = subprocess.run(cmd, capture_output=True, text=True)

    processes = []
    for line in result.stdout.strip().split("\n")[1:]:  # Skip header
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

        # Skip if below thresholds
        if cpu < cpu_threshold and mem_mb < mem_threshold:
            continue

        # Skip our own process
        if "hunt_processes" in command:
            continue

        # Categorize
        category, reason = categorize_process(name, command)

        processes.append(ProcessInfo(
            pid=pid,
            name=name,
            cpu_percent=cpu,
            mem_mb=mem_mb,
            command=command[:100],  # Truncate long commands
            category=category,
            reason=reason,
        ))

    # Sort by CPU + memory impact
    processes.sort(key=lambda p: p.cpu_percent + (p.mem_mb / 100), reverse=True)
    return processes


def categorize_process(name: str, command: str) -> tuple[Category, str]:
    """Categorize a process based on known patterns."""
    full_str = f"{name} {command}".lower()

    # Check ignore patterns first
    for pattern in IGNORE_PATTERNS:
        if re.search(pattern, name, re.IGNORECASE):
            return "IGNORE", "System process"

    # Check auto-kill patterns
    for pattern, desc in AUTO_KILL_PATTERNS:
        if re.search(pattern, full_str, re.IGNORECASE):
            return "AUTO_KILL", desc

    # Everything else needs user confirmation
    return "ASK", "Unknown high-resource process"


def format_output(processes: list[ProcessInfo], as_json: bool) -> str:
    """Format process list for output."""
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

    # Human-readable format
    lines = []

    auto_kill = [p for p in processes if p.category == "AUTO_KILL"]
    ask = [p for p in processes if p.category == "ASK"]

    if auto_kill:
        lines.append("\n🎯 AUTO-KILL (safe to terminate):")
        lines.append("-" * 60)
        for p in auto_kill:
            lines.append(f"  PID {p.pid:>6} | CPU {p.cpu_percent:>5.1f}% | MEM {p.mem_mb:>6.1f}MB")
            lines.append(f"           | {p.reason}: {p.name}")

    if ask:
        lines.append("\n❓ NEEDS CONFIRMATION:")
        lines.append("-" * 60)
        for p in ask:
            lines.append(f"  PID {p.pid:>6} | CPU {p.cpu_percent:>5.1f}% | MEM {p.mem_mb:>6.1f}MB")
            lines.append(f"           | {p.command[:60]}")

    if not auto_kill and not ask:
        lines.append("\n✅ No resource-hungry processes found!")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="Hunt resource-hungry processes")
    parser.add_argument("--cpu-threshold", type=float, default=10.0,
                        help="CPU percentage threshold (default: 10)")
    parser.add_argument("--mem-threshold", type=float, default=500.0,
                        help="Memory threshold in MB (default: 500)")
    parser.add_argument("--json", action="store_true",
                        help="Output as JSON")
    args = parser.parse_args()

    processes = get_processes(args.cpu_threshold, args.mem_threshold)

    # Filter out IGNORE category for output
    visible = [p for p in processes if p.category != "IGNORE"]

    print(format_output(visible, args.json))


if __name__ == "__main__":
    main()
