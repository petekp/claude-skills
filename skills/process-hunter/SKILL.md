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

1. Run `scripts/hunt_processes.py` to scan for resource hogs
2. Review the categorized output:
   - **AUTO-KILL**: Safe to terminate (dev servers, duplicate Claude sessions)
   - **NEEDS CONFIRMATION**: Ask user before terminating
3. Terminate processes using `scripts/terminate_process.py`

## Usage

### Scan for processes

```bash
python scripts/hunt_processes.py
```

Options:
- `--cpu-threshold PCT` - CPU threshold (default: 10%)
- `--mem-threshold MB` - Memory threshold (default: 500MB)
- `--json` - Output as JSON for programmatic use

### Terminate a process

```bash
python scripts/terminate_process.py <pid>
```

Options:
- `--force` - Skip graceful shutdown, force kill immediately

## Auto-Kill Targets

These are automatically categorized as safe to terminate:
- Next.js dev servers (`next-server`, `next dev`)
- Vite/Webpack dev servers
- npm/yarn/pnpm dev scripts
- React Native / Expo bundlers
- Claude Code sessions (suggest killing duplicates)
- TypeScript watch processes
- esbuild/Rollup bundlers

## When to Ask

Always ask user confirmation for:
- Unknown high-resource processes
- System-adjacent processes (even if not in ignore list)
- Any process the user might have intentionally started

## Example Session

```
$ python scripts/hunt_processes.py

🎯 AUTO-KILL (safe to terminate):
------------------------------------------------------------
  PID  61331 | CPU 121.9% | MEM 2886.5MB
           | Next.js server: next-server
  PID  73528 | CPU  30.6% | MEM  572.7MB
           | Claude Code session: claude

❓ NEEDS CONFIRMATION:
------------------------------------------------------------
  PID  50706 | CPU   3.8% | MEM  834.5MB
           | /Applications/Dia.app/Contents/MacOS/Dia
```

For AUTO-KILL processes, terminate without asking (unless user wants to review).
For NEEDS CONFIRMATION, use AskUserQuestion before terminating.
