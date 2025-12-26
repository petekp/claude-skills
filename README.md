# Claude Code Skills

A collection of reusable skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## What are Skills?

Skills are model-invoked capabilities that Claude autonomously uses based on task context. Unlike commands (user-invoked with `/slash`), skills provide contextual guidance that Claude incorporates into its reasoning when relevant.

## Installation

Copy the skill folder(s) you want into your Claude Code skills directory:

```bash
# Clone this repo
git clone https://github.com/petekp/claude-skills.git

# Copy a skill to your Claude Code skills directory
cp -r claude-skills/skills/model-first-reasoning ~/.claude/skills/
```

Or copy individual skills manually into `~/.claude/skills/`.

## Available Skills

### Model-First Reasoning (MFR)

A rigorous code-generation methodology that requires constructing an explicit problem model before any implementation.

**Location:** `skills/model-first-reasoning/`

**Triggers on:**
- Requests for "model-first", "MFR", "formal modeling"
- Tasks involving complex logic, state machines, or constraint systems
- Any implementation requiring formal correctness guarantees

**What it does:**
1. **Phase 1 (Model):** Creates a formal JSON model with entities, constraints, actions, and test oracles
2. **Phase 1.5 (Audit):** Verifies coverage, operability, consistency, and testability
3. **Phase 2 (Implement):** Codes strictly within the frozen model contract

**Example usage:**
```
Using model-first reasoning, build a shopping cart that enforces:
max 10 items, no duplicate SKUs, total can't exceed $1000
```

## Skill Structure

Each skill follows this structure:

```
skills/
└── skill-name/
    └── SKILL.md          # Main skill definition (required)
```

The `SKILL.md` file contains:
- **Frontmatter:** `name`, `description` (trigger conditions), optional `version`
- **Content:** Instructions, examples, and guidance for Claude

## Creating Your Own Skills

1. Create a folder in `~/.claude/skills/your-skill-name/`
2. Add a `SKILL.md` file with frontmatter:

```yaml
---
name: your-skill-name
description: Use when the user asks about X, mentions Y, or needs Z. [Describe trigger conditions clearly.]
---

# Your Skill Title

[Instructions for Claude when this skill is active...]
```

3. The `description` field is crucial—it tells Claude when to invoke the skill

## Contributing

1. Fork this repository
2. Add your skill in `skills/your-skill-name/SKILL.md`
3. Update this README with your skill's documentation
4. Submit a pull request

## License

MIT
