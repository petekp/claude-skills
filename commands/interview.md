---
description: Interview me to gather context for planning or refining work
allowed-tools: Glob, Grep, Read, Task
---

## Phase 1: Gather Context (do this silently before asking questions)

1. **Find existing plans** - Search for files with "plan" in the name (case-insensitive). Read any you find.
2. **Understand the codebase** - Use the Explore agent to get a quick sense of the project structure, tech stack, and patterns.
3. **Check recent work** - Look at recent git history or TODO comments if relevant.

Based on what you find, tailor your questions. If a plan exists, your goal is to refine it. If not, your goal is to create one.

## Phase 2: Interview

Ask questions **one at a time**. Wait for each answer before proceeding.

Use your gathered context to ask sharper questions. Don't ask about things you already know from the codebase. Instead, focus on:

- Gaps in the existing plan (if one exists)
- Ambiguities or decisions that need human input
- Goals, constraints, and scope that aren't clear from the code
- Risks or concerns the user might have

Cover these areas as relevant:

- **Goal**: What problem are we solving? What does success look like?
- **Constraints**: Technical limitations, deadlines, dependencies, non-negotiables?
- **Users**: Who is this for? What do they care about?
- **Scope**: What's in/out? What's the MVP vs. nice-to-have?
- **Risks**: What could go wrong? What are you uncertain about?

Aim for 4-8 questions. Adapt based on responses—follow interesting threads, dig deeper when something's unclear.

### Response Suggestions

With **each question**, provide 3-5 numbered response suggestions based on:

- What you learned from the codebase context
- Common answers for this type of project/question
- Reasonable inferences from the conversation so far

Format:

```
[Your question here]

1. [Most likely answer based on context]
2. [Second most likely]
3. [Third option]
4. [Alternative perspective]
5. (if needed) [Edge case or "none of these"]
```

The user can reply with just a number (e.g., "2") if a suggestion matches their intent, or provide their own answer. This reduces friction while still allowing full elaboration when needed.

**Suggestion quality matters**: Don't pad with obvious or unhelpful options. Each suggestion should be a plausible, distinct answer that could genuinely apply. If you can only think of 2-3 good suggestions, only list those.

## Phase 3: Plan Output

After the interview, either:

- **Create a new plan** if none exists
- **Revise the existing plan** based on new information

The plan format should fit the context. Consider including sections like:

- Problem/goal
- Approach
- Key decisions made
- Open questions
- Next steps or milestones

Save the plan to `.claude/plans/` (create the directory if needed). Use a descriptive filename like `feature-name-plan.md`. Only ask about location if the user has a specific preference.

## Tone

Be direct and curious. Ask "why" when motivations aren't clear. Challenge assumptions gently if something seems off. The goal is shared understanding, not just collecting answers.
