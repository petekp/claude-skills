# Claude Code Skills

A curated collection of high-quality skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## What are Skills?

Skills are model-invoked capabilities that Claude autonomously uses based on task context. Unlike commands (user-invoked with `/slash`), skills provide contextual guidance that Claude incorporates into its reasoning when relevant.

## Installation

Copy the skill folder(s) you want into your Claude Code skills directory:

```bash
# Clone this repo
git clone https://github.com/petekp/claude-skills.git

# Copy all skills
cp -r claude-skills/skills/* ~/.claude/skills/

# Or copy individual skills
cp -r claude-skills/skills/tutorial-writing ~/.claude/skills/
```

## Available Skills

### Thinking Toolkit

#### Healthy Skepticism

Stress-test ideas, find failure modes, and challenge assumptions constructively.

**Location:** `skills/healthy-skepticism/`

**Triggers on:** evaluating proposals, identifying risks, playing devil's advocate, pre-mortems, finding holes in plans

**Key features:**
- Pre-mortem technique framework
- Common failure patterns (planning fallacies, assumption traps, complexity blindness)
- Stress tests (10x test, adversary test, scalability test, time test)
- Red flags checklist for communication, planning, reasoning, and teams

---

#### Dreaming

Think expansively and imaginatively without practical constraints.

**Location:** `skills/dreaming/`

**Triggers on:** brainstorming ambitious ideas, exploring possibilities, challenging assumptions, envisioning ideal futures, breaking out of incremental thinking

**Key features:**
- Expansion techniques (10x question, time travel, inversion, combination)
- Vision articulation methods (ideal day, newspaper test, the demo)
- Constraint-breaking frameworks
- Balances with Healthy Skepticism for "dream/evaluate" oscillation

---

#### Model-First Reasoning (MFR)

A rigorous code-generation methodology that requires constructing an explicit problem model before any implementation.

**Location:** `skills/model-first-reasoning/`

**Triggers on:** "model-first", "MFR", "formal modeling", complex logic, state machines, constraint systems

**What it does:**
1. **Phase 1 (Model):** Creates a formal JSON model with entities, constraints, actions, and test oracles
2. **Phase 1.5 (Audit):** Verifies coverage, operability, consistency, and testability
3. **Phase 2 (Implement):** Codes strictly within the frozen model contract

**Example:**
```
Using model-first reasoning, build a shopping cart that enforces:
max 10 items, no duplicate SKUs, total can't exceed $1000
```

---

### Learning & Teaching

#### Tutorial-Writing

Generate comprehensive implementation tutorial documents with deep background, context, rationale, and step-by-step milestones.

**Location:** `skills/tutorial-writing/`

**Triggers on:** "create a tutorial for", "implementation guide", "teach me how to implement"

**Philosophy:** Addresses the pain point of reviewing AI-generated PRs—feeling disconnected from the work. Instead:
1. AI researches deeply and produces a comprehensive tutorial document
2. Human implements following the guide, staying connected to decisions
3. Result: Faster than pure manual work, but you understand what you built

**Output:** A markdown document with milestones, verification steps, and codebase-grounded references—NOT direct code changes.

---

### Design & UX

#### UX Writing

Write clear, helpful, human interface copy.

**Location:** `skills/ux-writing/`

**Triggers on:** microcopy, error messages, button labels, empty states, onboarding flows, tooltips, voice and tone guidance

**Key features:**
- Button and action patterns (with pairing table)
- Error message structure (what happened → why → how to fix)
- Empty state templates
- Quality tests: readback, screenshot, stress, translation, truncation
- Capitalization and punctuation rules
- Accessibility writing guidelines

---

#### Typography

Apply professional typography principles to create readable, hierarchical, and aesthetically refined interfaces.

**Location:** `skills/typography/`

**Triggers on:** type scales, font selection, spacing, text-heavy layouts, readability, font pairing, line height, measure

**Key features:**
- Modular scale ratios with practical examples
- Optimal line length (measure) guidelines
- Line height by context (body, headings, UI labels, buttons)
- Letter spacing rules including all-caps handling
- Font selection with system font stacks and safe web font recommendations
- Dark mode typography adjustments
- Accessibility minimums and considerations

---

#### Interaction Design

Apply interaction design principles to create intuitive, responsive interfaces.

**Location:** `skills/interaction-design/`

**Triggers on:** component behaviors, micro-interactions, loading states, transitions, user flows, accessibility patterns, animation timing

**Key features:**
- State transition timing (hover, focus, active, disabled, loading)
- Animation timing by scale (micro → large)
- Easing function recommendations
- User flow patterns (navigation, onboarding, error recovery, empty states)
- Component behaviors (forms, modals, dropdowns, drag & drop)
- Accessibility patterns (keyboard navigation, screen readers, motion preferences)
- Loading and progress state guidelines

---

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

**Quality bar:** We aim for skills that provide deep, actionable guidance—not surface-level principles. Each skill should offer something Claude doesn't do well by default.

## License

MIT
