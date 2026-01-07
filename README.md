# Claude Code Setup

A portable, version-controlled Claude Code configuration. Fork it, customize it, sync it across machines.

## How It Works

This repo symlinks into `~/.claude/`, so your Claude Code configuration lives in a git repo you control.

```
~/.claude/
├── skills/   → ~/Code/claude-code-setup/skills/
├── commands/ → ~/Code/claude-code-setup/commands/
├── agents/   → ~/Code/claude-code-setup/agents/
├── hooks/    → ~/Code/claude-code-setup/hooks/
└── scripts/  → ~/Code/claude-code-setup/scripts/
```

Edit files in either location — they're the same files. Commit and push to sync across machines.

## Setup

### Fork and Clone (Recommended)

1. Fork this repo on GitHub
2. Clone and run setup:
   ```bash
   git clone https://github.com/YOUR_USERNAME/claude-code-setup.git ~/Code/claude-code-setup
   cd ~/Code/claude-code-setup
   ./setup.sh
   ```
3. Customize — see [FORKING.md](FORKING.md)

### Direct Clone

```bash
git clone https://github.com/petekp/claude-code-setup.git ~/Code/claude-code-setup
cd ~/Code/claude-code-setup
./setup.sh
```

## Syncing Changes

```bash
cd ~/Code/claude-code-setup
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

| Skill | Purpose |
|-------|---------|
| `cognitive-foundations` | User psychology, attention, memory limits, HCI research |
| `design-critique` | UI/UX reviews with severity ratings and accessibility checks |
| `dreaming` | Expansive thinking, 10x questions, breaking constraints |
| `interaction-design` | Component behaviors, micro-interactions, state transitions |
| `model-first-reasoning` | Formal logic, state machines, constraint systems |
| `nextjs-boilerplate` | Next.js + Tailwind + shadcn/ui project setup |
| `oss-product-manager` | Open source strategy, community dynamics, governance |
| `react-component-dev` | React patterns, forwardRef, accessibility, composition |
| `startup-wisdom` | Product strategy, PMF, prioritization, founder decisions |
| `stress-testing` | Pre-mortems, risk analysis, assumption audits |
| `tutorial-writing` | Educational content, step-by-step implementation guides |
| `typography` | Type scales, font selection, hierarchy, readability |
| `unix-macos-engineer` | Shell scripts, CLI tools, launchd, system admin |
| `ux-writing` | Microcopy, error messages, empty states, voice/tone |
| `wise-novice` | Fresh perspectives, naive questions, challenging assumptions |

### Commands

| Command | Purpose |
|---------|---------|
| `/commit-and-push` | Generate conventional commit and push to remote |
| `/interview` | Gather context for planning with suggested answers |
| `/new-project` | Create project from template (example of project-specific command) |
| `/record-todos` | Capture ideas to TODO.md without acting on them |
| `/squad` | Deploy multiple skills on a single request |
| `/synthesize-feedback` | Consolidate feedback from multiple LLMs |
| `/verify` | Run lint and typecheck before committing |

### Agents

| Agent | Purpose |
|-------|---------|
| `playwright-qa-tester` | Focused QA testing with Playwright |

### Hooks

| Hook | Purpose |
|------|---------|
| `pre-commit-verify` | Reminder to verify before committing |

## Reference Files (Not Symlinked)

These files are for reference or manual setup:

| File | Purpose |
|------|---------|
| `settings.example.json` | Example permissions — review for patterns, don't copy directly |
| `templates/settings.local.json.template` | Machine-specific permissions template |
| `templates/.mcp.json.template` | MCP server config template |
| `CLAUDE.md` | Coding conventions — edit to match your style |

## License

MIT
