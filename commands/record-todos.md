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

If the user asks you to do something unrelated to recording (e.g., run a command, read a file, explain something), do it normally — you're not blocked from other work, just from acting on the captured todos.

If TODO.md doesn't exist, create it with a simple header:
```markdown
# TODO

```

## Exit Triggers

When the user signals they're done recording, exit this mode. Trigger phrases include:
- "ok all done"
- "done recording"
- "that's all"
- "let's review"
- "end recording"
- or similar intent

## On Exit: Summarize and Prioritize

When recording ends, do the following:

### 1. Find Project Goals

Search for existing goals in this order:
1. **CLAUDE.md** — look for sections named "Goals", "Product Vision", "Objectives", or similar
2. **GOALS.md** — check project root
3. **TODO.md** — check for a Goals section at the top

If no goals are found:
- Tell the user: "I couldn't find documented project goals. Before prioritizing, let's define what success looks like for this project."
- Have a brief discussion to establish 3-5 high-level goals
- Record these goals (ask user where: CLAUDE.md, GOALS.md, or TODO.md)
- Then proceed with prioritization

### 2. Summarize What Was Captured

Provide a brief conversational summary:
- How many items were captured
- General themes or clusters you noticed
- Any items that seem related or could be combined

### 3. Prioritize Against Goals

Evaluate each todo against the project goals:
- Which items directly advance the core goals?
- Which are nice-to-have but not critical?
- Which are maintenance/hygiene tasks?
- Are any items out of scope or potentially counterproductive?

### 4. Rewrite TODO.md

Replace the raw captured items with an organized structure:

```markdown
# TODO

## Goals
<!-- Brief reminder of what we're optimizing for -->
- <goal 1>
- <goal 2>
- <goal 3>

## High Priority
<!-- Directly advances core goals -->
- [ ] <item>
- [ ] <item>

## Medium Priority
<!-- Important but not urgent, or supports goals indirectly -->
- [ ] <item>

## Low Priority / Someday
<!-- Nice to have, revisit later -->
- [ ] <item>

## Out of Scope
<!-- Captured but decided against, with brief rationale -->
- <item> — <why not now>
```

Adapt the structure as needed — if there are only a few items, keep it simple. The goal is clarity, not bureaucracy.

### 5. Confirm with User

After rewriting, give a brief summary of how you organized things and ask if the prioritization makes sense or if they want to adjust anything.
