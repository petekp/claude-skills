---
name: frame-check
description: Check whether the stated problem is the right problem before work commits to it. Walks a problem statement back down to what was actually observed, names where the inference leapt, and returns competing frames plus the cheapest observation that would tell them apart. Use when the user asks "is this the right problem", "frame check", "what if the real problem is something else", "are we sure that's the cause", "reframe this", or questions a diagnosis. Also use proactively at the moments where solving the wrong problem is most likely and most expensive: a bug that keeps coming back after being fixed, a PRD or project whose problem statement is asserted rather than evidenced, a post-incident review, or the start of a large effort whose direction rests on an unexamined diagnosis. Do not use to pressure-test a plan whose problem is already settled, and do not use on small well-specified tasks where the frame is not in doubt.
---

# Frame check

Most failed work is not a wrong answer. It is a right answer to the wrong
question. Kimball named this the error of the third kind in 1957 and Mitroff
built a practice on it. The work is rigorous, the execution is clean, and it is
aimed at something that was never the problem.

Catch it before the work commits.

## What you are looking for

A problem statement arrives sounding like an observation. "Onboarding is too
slow." "Users are confused." "It's a race condition." None of those are
observations. Someone watched something, selected part of it, decided what it
meant, and concluded — and the sentence you received is the last link with the
chain removed. Your job is to put the chain back and ask what else the bottom of
it supports.

Two different failures produce a wrong problem, and they need different tools.

**The conclusion outran the evidence.** What was observed supports several
readings, and one got picked without anyone noticing a choice was made. Argyris's
ladder of inference is the tool here: walk back down to what a camera would have
recorded.

**The evidence is sound and the goal is wrong.** The diagnosis holds up and is
aimed at an objective nobody has examined. Climbing down the ladder will never
find this, because the goal never entered as evidence. Argyris's double-loop
learning is the tool: ask which governing goal makes this count as a problem at
all.

Check the first. Check the second before you finish.

## 1. Get rung one before you say anything

The bottom rung is observable data — what a recording device would have captured,
before anyone interpreted it. Go find it. An assertion about the evidence that
you did not actually check is the same error you are here to catch.

Where rung one usually hides:

- **A recurring bug.** `git log` the file. Has this been "fixed" before, and
  what did each fix assume? Three fixes to one symptom is strong evidence the
  frame is wrong, not that the engineers were careless.
- **An incident or failure.** The raw stack trace and log lines, not the summary
  of them. Summaries are already rung three.
- **A metric.** How the dashboard actually computes it, in the query or the
  event definition. Metric names drift from metric definitions constantly, and a
  problem stated in terms of a name is often a problem about something else.
- **A user complaint.** The verbatim, not the paraphrase in the ticket title.
- **A "slow" or "flaky" claim.** The actual numbers and their distribution. "Slow"
  is never rung one.

When you genuinely cannot reach any of it, say so plainly and name the smallest
thing that would produce it. "There is nothing at rung one here; the fastest way
to get some is X" is a legitimate and useful answer. Inventing an analysis on top
of an empty bottom rung is not.

## 2. Separate what was seen from what was concluded

Do not produce a rung-by-rung table. The canonical ladder has seven rungs and
several of them do not separate cleanly under pressure, so filling in all seven
yields a worksheet rather than a finding. Use it as a lens and report only the
catches.

Ask, in order, and keep the answers to yourself:

- What would a camera have recorded?
- Which part of that got attended to, and what got dropped?
- What was it taken to mean?
- What was concluded, and what is being done about it?

The catch is wherever an answer is larger than the answer beneath it. That is the
leap. Name it in one sentence, quoting the stated problem and the observation it
actually rests on.

## 3. Generate frames the evidence supports

Three or so, no more. Every frame must be consistent with rung one — a fabricated
alternative is worse than no alternative, because it costs the user attention and
teaches them to distrust the exercise.

Always include the null frame: this is not a problem, or not one worth solving.
Maybe the signal is noise, maybe the cost of the fix exceeds the cost of living
with it, maybe the population you are worried about was never going to convert.
Solving a non-problem is a Type III error too, and it is the one nobody checks
for.

For the generative moves — changing the actor, changing the level, looking
outside the boundary, bright spots, inversion, Ackoff's dissolve — read
`references/frame-moves.md`. It also carries the canonical ladder and worked
examples across a bug, a product metric, and an org problem.

## 4. Land a discriminating test

Argyris cared about making inferences *testable*, not merely visible. A frame
check that ends in doubt has made the user worse off: they now have less
confidence and no more information. Always land the next observation.

A good test is cheap (minutes or hours), decisive (the frames predict different
results), and available (the data exists or can be got today). State which result
supports which frame **before** it runs. Predicting in advance is what stops the
result from being absorbed into whichever frame someone already preferred.

If no cheap test discriminates, say that too, and name the expensive one. That is
still more useful than a list of possibilities.

## 5. Double-loop check

Before you finish, ask once: what goal makes this a problem? Then ask whether
that goal is the right goal.

Some signals that the goal is the rotten part rather than the diagnosis — the
same problem keeps recurring in different clothes, the fix always trades against
something nobody will name, or the honest answer to "what happens if we just
don't solve this?" is "not much."

If the goal survives, do not mention it. If it does not, that is the finding, and
it outranks everything above it.

## Output

```
STATED   <the problem as given, quoted>

LEAP     <what rung one actually is, and where the statement outran it>

FRAMES   A. <frame> — requires <assumption>
         B. <frame> — requires <assumption>
         C. <null frame, when live>

TEST     <the observation> — <cost>.
         <result X> supports A; <result Y> supports B.
```

Add a `GOAL` block only when the double-loop check fires. Keep the whole thing
short enough to read in under a minute; this is a redirect, not a report.

## Asking questions

Analyze first, then ask only what is load-bearing. A question is load-bearing
when the two answers lead to different work — if both roads end at the same next
step, the question is curiosity and it costs the user time.

Cap it at three. Give your best guess alongside each one so the user can correct
you rather than compose an essay.

## When to stand down

Say the frame holds, in two sentences, and stop. Do it when rung one is present,
the stated problem is a fair reading of it, and the alternatives you considered
are ruled out by the evidence.

Manufacturing a reframe when the frame is sound is itself an error of the third
kind — you would be solving a framing problem that does not exist. The skill is
worth having only if it can return "this is right, go" and mean it.

## What goes wrong

- **Worksheet theater.** Seven labelled rungs, no finding. The rungs are for you.
- **Doubt with no exit.** Alternatives listed, no test named, user now stuck.
- **Invented frames.** Alternatives rung one does not actually support.
- **Hobby-horse reframing.** Every problem turns out to be the thing you already
  wanted to talk about. Frames must come from the evidence, not from you.
- **Firing on small tasks.** A well-specified two-hour job does not need this.
  The cost of a frame check should scale with the cost of being wrong.
