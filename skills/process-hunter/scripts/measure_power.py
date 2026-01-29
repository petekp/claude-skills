#!/usr/bin/env python3
"""
CAVEMAN LIGHTNING JUICE CHECKER - Me watch magic box energy.

Usage:
    python measure_power.py before   # Remember how much juice before hunt
    python measure_power.py after    # See if cave have more juice now
    python measure_power.py report   # Show big celebration picture
    python measure_power.py status   # Quick peek at juice rock
"""

import subprocess
import json
import sys
import re
from pathlib import Path
from datetime import datetime

BASELINE_FILE = Path("/tmp/caveman_juice_memory.json")


def get_juice_bar(percentage: int, width: int = 20) -> str:
    """Make picture of juice level with cave painting."""
    fill = int((percentage / 100) * width)
    empty = width - fill

    if percentage > 60:
        fill_char = "█"
    elif percentage > 30:
        fill_char = "▓"
    else:
        fill_char = "▒"

    bar = fill_char * fill + "░" * empty
    return f"[{bar}]"


def get_battery_art(percentage: int, improved: bool = False) -> str:
    """Draw fancy lightning rock picture."""
    if improved:
        spark = "⚡"
        corners = ("╔", "╗", "╚", "╝", "║", "═")
    else:
        spark = "🪨"
        corners = ("┌", "┐", "└", "┘", "│", "─")

    tl, tr, bl, br, v, h = corners

    lines = []
    lines.append(f"     {tl}{h*12}{tr}┐")
    lines.append(f"     {v} {percentage:>3}%  {spark}  {v}│")
    lines.append(f"     {v} {get_juice_bar(percentage, 10)} {v}│")
    lines.append(f"     {bl}{h*12}{br}┘")

    return "\n".join(lines)


def get_comparison_art(before_min: int, after_min: int) -> str:
    """Make cave painting showing time victory."""
    diff = after_min - before_min

    if diff > 30:
        art = """
    ╭────────────────────────────────────────────╮
    │  🦣 MAMMOTH-SIZE VICTORY! 🦣                │
    │                                            │
    │      BEFORE           AFTER                │
    │     ┌──────┐        ┌──────┐              │
    │     │{before:^6}│  >>>  │{after:^6}│  +{diff} sun-moves│
    │     └──────┘        └──────┘              │
    │                                            │
    │  ✨ Lightning rock VERY happy! ✨          │
    │     Tribe can watch many more fire!        │
    ╰────────────────────────────────────────────╯
"""
    elif diff > 10:
        art = """
    ╭────────────────────────────────────────────╮
    │  🦴 GOOD HUNT! Caveman proud!              │
    │                                            │
    │   {before:>5} sun  ──────►  {after:>5} sun           │
    │                                            │
    │   Lightning rock last +{diff} more sun-moves! │
    ╰────────────────────────────────────────────╯
"""
    elif diff > 0:
        art = """
    ╭────────────────────────────────────────────╮
    │  👍 Little bit better. Me take it.         │
    │   {before:>5} sun  ──►  {after:>5} sun (+{diff} sun)      │
    ╰────────────────────────────────────────────╯
"""
    elif diff == 0:
        art = """
    ╭────────────────────────────────────────────╮
    │  🤷 Hmm. Same same. Maybe need wait.       │
    │     Lightning rock still thinking...       │
    ╰────────────────────────────────────────────╯
"""
    else:
        art = """
    ╭────────────────────────────────────────────╮
    │  😕 Ugh? Number go down?                   │
    │   {before:>5} sun  ──►  {after:>5} sun ({diff} sun)      │
    │   Lightning rock confused. Wait bit.       │
    ╰────────────────────────────────────────────╯
"""

    return art.format(before=before_min, after=after_min, diff=diff)


def get_process_kill_art(killed_count: int, mem_freed_gb: float) -> str:
    """Celebrate the hunt with cave paintings."""
    if killed_count == 0:
        return ""

    skulls = "💀" * min(killed_count, 5)
    clubs = "🏏" * min(killed_count, 5)

    return f"""
    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃  {skulls:^41}  ┃
    ┃  {clubs:^41}  ┃
    ┃                                             ┃
    ┃   Creatures Bonked: {killed_count:>3}                      ┃
    ┃   Cave Space Free: ~{mem_freed_gb:.1f} big rocks            ┃
    ┃                                             ┃
    ┃   OOGA BOOGA! GOOD HUNT!                    ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
"""


def get_battery_info() -> dict:
    """Ask lightning rock how much juice left."""
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
        info["status"] = "juice leaving"
    elif "charging" in output.lower():
        info["status"] = "eating lightning"
    elif "charged" in output.lower():
        info["status"] = "belly full"
    elif "AC Power" in output:
        info["status"] = "plugged to wall-vine"

    time_match = re.search(r"(\d+:\d+) remaining", output)
    if time_match:
        info["time_remaining"] = time_match.group(1)
        h, m = map(int, time_match.group(1).split(":"))
        info["time_remaining_minutes"] = h * 60 + m

    return info


def get_top_cpu_processes(n: int = 5) -> list:
    """Find which creature eating most fire."""
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
    """Caveman remember this moment for later compare."""
    data = {
        "battery": get_battery_info(),
        "top_processes": get_top_cpu_processes(),
        "processes_killed": processes_killed,
        "mem_freed_mb": mem_freed_mb,
    }
    BASELINE_FILE.write_text(json.dumps(data, indent=2))

    print("")
    print("    ╔═══════════════════════════════════════╗")
    print("    ║  🧠 CAVEMAN REMEMBER THIS MOMENT      ║")
    print("    ╠═══════════════════════════════════════╣")
    print(f"    ║   Juice Level: {data['battery']['percentage']:>3}%                  ║")
    if data['battery']['time_remaining']:
        print(f"    ║   Sun-moves Left: {data['battery']['time_remaining']:>5}            ║")
    print("    ╚═══════════════════════════════════════╝")
    print("")
    print("    💡 Now go bonk! Then run 'measure_power.py after'")
    print("")


def show_impact_report(processes_killed: int = 0, mem_freed_mb: float = 0):
    """Show big celebration of successful hunt."""
    has_baseline = BASELINE_FILE.exists()

    current = get_battery_info()
    current_procs = get_top_cpu_processes()

    mem_freed_gb = mem_freed_mb / 1024 if mem_freed_mb > 0 else 0

    print("\n")
    print("    ╔════════════════════════════════════════════════════════╗")
    print("    ║     🦣 CAVEMAN HUNT REPORT 🦣                          ║")
    print("    ║     ᕦ(ò_óˇ)ᕤ  Me show what happen!                     ║")
    print("    ╚════════════════════════════════════════════════════════╝")

    if processes_killed > 0:
        print(get_process_kill_art(processes_killed, mem_freed_gb))

    if has_baseline:
        baseline = json.loads(BASELINE_FILE.read_text())
        before = baseline['battery']
        after = current

        before_min = before.get('time_remaining_minutes', 0)
        after_min = after.get('time_remaining_minutes', 0)

        if before_min and after_min:
            print(get_comparison_art(before_min, after_min))

        print("\n    ┌─── FIRE BEFORE ───────┬─── FIRE AFTER ────────┐")
        before_procs = baseline.get('top_processes', [])[:3]
        after_procs = current_procs[:3]

        for i in range(max(len(before_procs), len(after_procs))):
            b = before_procs[i] if i < len(before_procs) else {"cpu": 0, "name": "-"}
            a = after_procs[i] if i < len(after_procs) else {"cpu": 0, "name": "-"}
            b_str = f"{b['cpu']:>5.1f}% {b['name'][:12]:<12}"
            a_str = f"{a['cpu']:>5.1f}% {a['name'][:12]:<12}"
            print(f"    │ {b_str} │ {a_str} │")

        print("    └───────────────────────┴───────────────────────┘")

        before_total = sum(p['cpu'] for p in before_procs)
        after_total = sum(p['cpu'] for p in after_procs)
        reduction = before_total - after_total

        if reduction > 0:
            print(f"\n    📉 Fire eating: {before_total:.0f}% → {after_total:.0f}% (↓{reduction:.0f}% less fire!)")

    improved = has_baseline and processes_killed > 0
    print("\n" + get_battery_art(current['percentage'], improved=improved))

    if current['time_remaining']:
        print(f"\n    ⏱️  Sun-moves remaining: {current['time_remaining']}")

    print("\n    ════════════════════════════════════════════════════════")
    if processes_killed > 0:
        print("    🌿 Magic lightning box breathe easy now!")
        print("    🦴 Caveman did good. Tribe proud.")
    print("")


def compare_to_baseline():
    """Compare now to what caveman remember."""
    if not BASELINE_FILE.exists():
        print("    🤔 Ugh! Caveman no remember before-time.")
        print("    Run 'measure_power.py before' first!")
        return

    baseline = json.loads(BASELINE_FILE.read_text())
    show_impact_report(
        processes_killed=baseline.get('processes_killed', 0),
        mem_freed_mb=baseline.get('mem_freed_mb', 0)
    )


def show_status():
    """Quick look at lightning rock."""
    info = get_battery_info()
    print("")
    print("    🪨 LIGHTNING ROCK STATUS")
    print("    " + "=" * 30)
    print(get_battery_art(info['percentage']))
    print(f"\n    What doing: {info['status']}")
    if info['time_remaining']:
        print(f"    Sun-moves left: {info['time_remaining']}")
    print("")


def main():
    if len(sys.argv) < 2:
        show_status()
        return

    cmd = sys.argv[1].lower()

    if cmd == "before":
        killed = int(sys.argv[2]) if len(sys.argv) > 2 else 0
        mem = float(sys.argv[3]) if len(sys.argv) > 3 else 0
        save_baseline(killed, mem)
    elif cmd == "after":
        compare_to_baseline()
    elif cmd == "report":
        killed = int(sys.argv[2]) if len(sys.argv) > 2 else 0
        mem = float(sys.argv[3]) if len(sys.argv) > 3 else 0
        show_impact_report(killed, mem)
    elif cmd == "status":
        show_status()
    else:
        print(f"    🤔 Ugh? '{cmd}' not caveman word.")
        print(__doc__)


if __name__ == "__main__":
    main()
