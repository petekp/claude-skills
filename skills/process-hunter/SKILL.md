---
name: process-hunter
description: >
  Find and terminate resource-hungry processes to save battery. Use when asked to
  "kill processes", "clean up dev servers", "save battery", "find resource hogs",
  "stop next.js servers", "terminate claude sessions", or "hunt processes".
  Auto-terminates known safe targets (dev servers, duplicate Claude sessions).
  Asks before killing unknown processes.
---

# Process Hunter

Find processes consuming excessive CPU/memory and terminate them to preserve battery life.

## Workflow

**IMPORTANT:** Always show the battery impact report after killing processes!

1. **Save baseline** before scanning:
   ```bash
   python scripts/measure_power.py before
   ```

2. **Scan** for resource hogs:
   ```bash
   python scripts/hunt_processes.py
   ```

3. **Terminate** processes (track count and memory freed)

4. **Show impact report** - ALWAYS do this after killing processes:
   ```bash
   python scripts/measure_power.py report <killed_count> <mem_freed_mb>
   ```

## Scripts

### hunt_processes.py - Find resource hogs

```bash
python scripts/hunt_processes.py [--cpu-threshold 10] [--mem-threshold 500] [--json]
```

Output categories:
- **AUTO-KILL**: Safe to terminate without asking
- **NEEDS CONFIRMATION**: Ask user first

### terminate_process.py - Kill a process

```bash
python scripts/terminate_process.py <pid> [--force]
```

### measure_power.py - Battery impact reporting

```bash
python scripts/measure_power.py before              # Save baseline
python scripts/measure_power.py report <N> <MB>     # Show impact (N killed, MB freed)
python scripts/measure_power.py after               # Compare to baseline
python scripts/measure_power.py status              # Quick battery check
```

## Auto-Kill Targets

Safe to terminate without asking:
- Next.js servers (`next-server`, `next dev`)
- Vite/Webpack/Turbopack dev servers
- npm/yarn/pnpm dev scripts
- React Native / Expo bundlers
- Duplicate Claude Code sessions
- TypeScript watch, esbuild, Rollup

## When to Ask

Use AskUserQuestion before killing:
- Unknown high-resource processes
- User applications (browsers, IDEs, creative apps)
- Anything not in the auto-kill list

## Example Output

After killing processes, always show the impact report:

```
    ╔════════════════════════════════════════════════════╗
    ║          ⚡ PROCESS HUNTER REPORT ⚡               ║
    ╚════════════════════════════════════════════════════╝

    ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
    ┃                  💀💀💀💀💀                  ┃
    ┃                                         ┃
    ┃   Processes Terminated:   5              ┃
    ┃   Memory Freed: ~7.8 GB                 ┃
    ┃                                         ┃
    ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

    ╭──────────────────────────────────────────╮
    │  🚀 MASSIVE IMPROVEMENT 🚀               │
    │                                          │
    │     BEFORE          AFTER                │
    │    ┌──────┐       ┌──────┐              │
    │    │ 135  │  >>>  │ 212  │   +77 min    │
    │    └──────┘       └──────┘              │
    │                                          │
    │  ✨ Your battery will thank you! ✨      │
    ╰──────────────────────────────────────────╯

     ╔════════════╗┐
     ║  58%  ⚡  ║│
     ║ [█████░░░░░] ║│
     ╚════════════╝┘

    ⏱️  Time remaining: 3:32

    ════════════════════════════════════════════════════
    🌱 Your MacBook is breathing easier now!
```
