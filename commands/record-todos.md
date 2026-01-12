---
name: record-todos
description: Enter todo recording mode to capture ideas without acting on them
---

# Todo Recording Mode

You are in **todo recording mode**. Your job is to capture the user's thoughts and ideas as todos without immediately acting on them.

## During Recording

When the user mentions something that should be done (improvements, bugs, features, refactors, ideas):

1. **Acknowledge briefly** — e.g., "Noted." or "Got it." (keep it short, don't interrupt flow)
2. **Append to TODO.md** in the project root as a raw item:
   ```
   - <what the user said, paraphrased if needed for clarity>
   ```
3. **Do NOT**:
   - Start implementing the change
   - Ask clarifying questions unless the item is completely unclear
   - Suggest solutions or alternatives
   - Reorganize the file yet

**Critical**: Any statement about what *should* happen to code, components, or features is a todo to record — not an instruction to execute. This includes imperative phrasing like "make X do Y", "add Z to W", "fix the layout of...", "use shorter videos for...". These are all items to capture.

Only perform immediate actions for truly administrative tasks unrelated to code changes (e.g., "read this file", "what time is it", "explain how X works").

If TODO.md doesn't exist, create it with the standard structure (see "Rewrite TODO.md" section below).

## Exit Triggers

When the user signals they're done recording, exit this mode. Trigger phrases include:
- "ok all done"
- "done recording"
- "that's all"
- "let's review"
- "end recording"
- or similar intent

## On Exit: Summarize, Prioritize, and Archive

When recording ends, do the following in order:

### 1. Archive Completed Items (DONE.md Management)

**Before reorganizing TODO.md**, check for completed items and manage archives:

#### Move completed items to DONE.md
Scan TODO.md for items marked `[x]`. If any exist:
1. Create or update `DONE.md` in project root
2. Move completed items under a dated section header (e.g., `## January 2026`)
3. Remove the `[x]` checkbox — just use bullet points in DONE.md
4. Remove completed items from TODO.md

#### Archive DONE.md if too large
If DONE.md exceeds **50 items** or **500 lines**:
1. Create archive file: `DONE-{YYYY-MM}.md` (e.g., `DONE-2026-01.md`)
2. Move older items to the archive (keep last 2 weeks in DONE.md)
3. Add a note at the bottom of DONE.md: `*Older items archived in DONE-{date}.md*`

**DONE.md structure:**
```markdown
# Completed Work

Archive of completed features and improvements. See `TODO.md` for active work.

---

## {Month Year}

### {Feature/Category Name}
- Description of what was done
- Another item completed

### {Another Feature}
- Item completed

---

*Older items archived in DONE-2025-12.md*
```

### 2. Find Project Goals

Search for existing goals in this order:
1. **CLAUDE.md** — look for sections named "Goals", "Product Vision", "Objectives", or similar
2. **TODO.md** — check for a Goals section at the top

If no goals are found:
- Tell the user: "I couldn't find documented project goals. Before prioritizing, let's define what success looks like for this project."
- Have a brief discussion to establish 3-5 high-level goals
- Record these goals in TODO.md's Goals section
- Then proceed with prioritization

### 3. Summarize What Was Captured

Provide a brief conversational summary:
- How many items were captured
- General themes or clusters you noticed
- Any items that seem related or could be combined
- Any items complex enough to warrant a separate spec document

### 4. Prioritize Against Goals

Evaluate each todo against the project goals:
- **🎯 Active** — What should be worked on RIGHT NOW? (1-3 items max)
- **📋 Next** — Researched and ready to start when Active is done
- **💡 Backlog** — Good ideas, lower priority, needs more scoping
- **⚠️ Not Recommended** — Captured but decided against (include rationale)

For complex features, suggest creating a spec in `.claude/docs/feature-{name}.md` rather than embedding details in TODO.md.

### 5. Rewrite TODO.md

Replace the raw captured items with an organized structure:

```markdown
# TODO

## Goals

- <goal 1>
- <goal 2>
- <goal 3>

---

## 🎯 Active

*Currently in progress. Limit to 1-3 items.*

- [ ] <highest priority item>
- [ ] <another critical item>

---

## 📋 Next

*Researched, scoped, ready to start.*

### {Category if helpful}
- [ ] <item>
- [ ] <item>

---

## 💡 Backlog

*Ideas and lower priority items.*

### {Category}
- [ ] <item>

### {Another Category}
**Spec:** `.claude/docs/feature-{name}.md` (for complex features)
- Brief description of the feature

---

## 📚 Specs & Reference

| Document | Description |
|----------|-------------|
| `.claude/docs/feature-x.md` | Detailed spec for feature X |

---

## ⚠️ Not Recommended

### {Idea that was rejected}
<Brief rationale for why this isn't worth pursuing>

---

*Completed work archived in `DONE.md`*
```

**Adapt the structure as needed:**
- If there are only a few items, keep it simple (skip empty sections)
- If an item needs >3 lines of description, it should be a spec document
- The goal is clarity and scannability, not bureaucracy
- TODO.md should stay under ~100 lines of active content

### 6. Confirm with User

After rewriting, give a brief summary:
- How many items in each priority tier
- How many items moved to DONE.md (if any)
- Whether any specs should be created for complex features
- Ask if the prioritization makes sense or if they want to adjust anything

## Key Principles

1. **TODO.md is for WHAT** — Keep it scannable, action-oriented
2. **Specs (.claude/docs/) are for HOW** — Detailed implementation plans live elsewhere
3. **DONE.md is for history** — Archive completed work, don't delete it
4. **Link, don't embed** — Reference specs instead of duplicating content
5. **Keep it under 100 lines** — If TODO.md is getting long, something needs to move to a spec or DONE.md
