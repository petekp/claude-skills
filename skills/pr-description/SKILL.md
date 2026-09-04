---
name: pr-description
description: "Write a short, visual, evidence-backed GitHub PR description and open or update the PR with it. Use whenever the user asks to open a PR, write or rewrite a PR description, 'describe this change', or run gh pr create — even if they don't say 'description'. Gathers real proof first (screenshots for UI, terminal transcripts for CLI, ascii before/after for data shapes), then writes prose that captions the evidence. Do not use for PRD/product documents (that's writing-prds) or for review comments on an existing PR (that's pr-self-review)."
---

# PR Description

A reviewer opens a PR with four questions: what does this do, why now, where's the risk, and how do I know it works. Answer those four things and stop. Everything else — file-by-file narration, restated diffs, boilerplate sections — costs reviewer attention without answering anything.

The description's job is to make the review fast and the merge safe, not to prove effort. A great one is shorter than the reader expects and shows more than it tells.

## Process: evidence first, prose last

Write nothing until you have looked at what the change actually does. The order matters — prose written before evidence turns into summary; prose written after evidence turns into captions.

1. **Read the real diff.** `git diff <base>...HEAD` (or `gh pr diff`). Note what a reviewer will find confusing or risky — that goes in the description. Skip what's mechanical — that doesn't.
2. **Find out why.** Check the branch name, linked issue, commit messages, and conversation context. If you genuinely can't tell why this change exists, ask — a wrong "why" is worse than none.
3. **Capture proof of behavior** (next section). Run the thing. Do not describe behavior you haven't seen.
4. **Write the prose around the evidence.** Then cut it by a third.

## Evidence: match the proof to the change

Every claim about behavior gets one piece of evidence. Pick by change type:

| Change | Proof |
|---|---|
| UI change | Before/after screenshot — use the **pr-screenshot-comparison** skill, which handles capture, stitching, and `gh --attach` |
| CLI or script behavior | A real terminal transcript, trimmed to the relevant lines, in a fenced block |
| Output/data/API shape | Before and after of the actual payload or output, side by side or stacked, fenced |
| Config or option change | A two-column table: old value → new value, one row per option that changed |
| Structural change (moved/split files, new module) | A small ascii tree or diagram of just the affected part |
| Bug fix | The failing behavior (error message, wrong output) and the fixed behavior |
| Pure refactor | Proof of *no* behavior change: test run output, or identical before/after output |

Rules for evidence:

- It must be real. Run the command, capture the actual output, take the actual screenshot. Fabricated transcripts are worse than no transcript — a reviewer who catches one stops trusting the whole PR.
- Trim hard. Show the 6 lines that matter, not the 60-line scrollback. Use `...` for elided output.
- Ascii diagrams earn their place only when they show a *relationship* prose would garble (flow, hierarchy, before/after structure). A diagram restating one sentence is decoration; cut it.
- Label before/after explicitly. Unlabeled pairs make the reviewer guess.

## Shape: no skeleton, strict budget

Do not use a fixed template. "Summary / Changes / Test plan" headers exist so authors don't have to think; the reviewer pays for that. Let the change dictate the structure — a one-line fix might be two sentences and a transcript with no headers at all.

Every paragraph of prose does one of three jobs: states the change and its why, captions a piece of evidence, or points the reviewer at risk. A paragraph doing none of those gets deleted, however well written — implementation detail the reviewer can read in the diff is the usual offender. Evidence-rich changes are where prose creeps: each new screenshot or transcript tempts you into a paragraph of explanation, but the evidence is there so the prose doesn't have to be. One caption sentence per exhibit.

What every description does need, in this order:

1. **The first line carries the whole PR, told as what a person experienced.** Someone reading only the title and first sentence knows what changed and whether it affects them. Write it the way the bug report or feature request would have read: what someone did, what they saw, what they'll see now — "Uploads no longer vanish when the wifi drops mid-transfer," not "Adds RetryPolicy class to UploadManager." If no human ever experiences the change directly (a refactor, tooling), the person is the next developer: say what *they* no longer have to do or worry about.
2. **Why, in one or two sentences** — the situation that made this worth doing. Link the issue if one exists, but the sentence must stand without clicking it.
3. **The evidence**, with a one-sentence caption each.
4. **Where to look hard**, if anywhere: "The tricky part is the cache invalidation in `sync.ts:141` — the rest is mechanical renames." This is the highest-value sentence in the whole description. If nothing is tricky, say nothing; don't invent a risk section.

Length budget, scaled to the diff:

- Under ~50 changed lines: 1–3 sentences plus one piece of evidence.
- A typical feature: under 150 words of prose. Evidence doesn't count against the budget; prose does.
- Only a genuinely large or dangerous change (migration, breaking API, security fix) justifies headers and more prose — and even then, each section exists because a reviewer needs it, not because a template has it. Renaming the skeleton doesn't escape it: "The bug / The fix / Verification" is the same reflex as "Summary / Changes / Test plan."

The budget is enforced, not aspirational: after writing, count the prose words (everything outside fenced blocks, tables, and image lines — `wc -w` on a stripped copy is fine). Over budget means cut and recount before delivering.

Things that never go in, at any size:

- A file-by-file list of edits. The Files tab already shows this, better.
- Restating what the diff visibly does ("renamed `foo` to `bar`").
- "Test plan: run the tests." If tests are in the diff, they're visible; mention testing only to show evidence of a behavior (see table) or to flag what is *not* covered.
- Openers like "This PR introduces…" — start with the change itself.

## Prose

Follow the **stop-slop** skill if it's available. The load-bearing rules either way:

- Plain subject-verb-object sentences. One idea per sentence.
- Name things concretely: the file, the flag, the error message. "Improves reliability" says nothing; "stops the 3-retry loop from hammering a dead endpoint" says everything.
- Write like a person telling a colleague what they did. It's fine to say "I couldn't reproduce the crash on main, so this fixes the symptom" — honest uncertainty helps the reviewer more than false completeness.
- **No mannered prose.** Mannered prose substitutes metaphor and flourish for direct statement. Instead of "a parameter worth varying," the mannered writer produces "a dial worth turning." Instead of "this point still matters," they write "this point earns its keep." The phrases exist to display the writer, not to convey the idea, and readers can tell. That is why mannered prose irritates: it makes the reader work harder so the writer can perform. It is also imprecise — metaphors drag in connotations the writer did not choose and cannot control. The fix is to say what you mean. When a literal phrase is available, use it.

**The reader is a teammate from a different corner of the codebase.** They know the product and the language, not this module's private vocabulary. Read every sentence as that person. Internal names — cached-box nicknames, driver/manager/reflow terms, demo-page IDs, enum cases — mean nothing to them until you've said the plain-language thing the name stands for. So state cause and effect in ordinary words first ("the animation started from where the element sat *before* you scrolled"), and bring in an internal name only if the reviewer needs it to navigate the diff, glossed in the same breath ("the cached starting position — `First` in the code — ..."). If a sentence only parses for someone who already read the diff, it's a comment for the code, not a sentence for the PR.

One plain sentence of cause is usually the right depth. The full mechanism story — why the caching interacts with scroll, which tick measures what — lives better in the diff and its comments, where it sits next to the code it explains. A reviewer who wants that depth will read the code; the description's job is to make sure they know what they're looking for when they do.

## Delivering it

Open or update the PR with `gh pr create --body-file` / `gh pr edit --body-file`. For image attachments, `gh --attach` uploads and rewrites local paths (details in pr-screenshot-comparison). Never commit screenshots to the branch. After writing, re-read the stored body with `gh pr view --json body` to confirm images render as hosted `user-attachments` URLs.

Append nothing the user didn't sanction (no advertising footers beyond what the harness requires).

## Example

A typical model-drafted description, and what this skill produces instead, for the same change:

**Before (285 words, zero evidence):**

> ## Summary
> This PR introduces comprehensive retry logic for the upload pipeline, enhancing reliability and robustness across transient network failures…
> ## Changes
> - Added `RetryPolicy` class in `upload/retry.ts` encapsulating exponential backoff…
> - Modified `UploadManager` to leverage the new retry mechanism…
> - Updated unit tests to cover the new functionality…
> ## Test plan
> - [x] Unit tests pass
> - [x] Manual testing performed

**After:**

> Failed uploads now retry (3×, exponential backoff) instead of being silently dropped. We were losing ~2% of uploads on flaky hotel wifi — #482.
>
> ```
> # before — one timeout kills the upload
> $ node upload.js big.mp4        # after — same timeout, recovered
> ✗ upload failed: ETIMEDOUT      ⟳ retry 1/3 in 2s… ✓ uploaded (14s)
> ```
>
> Look hard at `retry.ts:52` — the backoff timer isn't cancelled if the user aborts mid-retry. I handle it in `UploadManager.dispose`, but it's the one non-obvious interaction.

The second one is a fifth the length, and the reviewer knows the behavior, the motivation, and the single risky spot before scrolling.
