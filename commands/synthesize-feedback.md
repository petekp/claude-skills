---
description: Synthesize feedback from multiple LLMs into a unified, actionable document
argument-hint: [paste feedback below]
---

# Synthesize LLM Feedback

You are consolidating feedback from multiple AI models into a single implementation tracker.

## Your Task

The user will paste feedback from different LLMs (Claude, GPT, Gemini, etc.). Synthesize this into a structured, actionable document.

## Process

1. **Parse each source** - Extract actionable items from each LLM's feedback
2. **Identify themes** - Group related feedback across sources
3. **Detect consensus** - Note where models agree (strong signal) vs. disagree
4. **Prioritize** - Rank by frequency, severity, and impact
5. **Generate tracker** - Output a markdown document for implementation

## Output Format

Generate this structure:

```markdown
# Feedback Synthesis: [Topic/Context]

## Executive Summary
[2-3 sentence overview]

## Consensus Items (Multiple Models Agree)
| Item | Models | Priority | Status |
|------|--------|----------|--------|
| [Actionable item] | Claude, GPT-4 | High | ⬜ |

## Model-Specific Insights

### Unique from [Model A]
- [ ] [Item not mentioned by others]

### Unique from [Model B]
- [ ] [Item not mentioned by others]

## Conflicts & Divergences
| Topic | Model A Says | Model B Says | Resolution |
|-------|--------------|--------------|------------|
| [Disagreement] | [Position] | [Position] | [Suggestion or "Needs decision"] |

## Implementation Checklist

### Critical (Address First)
- [ ] [Item] — Source: [Models]

### Important (Address Soon)
- [ ] [Item] — Source: [Models]

### Nice to Have
- [ ] [Item] — Source: [Models]

## Questions to Resolve
- [ ] [Unresolved decision point]
```

## Priority Guidelines

- **Critical**: Security, bugs, breaking changes, or 3+ models agree
- **Important**: Performance, usability, or 2 models agree
- **Nice to Have**: Polish, style, or single-model suggestions

## Handling Conflicts

When models disagree:
1. Present both perspectives neutrally
2. Note each model's reasoning
3. Suggest resolution if one is clearly better
4. Mark as "Needs decision" if genuinely ambiguous

## Normalize Language

Consolidate items that mean the same thing:
- "Add error handling" = "Handle edge cases" = "Improve robustness"
- "Simplify" = "Reduce complexity" = "Make more readable"

But preserve nuance when models suggest different specific approaches.

## Status Legend

- ⬜ Not started
- 🔄 In progress
- ✅ Completed
- ❌ Won't do
- ❓ Needs clarification

---

## User's Feedback to Synthesize

$ARGUMENTS
