# Claude Code Setup

My portable, version-controlled Claude Code configuration. Fork it, customize it, sync it across machines.

## Quick Start

```bash
git clone https://github.com/YOUR_USERNAME/claude-code-setup.git
cd claude-code-setup && ./setup.sh

// Optional prompt to streamline usage
claude "This is someone else's Claude Code configuration setup. I also want to version my Claude Code configuration. Analyze this configuration and provide a concise summary of its contents, how it differs from my current setup, what I may find particularly useful. After that, interview me about what I do or don't want to bring over to my own configuration, and my preferences around where nad how to store my own versioned Claude Code repo."
```

That's it. Your Claude Code now uses this repo's skills and commands.

## How It Works

This repo symlinks into `~/.claude/`, so your Claude Code configuration lives in a git repo you control.

```
~/.claude/
├── skills/   → <repo>/skills/
├── commands/ → <repo>/commands/
├── agents/   → <repo>/agents/
├── hooks/    → <repo>/hooks/
└── scripts/  → <repo>/scripts/
```

Edit files in either location — they're the same files. Commit and push to sync across machines.

## Setup

### Fork and Clone (Recommended)

1. Fork this repo on GitHub
2. Clone and run setup:
   ```bash
   git clone https://github.com/YOUR_USERNAME/claude-code-setup.git
   cd claude-code-setup && ./setup.sh
   ```
3. Customize — see [FORKING.md](FORKING.md)

### Direct Clone

```bash
git clone https://github.com/petekp/claude-code-setup.git
cd claude-code-setup && ./setup.sh
```

Clone it wherever you keep projects — the setup script detects its own location.

## Syncing Changes

From the repo directory:

```bash
git add -A && git commit -m "Update config" && git push
```

On another machine, just `git pull`.

## Undo

```bash
./setup.sh --undo
```

Removes symlinks and restores any backed-up directories.

## What's Included

### Skills

| Skill                   | Purpose                                                      |
| ----------------------- | ------------------------------------------------------------ |
| `cognitive-foundations` | User psychology, attention, memory limits, HCI research      |
| `design-critique`       | UI/UX reviews with severity ratings and accessibility checks |
| `dreaming`              | Expansive thinking, 10x questions, breaking constraints      |
| `interaction-design`    | Component behaviors, micro-interactions, state transitions   |
| `model-first-reasoning` | Formal logic, state machines, constraint systems             |
| `nextjs-boilerplate`    | Next.js + Tailwind + shadcn/ui project setup                 |
| `oss-product-manager`   | Open source strategy, community dynamics, governance         |
| `react-component-dev`   | React patterns, forwardRef, accessibility, composition       |
| `startup-wisdom`        | Product strategy, PMF, prioritization, founder decisions     |
| `stress-testing`        | Pre-mortems, risk analysis, assumption audits                |
| `tutorial-writing`      | Educational content, step-by-step implementation guides      |
| `typography`            | Type scales, font selection, hierarchy, readability          |
| `unix-macos-engineer`   | Shell scripts, CLI tools, launchd, system admin              |
| `ux-writing`            | Microcopy, error messages, empty states, voice/tone          |
| `wise-novice`           | Fresh perspectives, naive questions, challenging assumptions |

### Commands

| Command                | Purpose                                                            |
| ---------------------- | ------------------------------------------------------------------ |
| `/commit-and-push`     | Generate conventional commit and push to remote                    |
| `/grok`                | Deep 6-phase codebase analysis for authoritative understanding     |
| `/interview`           | Gather context for planning with suggested answers                 |
| `/new-project`         | Create project from template (example of project-specific command) |
| `/record-todos`        | Capture ideas to TODO.md without acting on them                    |
| `/recover`             | Escape rabbit holes, impasses, and tangled sessions                |
| `/refactor`            | Refactor for readability, maintainability, type safety             |
| `/squad`               | Deploy multiple skills on a single request                         |
| `/synthesize-feedback` | Consolidate feedback from multiple LLMs                            |
| `/verify`              | Run lint and typecheck before committing                           |

### Agents

| Agent                  | Purpose                            |
| ---------------------- | ---------------------------------- |
| `playwright-qa-tester` | Focused QA testing with Playwright |

### Hooks

| Hook                | Purpose                                                   |
| ------------------- | --------------------------------------------------------- |
| `doc-update-check`  | Prompt to update README when commands/skills/hooks change |
| `pre-commit-verify` | Reminder to verify before committing                      |
| `say-ready`         | Speak project name when Claude is ready for input         |

The `doc-update-check` hook makes this repo self-maintaining: when Claude adds or removes commands, skills, or hooks, it's prompted to update this README before finishing. No more stale docs.

### Scripts

| Script         | Purpose                                                      |
| -------------- | ------------------------------------------------------------ |
| `say-ready.sh` | Speak project name aloud (with 10s debounce)                 |
| `validate.sh`  | Validate frontmatter in skills, commands, agents, and hooks  |

## Reference Files (Not Symlinked)

These files are for reference or manual setup. See [templates/README.md](templates/README.md) for details.

| File                                      | Purpose                                                        |
| ----------------------------------------- | -------------------------------------------------------------- |
| `templates/settings.json.reference`       | Example permissions — review for patterns, don't copy directly |
| `templates/settings.local.json.template`  | Machine-specific permissions template                          |
| `templates/.mcp.json.template`            | MCP server config template                                     |
| `CLAUDE.md`                               | Coding conventions — edit to match your style                  |

## Troubleshooting

### Skills/commands not appearing

1. Check symlinks exist: `ls -la ~/.claude/skills`
2. Validate frontmatter: `./scripts/validate.sh`
3. Restart Claude Code

### "Permission denied" on setup.sh

```bash
chmod +x setup.sh && ./setup.sh
```

### Preview changes before running

```bash
./setup.sh --dry-run
```

### Restoring after breaking changes

```bash
./setup.sh --undo  # Restores from timestamped backups
```

### Windows users

This script requires a Unix shell. Use WSL (Windows Subsystem for Linux) or set up symlinks manually.

## License

MIT
