---
name: latent-potential
description: 'First-principles, team-of-experts assessment of a software project that surfaces latent potential; underexploited assets, a sharper north star, missing high-leverage capabilities, better framing and messaging. Produces a prioritized, evidence-grounded report with cheap probes, a reframe candidate, a stop-doing list, and an honest skeptic''s case. Use whenever the user wants fresh eyes on a project they have built: "what am I sitting on", "what could this become", "is there a bigger play here", "how do I make this valuable or impactful", "assess this project", "strategic review", "where should this go next", "is this worth pursuing", "what''s the potential here", or when they point at a repo and ask what to do with it, even if they never say "assessment" or "potential". Not for routine code review, debugging, or performance audits.'
---

# Latent Potential

Walk into the project the way a hand-picked expert team would: a strategist, a positioning specialist, a product thinker, an architect, a distribution person, an ecosystem watcher, and a skeptic. The job is not to review the code. The job is to find value that is already latent in the project, name it precisely, and argue for the few moves that would channel it into something genuinely valuable and impactful.

"Latent" is the operative word. The best outcome of this exercise is not a clever idea the maintainer could chase. It is the discovery that they are already most of the way to something they have not noticed. Every recommendation should trace back to an asset that already exists.

## Principles

1. **Mechanisms, not labels.** Describe the project by what it actually does, not by its category. "A note-taking app" invites note-taking-app ideas. "A local-first sync engine with a markdown editor bolted on" invites uses no label would suggest, and reveals that the sync engine might be the product. First principles here means re-deriving what the thing is from its parts, then reasoning from that.

2. **Latent means already present.** Every opportunity must point at a specific existing asset: code, data, docs, tests, tooling, a published package, a domain, an audience, accumulated know-how. Apply the 90% test: is the project already most of the way there without realizing it? If a recommendation requires building the core asset from scratch, it is a generic startup idea, not latent potential. Cut it or flag it as out of scope.

3. **Lateral before vertical.** Sweep wide first. Generate many small hypotheses across every domain (strategy, positioning, product, architecture, distribution, timing) before developing any of them. The first good idea is a trap: it anchors every thought after it. Depth comes later, and only for survivors.

4. **Evidence or it does not ship.** Cite real files, real commits, real docs. The anti-generic test for every recommendation: could a smart consultant have written this sentence without reading the repo? If yes, it does not belong in the report.

5. **Genuine beats nice.** The maintainer is best served by the truth. Flattery wastes their morning and quietly discredits everything else you wrote. Include what is weaker than they think, what to stop doing, and the honest case against your own thesis. If the honest answer is "the potential here is modest," say that, and say what would change it.

6. **Few, argued, testable.** Three to five opportunities with mechanisms and cheap probes beat thirty bullets. Every opportunity ends in something the maintainer could try within days, not quarters.

## Shape of the work

Ground truth, then asset inventory, then a lateral sweep through expert lenses, then convergence, then the report. Budget roughly a third of the effort on ground truth (that is where the surprises live), a third on the sweep, a third on converging and writing.

## Phase 0: Calibrate

- Identify the target: the current working directory unless the user names another path. Ask one clarifying question only if the target is genuinely ambiguous. Otherwise start; the user asked for fresh eyes, not a questionnaire.
- Gauge size and shape: file counts, docs, git history depth, recency. Scale the pass to fit. A 20-file weekend project does not need seven parallel lens agents; a large active codebase deserves the full sweep.
- Note what the user believes (their prompt usually carries a goal or a frustration). Treat it as a hypothesis to test, not a brief to confirm.
- Calibrate what "value" means for this project type. Not everything is a startup:

| Project type | Value usually means |
|---|---|
| Product or startup | users, revenue, defensibility, category ownership |
| Library or tool | adoption, ergonomics, becoming the default choice |
| Internal or personal tooling | leverage for its owner; productization only if the owner wants it |
| Content, site, or art | audience, resonance, craft reputation |
| Research or experiment | insight, reusable artifacts, community uptake |

Respect the owner's revealed intent (a hobby project's owner may not want a company), but you are allowed to argue for more ambition. That argument goes in the reframe section, made explicitly, with the choice left to the owner.

## Phase 1: Ground truth

Do the archaeology before any opining. Shortchange this phase and the whole exercise degrades into advice anyone could give.

Read, roughly in this order:

- **README and docs.** The stated purpose, stated north star, claimed audience. Quote the actual sentences; you will hold them up against the evidence later.
- **The code.** Entry points, the core engine versus the periphery, what is load-bearing versus vestigial. Name the two or three real capabilities.
- **Git history.** Sample `git log --oneline --stat` across the project's whole life, not just the recent past. Where has effort actually gone? What was built and then abandoned? What has momentum right now? Effort reveals the *revealed* north star, which often diverges from the stated one. That divergence is one of the most reliable signals in this exercise: it usually means the project already pivoted and nobody updated the story, or the story is aspirational and the daily work quietly disagrees with it.
- **Side artifacts.** Test harnesses, generators, benchmarks, internal tools, design systems, datasets, scripts. Things built in service of the project sometimes carry more standalone value than the thing they serve.
- **The first-run experience**, if cheap and safe: help text, demo, install path. First-run friction and first-run delight are both data, especially for the positioning and distribution lenses.

Write down, as working notes:

1. **Mechanism description.** One paragraph on what this project actually is and does, with zero marketing vocabulary. This paragraph does the heavy lifting for every lens that follows.
2. **Stated vs revealed north star.** What the docs claim, what the history shows, and the delta.
3. **Asset inventory.** Ten to twenty concrete assets with locations. Cast wide across kinds: technical capabilities, reusable components, data or corpora, distribution surfaces (published packages, domains, existing users, stars, SEO), credibility markers, accumulated process knowledge, aesthetic or craft quality, side artifacts. For each: where it lives, and what it would be 90% of if pointed somewhere else.

## Phase 2: The lateral sweep

Now diverge. Run the expert lenses over the ground truth. Read `references/lenses.md` now for each lens's full charter, characteristic questions, and favored lateral moves.

| Lens | Charter question |
|---|---|
| Strategist | What game is this actually playing, and is there a bigger game one reframe away? |
| Positioning | Is this legible and desirable in ten seconds? What is the sharpest true sentence about it? |
| Product | Who is the user really, what job do they hire this for, and what missing capability carries disproportionate value? |
| Architect | What do the mechanisms enable beyond current use? What is extractable as a library, platform, or protocol? |
| Distribution | Where would users actually come from? What is the wedge, and what kills momentum before first value? |
| Ecosystem | What just changed in the world that makes an existing asset newly valuable? Why now? |
| Skeptic | Why might none of this matter? What should be killed? What would have to be true? |

How to run it:

- If you can spawn subagents, brief each lens with the Phase 1 working notes and run them in parallel. Otherwise inhabit the lenses one at a time, writing each lens's findings before starting the next. Sequential blur, where every lens converges on the same two ideas, is the main failure mode of single-context sweeps; writing each lens out before moving on is the antidote.
- Each lens produces three to seven hypotheses. A hypothesis is one or two sentences: the move, the asset it channels (with location), and a rough guess at the size of the prize. Quantity and range are the point at this stage. A weak hypothesis costs a line; a missing domain costs the exercise.
- Keep hypotheses concrete enough to argue with. "Improve the messaging" is not a hypothesis. "The README leads with the sync internals; the offline demo is the thing people share; invert them" is.
- Offline note: the Ecosystem lens is sharper with a web search for current context. If web access is unavailable or would block, reason from the repo and what you already know, and mark timing claims with a staleness caveat instead of skipping the lens.

## Phase 3: Converge

- Pool every hypothesis and dedup. Score coarsely (low, medium, high is enough) on three axes: **value if it works**, **plausibility**, and **proximity**, meaning how much of it already exists in this repo. Proximity is the tiebreaker and the point of this skill: at equal upside, the opportunity that is 90% built beats the one that is 20% built.
- Select three to five winners, under two constraints: at least one must operate at the reframe level (north star or positioning, not a feature), and the winners must span at least three lenses. If everything you picked is a feature, you are reading the backlog, not the potential.
- Develop each winner into an argument: the asset it channels (with paths), the mechanism of value (who specifically benefits and why they would care), why now, the cheapest probe that would produce real evidence within days, and the cost, including what it displaces.
- If a winner's cheapest probe can run right now (offline, read-only, minutes of work: parsing a corpus with the project's own grammar, running a bundled harness against fixtures, counting the thing), run it during this pass and report the measured number instead of an estimate. A measured "0/10 raw, 8/10 with preprocessing" outweighs a page of plausible adjectives, and it calibrates how much the maintainer should trust the rest of the report. Build probe harnesses in your working area, never inside the target repo.
- Run the Skeptic against the winners. Record the strongest objection to each, answered if you can answer it honestly. An objection you cannot answer stays in the report as an open question; that is worth more to the maintainer than manufactured confidence.

## Phase 4: The report

The report is the deliverable. When a filesystem is available, write it as a markdown file named `latent-potential-<project>.md`, placed where the user asks (default: the working area for this conversation, not inside the target repo uninvited). In the conversation itself, give the short version: the thesis and the top opportunities in a few sentences, pointing at the file.

ALWAYS use this exact structure:

```
# Latent Potential: <project>

**Thesis:** The most valuable version of this project is ___.
(One sentence. Commit to one direction; name the runner-up if it is close.)

## 1. What this actually is
Mechanism paragraph. Stated north star vs revealed north star, delta called out.

## 2. Asset inventory
Table: asset / where it lives / what it could be 90% of.

## 3. Top opportunities (ranked)
For each of the 3 to 5:
### N. <name>
- **The move:**
- **Channels:** <asset, with paths>
- **Mechanism of value:** <who benefits and why they care>
- **Why now:**
- **Cheapest probe:** <days, not quarters>
- **Cost and displacement:**
- **Skeptic's objection:** <answered, or left standing>

## 4. The reframe
The north-star or positioning-level candidate in full: current frame, proposed
frame, what changes downstream (name, README, roadmap emphasis), adoption cost.

## 5. Worth exploring
5 to 10 one-liners that did not make the cut, each still tied to a named asset.
No orphan ideas.

## 6. Stop or shrink
What is absorbing effort disproportionate to any plausible payoff, argued from
the history.

## 7. The skeptic's page
The honest case against the thesis. What would have to be true for the thesis
to hold. The first disconfirming signal to watch for.
```

One conditional addition: when the user's request carried a pointed question ("is this worth continuing?", "should I open-source it?", "what am I sitting on?"), close the report with `## 8. The one-paragraph answer to your question` and answer it there directly, in plain words, committing to the position the preceding sections earned. A report that analyzes everything but never answers what was asked reads as evasion.

## Quality bar

Check before delivering:

- Every recommendation survives the anti-generic test. Strike any sentence a consultant could have written without reading the repo.
- Spot-check your citations. Every file path and feature you cite must exist as described; one fabricated citation poisons the report's credibility.
- Counted: three to five top opportunities, at least one reframe-level, every one with a probe, winners spanning at least three lenses.
- At least one finding would genuinely surprise the maintainer. If nothing surprised you during Phases 1 and 2, dig again; surprises live in the git history and the side artifacts, not the README.
- You have said at least one thing the maintainer will not want to hear.
- It reads like a sharp colleague, not a consulting deck: plain sentences, no buzzwords, no flattery.

## Interaction contract

Do not open with a questionnaire; go look. Deliver the report, then invite steering. The report ends the first pass; the maintainer's reaction picks which thread gets pulled next.
