# Frame moves, the canonical ladder, and worked examples

Read this when you need help generating alternative frames, or when you want the
source material behind the method.

- [Moves for generating frames](#moves-for-generating-frames)
- [The canonical ladder](#the-canonical-ladder)
- [Single loop and double loop](#single-loop-and-double-loop)
- [Worked example: a bug that keeps coming back](#worked-example-a-bug-that-keeps-coming-back)
- [Worked example: a product metric](#worked-example-a-product-metric)
- [Worked example: an org problem](#worked-example-an-org-problem)
- [Sources](#sources)

## Moves for generating frames

Alternative frames are not brainstormed. They are produced by applying a move to
rung one and seeing whether the result still fits the evidence. Try several;
keep the ones that survive.

**Change the actor.** "Users are confused" and "we are confusing users" and "the
wrong users are arriving" all fit the same data and imply completely different
work.

**Change the level.** Is this an instance or a class? A bug fixed three times is
usually a process problem wearing a code problem's clothes.

**Look outside the boundary.** The frame drew a line somewhere. What sits just
outside it? The classic case is the slow elevator: tenants complained about wait
times, and the fix was mirrors in the lobby, because the real frame was "waiting
is boring" rather than "the elevator is slow." Nobody measured the elevator wrong.
They measured the right thing inside the wrong boundary.

**Bright spots.** Where does the problem *not* occur? Cases where it should
happen and doesn't carry more information about mechanism than more examples of
it happening.

**Look in the mirror.** What is our own contribution to this? Argyris's central
finding was that people reliably exclude themselves from their causal account.

**Take their perspective.** How would the person on the other side state this
problem? If their version is coherent, yours is at best partial.

**Invert.** What if the observation means the opposite of the obvious reading?
High support volume can mean a broken product or an engaged one.

**Dissolve rather than solve.** Ackoff's move: change the system so the problem
stops arising, instead of getting better at handling it. Ask what would have to
be true for this problem to be impossible.

**The null frame.** Not a problem, or not worth solving. Always test this one.

## The canonical ladder

Argyris's ladder, as presented in *The Fifth Discipline Fieldbook*, bottom to top:

1. Observable data and experience — what a videotape would capture
2. Selected data — the part I attend to
3. Added meanings — cultural and personal
4. Assumptions — built on the meanings I added
5. Conclusions
6. Beliefs — what I now hold about the world
7. Actions — taken on those beliefs

The **reflexive loop** matters as much as the rungs: beliefs at rung six shape
which data gets selected at rung two next time. This is why a wrong frame is
self-confirming and why teams can accumulate years of evidence for a problem they
do not have.

The seven rungs are useful for understanding and clumsy for output. Rungs three
and four blur in practice. Compress to four questions when working: what was
recorded, what was selected, what it was taken to mean, what was concluded.

## Single loop and double loop

Single-loop learning detects an error and corrects it within the existing goals.
The thermostat is the standard illustration: it senses the room is cold and turns
on the heat.

Double-loop learning questions the governing variable itself. The thermostat that
asks whether 68 degrees is the right target is doing double-loop learning.

Type III error lives in both places. The ladder catches the single-loop version,
where the diagnosis outran the data. The double-loop check catches the version
where the diagnosis is correct and the goal is wrong. Argyris's observation was
that organizations are structured to make double-loop learning socially costly,
which is why the wrong-goal version survives so much longer than the
wrong-diagnosis version.

## Worked example: a bug that keeps coming back

```
STATED   "There's a race condition in the upload handler."

LEAP     Rung one is three incident reports over five months, each showing a
         truncated file, and two prior commits both described as "fix upload
         race." Nothing observed shows concurrent access. "Race condition" is
         the conclusion that survived last time, not a finding.

FRAMES   A. Genuine concurrency bug the two prior fixes narrowed but missed —
            requires the truncations to correlate with concurrent requests
         B. Client-side aborts on slow connections, arriving as truncated
            uploads — requires the incidents to skew toward mobile or high-RTT
         C. Null: three events in five months on a path handling 40k/day is
            within the failure rate of the storage layer's own SLA

TEST     Pull the request IDs from the three incidents and check connection
         duration and client type against a sample of successful uploads.
         ~30 minutes in the log store.
         Concurrent in-flight writes to the same key supports A; long duration
         plus mobile client supports B; neither pattern supports C.
```

Note what the two prior fixes are doing in the analysis. They are not background.
Repeated failure to fix is itself rung-one evidence about the frame.

## Worked example: a product metric

```
STATED   "Activation dropped 12% this quarter, our onboarding got worse."

LEAP     Rung one is a dashboard number. Before it means anything, the event
         definition has to be read: `activated` fires on first workspace
         invite sent. The statement assumes the metric measures onboarding
         quality. It measures one specific action.

FRAMES   A. Onboarding genuinely degraded — requires the drop to appear in
            step-level completion, not just the terminal event
         B. Mix shift: more solo signups from the new self-serve channel, who
            have nobody to invite — requires the drop to concentrate in that
            channel and vanish when segmented
         C. Null: the invite flow moved behind a new nav item in the March
            release and the metric now under-counts the same behavior

TEST     Segment the metric by acquisition channel and overlay the March
         release date. ~20 minutes.
         A drop across all channels supports A; a drop confined to self-serve
         supports B; a step function at the release date supports C.
```

C is the frame that costs the most to miss, because a quarter of work aimed at A
would ship, move nothing, and leave the instrumentation bug in place.

## Worked example: an org problem

```
STATED   "Code review is our bottleneck — PRs sit for days."

LEAP     Rung one is a median time-to-first-review of 31 hours and six people
         saying review is slow. "Bottleneck" adds the claim that review is what
         constrains throughput, which nothing measured establishes.

FRAMES   A. Reviewer capacity — requires the wait to track reviewer load
         B. PR size: median diff is 800 lines, and large PRs wait because they
            are expensive to review — requires wait time to scale with size
         C. Null: review wait is not on the critical path, because the same
            work is blocked downstream on a weekly release train anyway

TEST     Scatter time-to-first-review against diff size for the last 200 PRs,
         and compare merge-to-deploy against open-to-merge. ~1 hour.
         Flat against size supports A; a clear slope supports B; a
         merge-to-deploy time that dwarfs review wait supports C.

GOAL     If C holds, the governing goal is worth examining. The team is
         optimizing PR latency while the release cadence sets throughput.
         "How do we review faster" is a single-loop question inside a frame
         where the answer cannot matter.
```

## Sources

- Chris Argyris, *Overcoming Organizational Defenses* (1990) — ladder of
  inference, theories-in-use, defensive routines
- Senge et al., *The Fifth Discipline Fieldbook* (1994) — the ladder as usually
  drawn, plus the reflexive loop
- Argyris & Schön, *Organizational Learning* (1978) — single- and double-loop
- A.W. Kimball, "Errors of the Third Kind in Statistical Consulting" (1957) —
  the right answer to the wrong problem
- Mitroff & Featheringham, "On Systemic Problem Solving and the Error of the
  Third Kind" (1974); Mitroff, *Smart Thinking for Crazy Times* (1998)
- Russell Ackoff on messes, and on dissolving rather than solving
- Thomas Wedell-Wedellsborg, *What's Your Problem?* (2020) — the reframing moves,
  including the slow elevator
- Donald Schön, *The Reflective Practitioner* (1983) — problem setting vs solving
- Rittel & Webber, "Dilemmas in a General Theory of Planning" (1973) — for wicked
  problems, formulating the problem *is* the problem

A caution on the term: "Type III error" also has a competing statistical meaning
from Mosteller (1948) — correctly rejecting the null but getting the direction of
the effect wrong. This skill uses Kimball's and Mitroff's sense. If a user is
asking about directional errors in a hypothesis test, they want statistics, not
this.
