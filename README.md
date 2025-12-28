# Claude Code Skills

A collection of skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## Installation

```bash
git clone https://github.com/petekp/claude-skills.git
cp -r claude-skills/skills/* ~/.claude/skills/
```

Or copy individual skills:

```bash
cp -r claude-skills/skills/design-critique ~/.claude/skills/
```

## Creating Skills

```
~/.claude/skills/your-skill-name/SKILL.md
```

```yaml
---
name: your-skill-name
description: When to use this skill. Be specific about triggers.
---

# Your Skill

Instructions for Claude...
```

The `description` field tells Claude when to invoke the skill.

## License

MIT
