#!/usr/bin/env python3
"""
Measure system power consumption before/after process cleanup.

Usage:
    python measure_power.py before   # Save baseline
    python measure_power.py after    # Compare to baseline
    python measure_power.py report   # Show impact report (auto-detects baseline)
    python measure_power.py status   # Current battery info
"""

import subprocess
import json
import sys
import re
from pathlib import Path
from datetime import datetime

BASELINE_FILE = Path("/tmp/process_hunter_power_baseline.json")


def get_battery_icon(percentage: int, width: int = 20) -> str:
    """Generate ASCII battery with fill level."""
    fill = int((percentage / 100) * width)
    empty = width - fill

    # Choose fill character based on level
    if percentage > 60:
        fill_char = "█"
        status = "▓"
    elif percentage > 30:
        fill_char = "▓"
        status = "▒"
    else:
        fill_char = "▒"
        status = "░"

    bar = fill_char * fill + "░" * empty
    return f"[{bar}]"


def get_battery_art(percentage: int, improved: bool = False) -> str:
    """Generate fancy ASCII battery."""
    fill = int((percentage / 100) * 10)

    if improved:
        spark = "⚡"
        corners = ("╔", "╗", "╚", "╝", "║", "═")
    else:
        spark = "🔋"
        corners = ("┌", "┐", "└", "┘", "│", "─")

    tl, tr, bl, br, v, h = corners

    # Build battery
    lines = []
    lines.append(f"     {tl}{h*12}{tr}┐")
    lines.append(f"     {v} {percentage:>3}%  {spark}  {v}│")
    lines.append(f"     {v} {get_battery_icon(percentage, 10)} {v}│")
    lines.append(f"     {bl}{h*12}{br}┘")

    return "\n".join(lines)


def get_comparison_art(before_min: int, after_min: int) -> str:
    """Generate ASCII art showing the time improvement."""
    diff = after_min - before_min

    if diff > 30:
        art = """
    ╭──────────────────────────────────────────╮
    │  🚀 MASSIVE IMPROVEMENT 🚀               │
    │                                          │
    │     BEFORE          AFTER                │
    │    ┌──────┐       ┌──────┐              │
    │    │{before:^6}│  >>>  │{after:^6}│   +{diff} min  │
    │    └──────┘       └──────┘              │
    │                                          │
    │  ✨ Your battery will thank you! ✨      │
    ╰──────────────────────────────────────────╯
"""
    elif diff > 10:
        art = """
    ╭────────────────────────────────────────╮
    │  ⚡ NICE IMPROVEMENT ⚡                 │
    │                                        │
    │   {before:>5} min  ──────►  {after:>5} min       │
    │                                        │
    │   Battery life extended by +{diff} min   │
    ╰────────────────────────────────────────╯
"""
    elif diff > 0:
        art = """
    ╭────────────────────────────────────────╮
    │  ✓ Slight improvement                  │
    │   {before:>5} min  ──►  {after:>5} min (+{diff} min)  │
    ╰────────────────────────────────────────╯
"""
    elif diff == 0:
        art = """
    ╭────────────────────────────────────────╮
    │  ➡️  No change in battery estimate      │
    │     (may take a minute to update)      │
    ╰────────────────────────────────────────╯
"""
    else:
        art = """
    ╭────────────────────────────────────────╮
    │  ⚠️  Battery estimate dropped           │
    │   {before:>5} min  ──►  {after:>5} min ({diff} min)   │
    │   (This can happen during recalc)      │
    ╰────────────────────────────────────────╯
"""

    return art.format(before=before_min, after=after_min, diff=diff)


def get_process_kill_art(killed_count: int, mem_freed_gb: float) -> str:
    """Generate ASCII art celebrating the kills."""
    if killed_count == 0:
        return ""

    skulls = "💀" * min(killed_count, 5)

    return f"""
    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃  {skulls:^37}  ┃
    ┃                                         ┃
    ┃   Processes Terminated: {killed_count:>3}              ┃
    ┃   Memory Freed: ~{mem_freed_gb:.1f} GB                 ┃
    ┃                                         ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
"""


def get_battery_info() -> dict:
    """Get current battery status from pmset."""
    result = subprocess.run(["pmset", "-g", "batt"], capture_output=True, text=True)
    output = result.stdout

    info = {
        "timestamp": datetime.now().isoformat(),
        "percentage": None,
        "status": None,
        "time_remaining": None,
        "raw": output.strip(),
    }

    pct_match = re.search(r"(\d+)%", output)
    if pct_match:
        info["percentage"] = int(pct_match.group(1))

    if "discharging" in output.lower():
        info["status"] = "discharging"
    elif "charging" in output.lower():
        info["status"] = "charging"
    elif "charged" in output.lower():
        info["status"] = "charged"
    elif "AC Power" in output:
        info["status"] = "ac_power"

    time_match = re.search(r"(\d+:\d+) remaining", output)
    if time_match:
        info["time_remaining"] = time_match.group(1)
        h, m = map(int, time_match.group(1).split(":"))
        info["time_remaining_minutes"] = h * 60 + m

    return info


def get_top_cpu_processes(n: int = 5) -> list:
    """Get top N CPU-consuming processes."""
    result = subprocess.run(
        ["ps", "-eo", "pid,pcpu,rss,comm", "-r"],
        capture_output=True, text=True
    )
    processes = []
    for line in result.stdout.strip().split("\n")[1:n+1]:
        parts = line.split(None, 3)
        if len(parts) >= 4:
            processes.append({
                "pid": int(parts[0]),
                "cpu": float(parts[1]),
                "mem_mb": float(parts[2]) / 1024,
                "name": parts[3],
            })
    return processes


def save_baseline(processes_killed: int = 0, mem_freed_mb: float = 0):
    """Save current state as baseline."""
    data = {
        "battery": get_battery_info(),
        "top_processes": get_top_cpu_processes(),
        "processes_killed": processes_killed,
        "mem_freed_mb": mem_freed_mb,
    }
    BASELINE_FILE.write_text(json.dumps(data, indent=2))

    print("\n    ╔═══════════════════════════════════╗")
    print("    ║   📊 BASELINE SAVED               ║")
    print("    ╠═══════════════════════════════════╣")
    print(f"    ║   Battery: {data['battery']['percentage']:>3}%                  ║")
    if data['battery']['time_remaining']:
        print(f"    ║   Remaining: {data['battery']['time_remaining']:>5}              ║")
    print("    ╚═══════════════════════════════════╝")
    print("\n    💡 Run cleanup, then 'measure_power.py after'")


def show_impact_report(processes_killed: int = 0, mem_freed_mb: float = 0):
    """Show a cool impact report after killing processes."""
    has_baseline = BASELINE_FILE.exists()

    current = get_battery_info()
    current_procs = get_top_cpu_processes()

    mem_freed_gb = mem_freed_mb / 1024 if mem_freed_mb > 0 else 0

    # Header
    print("\n")
    print("    ╔════════════════════════════════════════════════════╗")
    print("    ║          ⚡ PROCESS HUNTER REPORT ⚡               ║")
    print("    ╚════════════════════════════════════════════════════╝")

    # Kill stats
    if processes_killed > 0:
        print(get_process_kill_art(processes_killed, mem_freed_gb))

    # Battery comparison if we have baseline
    if has_baseline:
        baseline = json.loads(BASELINE_FILE.read_text())
        before = baseline['battery']
        after = current

        before_min = before.get('time_remaining_minutes', 0)
        after_min = after.get('time_remaining_minutes', 0)

        if before_min and after_min:
            print(get_comparison_art(before_min, after_min))

        # Process comparison
        print("\n    ┌─── CPU BEFORE ────────┬─── CPU AFTER ─────────┐")
        before_procs = baseline.get('top_processes', [])[:3]
        after_procs = current_procs[:3]

        for i in range(max(len(before_procs), len(after_procs))):
            b = before_procs[i] if i < len(before_procs) else {"cpu": 0, "name": "-"}
            a = after_procs[i] if i < len(after_procs) else {"cpu": 0, "name": "-"}
            b_str = f"{b['cpu']:>5.1f}% {b['name'][:12]:<12}"
            a_str = f"{a['cpu']:>5.1f}% {a['name'][:12]:<12}"
            print(f"    │ {b_str} │ {a_str} │")

        print("    └───────────────────────┴───────────────────────┘")

        # Total CPU reduction
        before_total = sum(p['cpu'] for p in before_procs)
        after_total = sum(p['cpu'] for p in after_procs)
        reduction = before_total - after_total

        if reduction > 0:
            print(f"\n    📉 Top-3 CPU usage: {before_total:.0f}% → {after_total:.0f}% (↓{reduction:.0f}%)")

    # Current battery status
    improved = has_baseline and processes_killed > 0
    print("\n" + get_battery_art(current['percentage'], improved=improved))

    if current['time_remaining']:
        print(f"\n    ⏱️  Time remaining: {current['time_remaining']}")

    # Footer
    print("\n    ════════════════════════════════════════════════════")
    if processes_killed > 0:
        print("    🌱 Your MacBook is breathing easier now!")
    print("")


def compare_to_baseline():
    """Compare current state to saved baseline."""
    if not BASELINE_FILE.exists():
        print("❌ No baseline found. Run 'python measure_power.py before' first.")
        return

    baseline = json.loads(BASELINE_FILE.read_text())
    show_impact_report(
        processes_killed=baseline.get('processes_killed', 0),
        mem_freed_mb=baseline.get('mem_freed_mb', 0)
    )


def show_status():
    """Show current battery status."""
    info = get_battery_info()
    print("\n" + get_battery_art(info['percentage']))
    print(f"\n    Status: {info['status']}")
    if info['time_remaining']:
        print(f"    Time remaining: {info['time_remaining']}")
    print("")


def main():
    if len(sys.argv) < 2:
        show_status()
        return

    cmd = sys.argv[1].lower()

    if cmd == "before":
        # Optional: pass killed count and mem freed
        killed = int(sys.argv[2]) if len(sys.argv) > 2 else 0
        mem = float(sys.argv[3]) if len(sys.argv) > 3 else 0
        save_baseline(killed, mem)
    elif cmd == "after":
        compare_to_baseline()
    elif cmd == "report":
        # report <killed_count> <mem_freed_mb>
        killed = int(sys.argv[2]) if len(sys.argv) > 2 else 0
        mem = float(sys.argv[3]) if len(sys.argv) > 3 else 0
        show_impact_report(killed, mem)
    elif cmd == "status":
        show_status()
    else:
        print(f"Unknown command: {cmd}")
        print(__doc__)


if __name__ == "__main__":
    main()
