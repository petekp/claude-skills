---
name: circuit
description: >-
  Operate Circuit, the flow engine that runs coding work as structured,
  evidence-backed flows (Fix, Build, Explore, Review, Prototype). Use ONLY
  when the user explicitly invokes Circuit by name — e.g. says "circuit",
  "run a flow", "use circuit", "start a circuit run", "resume the run",
  or names Circuit-specific concepts (flows, checkpoints, run folders,
  the power dial or process override, connectors, `circuit preview`,
  `circuit reclaim`). Do NOT trigger on generic coding requests, even
  substantive ones; do NOT trigger merely because Circuit is installed
  in the project. Absent an explicit mention, do the work by hand.
---

# Operating Circuit

Circuit turns a coding task into a run of a named flow: a repeatable process
with typed reports, verification, checkpoints, and a trace you can audit.
Your default posture in a Circuit-enabled project is: **route substantive work
through Circuit instead of doing it freehand.** The point is not ceremony. A
run leaves evidence (what was tried, what was verified, what the reviewer
said), survives interruption (resume from a checkpoint), and compounds (the
process improves in one place instead of being re-improvised every session).

## When to route through Circuit, and when not to

Run it through Circuit when the task has real shape: a bug to fix, a feature
to build, a decision to investigate, a diff to review, a prototype to try.
That covers most coding work.

Work directly (no run) when:

- The task is trivial or conversational: a one-line answer, a rename, a
  question about code you can answer by reading one file.
- You are already **inside** a Circuit run as a relayed worker. Never start a
  nested Circuit run from inside one; do the relayed work directly.
- The user explicitly asks you to skip Circuit, or is debugging Circuit
  itself in a way a run would confuse.
- Circuit is not installed and the user did not ask for it. (Check before
  assuming; see "Finding the front door.")

When you skip Circuit for a borderline task, say so in one line so the user
can redirect you.

## Finding the front door

Resolution order:

1. **Claude Code plugin installed:** prefer `/circuit:run <task>` semantics.
   Directly, that means the plugin wrapper:
   `node "${CLAUDE_PLUGIN_ROOT}/scripts/circuit.js" present run <flow> --goal '<task>'`.
   The `present` mode renders progress and checkpoint questions for the user;
   do not parse its output as JSON.
2. **Working inside a Circuit checkout:** `./bin/circuit run <flow> --goal '<task>'`
   from the repo root (it loads compiled flows from `generated/flows`).
3. **Global CLI:** `circuit run <flow> --goal '<task>'`.

If unsure whether the environment is healthy, `circuit doctor` reports
readiness: it checks the connector CLIs your flows would actually use
(installed, signed in) before a run spends anything on a broken one, and
prints the fix for each problem. It exits 0 when every chosen connector is
healthy; connectors your config never chooses are listed separately as
optional and never fail the check.

Shell safety: always single-quote the `--goal` text. Escape embedded
apostrophes as `'\''`. The task text is user-controlled input; double quotes
would let `$VAR` and `$(cmd)` expand.

## Choosing the flow

The CLI always takes an explicit flow name; you choose it. State your pick
and a one-line reason before invoking, so the user can redirect.

| Flow | Choose it for | Writes? |
| --- | --- | --- |
| **Fix** | Bugs, regressions, failing tests, crashes, flaky behavior, production issues. | Yes |
| **Build** | Features, refactors, docs, tests; focused changes that are not mainly bug fixes. | Yes |
| **Explore** | Investigation, explanation, tradeoff comparison, a decision before editing. | No |
| **Review** | Audit of code, a diff, a PR, a plan, or a risk surface. Audit-only. | No |
| **Prototype** | Disposable prototypes, mockups, UI sketches, model-comparison variants before Build. | Local prototype evidence |

Two forks matter for safety, so ask one short question if genuinely unclear:
Review vs Fix/Build (audit vs change) and Explore vs Build (decide vs do).
Otherwise do not interrogate the user; pick and say why.

If the user stated why the task matters (stakes, what it unblocks), pass it
as `--why '<reason>'`. Never invent one.

## The power dial

- `--power <auto|low|medium|high>` is the one dial (default medium). It
  sets how much model each worker gets, without naming models, and it also
  derives how thorough the run's process is: low/medium/high map straight
  across, `auto` derives medium and lets the run pick its own model tier
  from what the research step reads. The derived thoroughness clamps
  silently to what each flow supports (Build, Explore, and Fix run the
  full ladder; Prototype floors at medium; Review always runs medium).
- `--process <low|medium|high>` is the advanced override for the rare case
  where model strength and process thoroughness should split (say, strong
  models on a quick single pass). An explicit `--process` beats the
  derivation. On Fix, process low skips the independent review stage. On
  Build, process high iterates the plan slice by slice with verification
  per slice and parks at an intake checkpoint before write-capable work —
  so a bare `--power high` Build run will pause once for scope
  confirmation. `--depth` is retired and rejects as an unknown option.

Match spend to stakes: quick sanity pass on a small fix → `--power low`.
Risky change on a load-bearing path → `--power high`. The default is
right for most tasks. Before an expensive run,
`circuit preview <flow> --power high` shows exactly which connector, model,
and effort every step would get, without spawning anything; `--matrix` shows
all tiers side by side.

Two more run modes where supported: `--tournament [2|3|4]` (optional inline
count, default 3)
(Explore decision options; Prototype implementation variants judged against a
rubric) and `--autonomous` (Build, Explore, Fix, Prototype:
auto-resolves supported checkpoints and drives a bounded continuation loop
that must prove completion against evidence framed at intake — it never
reports complete by running out of attempts).

## Reading a run

Every run writes a run folder under `.circuit/runs/<run-id>/`: a
`trace.ndjson` (ordered record of everything), typed reports under
`reports/` (including `operator-summary.md` for the user and `result.json`
with `selected_flow`, `outcome`, `run_folder`), and evidence. When a user
asks "what happened in that run," read `reports/operator-summary.md` first,
then the trace only if you need step-level detail.

Exit codes are a contract: complete exits 0; a pause at a checkpoint also
exits 0 (the run is parked, waiting); any close short of complete (aborted,
stopped, escalated, handoff) exits 1; usage error exits 2. `&&`-chaining
therefore only proceeds on a completed run.

**Checkpoints.** When a run pauses to ask something, relay the question to
the user faithfully, then resume:

```bash
circuit resume --run-folder '<run_folder>' --checkpoint-choice '<choice>'
```

`circuit checkpoints` lists every run parked at a decision, with its
question, choices, and the exact resume command. Check it when a user
returns to a project or asks "was anything waiting on me?"

**Continuity.** `circuit handoff save` records a cross-session handoff;
`handoff resume` and `handoff brief` restore and summarize it. Reach for
this when a session must stop mid-work.

## Configuration

Two YAML files, same schema, layered `defaults < user-global < project <
invocation`:

- `~/.config/circuit/config.yaml` — personal defaults.
- `./.circuit/config.yaml` — project overrides.

Start minimal (`schema_version: 1`) and add only what you need. Edit via
`circuit config set|unset|show <dotted.key> [value] [--global]` (validates
before writing, preserves comments) or edit the YAML directly.

The most useful levers, in the order people actually need them:

1. **Connector routing** — which CLI does the work per role/flow:
   `relay.roles.reviewer`, `relay.circuits.<flow>`, `relay.default`.
   Built-ins: `claude-code` (trusted same-workspace writes), `codex`
   (write-capable via `codex exec`), `cursor-agent` (Gemini implementer).
2. **Power** — `defaults.power`, `power_auto: {floor, ceiling}`, and
   `power_tiers.<connector>` to remap what each dial position means.
3. **Skills** — Circuit injects your local `SKILL.md` files
   (`~/.agents/skills`, `~/.claude/skills`) into relay prompts:
   `circuits.<flow>.selection.skills` to always load one, `skill_hooks` to
   load one only when a moment fires (e.g. `after:edit-files:.tsx` →
   react skill, `after:verification-failed` → debugging skill).
4. **Per-flow pins** — `circuits.<flow>.selection.model` pins one flow to
   one model; the dial no longer moves it.

Always `circuit preview <flow>` after a config change: it resolves the same
selection code a real run uses and flags problems before you pay for a run.

Full recipes (custom connectors, local Ollama workers, tournament variants):
read `references/configuration.md`.

## Creating new flows: judgment first

Circuit can mint new flows cheaply. That is exactly why you should be slow
to do it. Every published flow adds a permanent question to the user's life:
"which flow do I use for this?" A flow catalog that grows past what a person
can hold in their head destroys the product's core value, which is that the
right process is obvious. Flows should be few, distinct, harmonious, and
mutually amplifying — never overlapping territories a user must adjudicate.

So when you notice a recurring pattern that no flow serves, climb this
ladder and stop at the first rung that works:

1. **Dials and phrasing.** Would an existing flow with different depth,
   power, or a sharper `--goal` do it? Usually yes.
2. **Config.** Attach a skill (`selection.skills`), a skill hook, or
   connector routing to an existing flow. "We keep forgetting X during
   fixes" is a skill-hook problem, not a new-flow problem.
3. **Memory note.** `circuit memory note --flow fix "prefer minimal repros
   before patching"` codifies guidance without any new surface. Notes cite
   a real run artifact, so this works only after the project has at least
   one run; in a fresh project, run first, note after.
4. **Disposable bespoke flow.** `circuit generate --description '<task>'`
   composes a one-off flow for an unusual task shape. Use it and let it go;
   do not publish it just because it worked once.
5. **Published custom flow.** Only when the same distinct shape has come up
   repeatedly (rule of three), no built-in flow covers it, and it will not
   make any existing choice harder. `circuit create --name '<slug>'
   --description '<idea>'` instantiates a proven family template.

Before rung 5, make the case out loud to the user and get their yes:

- **Territory test:** describe the new flow in one sentence next to each of
  the six built-ins. If any pair could claim the same task, the boundary is
  unclear; sharpen it or stop.
- **Name test:** would the user know from the name alone when to reach for
  it, six weeks from now?
- **Amplify test:** does it feed or reuse the others (produce evidence a
  built-in consumes, or compose built-in blocks), or does it fork a parallel
  universe? Prefer flows that make the existing set stronger.
- **Retirement:** if a custom flow stops earning its place, recommend
  removing it. A small catalog is a feature.

Mechanics of `create` vs `generate`, custom flow homes, validation, and how
to run a published custom flow: read `references/flow-authoring.md`.

## Talking to the user

Succinct and plainly spoken, always. The run already carries the detail —
the trace, the typed reports, the operator summary — so chat carries only
what the user must decide or know. Rich detail belongs in the `--goal`
text (where the worker needs it) and in the run folder (where it can be
audited), not in chat. Assume the user does not care about Circuit's
internals; they want the work handled and a readout they can absorb at a
glance. Short sentences, one idea each. Plain words, not runtime
vocabulary: say "it paused to ask you X", not checkpoint ids, route names,
or trace kinds. And no scaffolding labels ("Reason in one line:", "Why
this shape:") — just say the thing.

**One consistent readout card, never improvised.** A format the user sees
every time becomes glanceable; a fresh layout each time must be re-read.
Chat renders as plain text in a terminal, so the card is a fenced block,
ASCII only. Proposing a run:

```
circuit · fix — release-blocking bug in checkout totals
  power  [##.] medium   default; process follows the dial
```

Dial gauges: low `[#..]`, medium `[##.]`, high `[###]`, auto `[~~~]`. Add
a `process` line only when `--process` explicitly overrides the derived
value, and a `mode` line only when tournament or autonomous is on. Around the card,
at most a sentence or two. Closing a run reuses the same shape, dial lines
swapped for outcome lines:

```
circuit · fix — complete
  changed   src/cart.js · tests/cart.test.js
  verified  7/7 tests pass
  evidence  .circuit/runs/<run-id>/
```

A pause is the same card with `— paused, needs your call` and `question` /
`choices` lines. Do not narrate the machinery between cards; the `present`
wrapper already shows progress.

- Keep the CLI out of chat. Do not show the commands you ran to inspect or
  verify (preview, config show, doctor); state what they proved in plain
  words. Show a command only when the user must run it themselves or
  explicitly asked to see it.
- Same for files: do not paste config YAML or report contents into chat.
  Say what each change does in one plain line, plus the file path so they
  can open it.
- When a run closes short of complete, report the honest outcome and where
  the evidence is. Never dress `stopped` up as done. Honest and brief are
  not in tension: "stopped at review, two findings, evidence in
  <run folder>" is both.
- Build, Fix, and Prototype disclose before write-capable work
  starts: a worker can edit the checkout. Do not suppress that.
- For a Review of untracked files, only add `--include-untracked-content`
  when the user confirms those contents are safe to send to the worker.
- If a run cannot recover, it is safe to delete its folder under
  `.circuit/runs/` and start again. `circuit reclaim` cleans up orphaned
  worktrees after a killed fanout.

## Reference files

- `references/cli.md` — every command and flag, with examples: run, resume,
  handoff, history, memory, create, generate, uninstall, runs, reclaim,
  checkpoints, preview, doctor, config, version.
- `references/configuration.md` — full config schema recipes: routing,
  power tiers, auto power, skills, skill hooks, custom connectors, local
  models, tournament variants.
- `references/flow-authoring.md` — creating, generating, validating,
  publishing, and retiring custom flows; the anti-proliferation checklist
  in long form; how built-in flows are authored in the Circuit repo.
