# Cognitive Foundations

Mental models, error psychology, attention, and measurement approaches for interaction design.

## Table of Contents
- [Mental Models and Conceptual Design](#mental-models-and-conceptual-design)
- [The Seven Stages of Action](#the-seven-stages-of-action)
- [Error Psychology](#error-psychology)
- [Attention and Cognitive Load](#attention-and-cognitive-load)
- [Measurement Approaches](#measurement-approaches)
- [The Syntactic/Semantic Model](#the-syntacticsemantic-model)

---

## Mental Models and Conceptual Design

### The Three Models

**Designer's model:** How the designer thinks the system works. Complete, technically accurate, often complex.

**System image:** What the user perceives—the interface, documentation, feedback, behavior. The only access users have to the designer's model.

**User's model:** How the user thinks the system works. Built from experience with the system image plus prior knowledge.

```
Designer's Model  →  System Image  →  User's Model
     (truth)          (artifact)       (belief)
```

**The gap problem:** Users form their mental model from the system image, not the designer's model. If the system image is unclear, incomplete, or misleading, users form incorrect mental models—and blame themselves when things go wrong.

### Designing the System Image

The system image must communicate:

1. **What can I do?** (Affordances via signifiers)
2. **What is the current state?** (Visible status)
3. **What just happened?** (Feedback)
4. **What will happen if I do X?** (Predictability via consistency)
5. **How do I undo/recover?** (Reversibility)

**Red flags in your design:**
- Users ask "Did that work?"
- Users develop superstitions ("I always click twice")
- Users are surprised by outcomes
- Users describe the system incorrectly but functionally

### Affordances and Signifiers

**Affordance:** A relationship between object and agent—what actions are possible. A button affords pressing. A handle affords pulling.

**Signifier:** A perceptible signal indicating where action is possible and how to perform it. The raised appearance of a button signifies "press me." The position of a handle signifies "grasp here."

**Design principle:** Affordances may exist without signifiers (a flat region that responds to touch), and signifiers may exist without affordances (a decorative button that doesn't do anything). Good design ensures signifiers accurately indicate real affordances.

| Element | Signifier Type | What It Communicates |
|---------|----------------|----------------------|
| Raised button | Visual depth | "I can be pressed" |
| Underlined text | Convention | "I'm a link" |
| Grab handle (⋮⋮) | Icon metaphor | "Drag me" |
| Cursor change | System feedback | "This is interactive" |
| Text placeholder | Position | "Type here" |

---

## The Seven Stages of Action

Every interaction involves seven psychological stages:

### The Execution Side (Planning → Doing)

1. **Goal:** Form the goal (What do I want to accomplish?)
2. **Plan:** Form the intention (What action will achieve my goal?)
3. **Specify:** Specify the action sequence (What exact steps?)
4. **Perform:** Execute the action (Do it)

### The Evaluation Side (Perceiving → Understanding)

5. **Perceive:** Perceive the state of the world (What happened?)
6. **Interpret:** Interpret the perception (What does this mean?)
7. **Compare:** Compare outcome to goal (Did I succeed?)

### Design Implications

**Gulf of Execution:** Distance between user's goal and available actions
- Reduce by: Clear affordances, visible actions, minimal steps

**Gulf of Evaluation:** Distance between system state and user's understanding
- Reduce by: Visible feedback, clear status, interpretable responses

| Stage | Gulf | Design Question |
|-------|------|-----------------|
| Goal | — | Is the user's goal achievable here? |
| Plan | Execution | Can user figure out what to do? |
| Specify | Execution | Can user determine exact actions? |
| Perform | Execution | Can user physically execute? |
| Perceive | Evaluation | Is feedback visible/audible? |
| Interpret | Evaluation | Is feedback understandable? |
| Compare | Evaluation | Can user tell if goal is achieved? |

---

## Error Psychology

### Two Types of Errors

**Slips:** User intended correctly, but executed incorrectly
- Cause: Attention failure, motor error, habit intrusion
- Example: Clicking the wrong button in a familiar position

**Mistakes:** User formed an incorrect goal or plan
- Cause: Incomplete knowledge, incorrect mental model
- Example: Using "Save As" when trying to rename a file

### Types of Slips

| Slip Type | Cause | Design Prevention |
|-----------|-------|-------------------|
| **Capture** | Habit overrides intention | Don't put dangerous actions where safe ones usually are |
| **Description** | Similar objects confused | Make different things look different |
| **Data-driven** | External trigger overrides intention | Remove misleading environmental cues |
| **Associative** | Memory triggers wrong response | Consistent mapping across the interface |
| **Loss-of-activation** | Forgot intention mid-action | Show progress, maintain context |
| **Mode** | Forgot current mode | Make modes visible, minimize modes |

### Types of Mistakes

| Mistake Type | Cause | Design Prevention |
|--------------|-------|-------------------|
| **Rule-based** | Applied wrong rule | Clear feedback on rule application |
| **Knowledge-based** | Incomplete mental model | Improve system image, provide guidance |
| **Memory-lapse** | Forgot goal or step | Visible state, breadcrumbs, history |

### Forcing Functions

Constraints that make errors impossible or immediately visible:

**Interlocks:** Prevent operation until prerequisites met
- Example: Can't start car without brake pedal pressed
- Example: Can't submit form until required fields filled

**Lockins:** Prevent stopping mid-operation when dangerous
- Example: Warning before closing unsaved document
- Example: Requiring confirmation before abandoning wizard

**Lockouts:** Prevent entering dangerous states
- Example: Graying out unavailable options
- Example: Rate limiting on destructive actions

### Error Messages That Help

**Bad error message:**
```
Error 403: Access Denied
```

**Good error message:**
```
You don't have permission to edit this file.

This file belongs to Sarah Chen. You can:
• Request edit access from Sarah
• Make a copy you can edit
• View in read-only mode
```

**Error message checklist:**
- [ ] What happened (briefly)
- [ ] Why it happened (if knowable and useful)
- [ ] What user can do to recover
- [ ] Tone: helpful, not blaming

---

## Attention and Cognitive Load

### The Locus of Attention

Users can only focus on one thing at a time. Everything else is peripheral.

**Design implications:**
- Feedback must appear at or near the locus of attention
- Controls for an object should be near that object (spatial offset)
- Mode indicators far from work area will be missed
- Notifications compete for attention—use judiciously

### Working Memory Limits

Users can hold roughly 4±1 chunks in working memory.

**Design implications:**
- Don't require remembering information across screens
- Visible state beats remembered state
- Group related items into chunks
- Recognition beats recall

### Cognitive Load Types

**Intrinsic load:** Inherent complexity of the task
- Can't reduce without simplifying the task itself
- Can distribute across time (progressive disclosure)

**Extraneous load:** Load imposed by poor design
- Reduce: clearer language, visible state, consistent patterns
- This is the load interaction design can eliminate

**Germane load:** Load from learning and schema formation
- Support: clear conceptual model, meaningful feedback
- This is productive load—don't eliminate it

### Attention Design Principles

| Principle | Application |
|-----------|-------------|
| Proximity | Related controls near related content |
| Change blindness | Animate changes to draw attention |
| Inattentional blindness | Don't rely on noticing unexpected elements |
| Cognitive tunneling | Stressed users miss peripheral information |
| Habituation | Familiar patterns need less attention |

---

## Measurement Approaches

### When to Measure

Measurement is valuable but not always necessary. Consider:

- **High-frequency interactions:** Worth optimizing (measure)
- **Infrequent interactions:** Discoverability matters more than speed
- **Critical interactions:** Error rate more important than speed
- **Playful interactions:** Enjoyment may trade off against efficiency

### GOMS (Goals, Operators, Methods, Selection)

Predictive model for expert performance time.

**Components:**
- **Goals:** What user wants to accomplish
- **Operators:** Elementary actions (keystroke, mouse move, mental operation)
- **Methods:** Sequences of operators to accomplish goals
- **Selection rules:** How users choose between methods

**Use when:**
- Comparing alternative designs for same task
- Estimating expert performance time
- Identifying bottlenecks in workflows

**Limitation:** Assumes error-free expert performance. Doesn't model learning, errors, or satisfaction.

### Keystroke-Level Model (KLM)

Simplified GOMS for quick estimates.

| Operator | Symbol | Time |
|----------|--------|------|
| Keystroke | K | 0.2s |
| Point with mouse | P | 1.1s |
| Home hands | H | 0.4s |
| Mental preparation | M | 1.35s |
| System response | R | varies |
| Button press | B | 0.1s |

**Example:** Click a button, type 5 characters, click OK
```
P + B + M + 5K + P + B = 1.1 + 0.1 + 1.35 + 1.0 + 1.1 + 0.1 = 4.75s
```

### Fitts's Law

Time to acquire a target is a function of distance and size.

```
Movement Time = a + b × log₂(2D/W)
```

Where D = distance to target, W = width of target.

**Design implications:**
- Make frequent targets larger
- Put frequent targets closer (or at screen edges where distance is "infinite" but acquisition is easy)
- For touch, increase target size for error reduction

### Hick's Law

Time to decide increases with number of choices.

```
Decision Time = a + b × log₂(n)
```

Where n = number of choices.

**Design implications:**
- Reduce choices through progressive disclosure
- Group choices into categories
- Provide defaults and recommendations

### What to Actually Measure

| Metric | What It Shows | When to Use |
|--------|---------------|-------------|
| Task completion rate | Can users succeed? | Critical workflows |
| Time on task | Efficiency | Frequent tasks |
| Error rate | Quality of outcome | Error-prone areas |
| Learnability | Time to first success | New features |
| Satisfaction (SUS, etc.) | Subjective experience | Overall assessment |
| Attention shifts | Cognitive load | Complex interfaces |

---

## The Syntactic/Semantic Model

### Why Direct Manipulation Works

Shneiderman's key insight explains why direct manipulation feels natural:

**Semantic knowledge:** Understanding of the problem domain
- What files are, what editing means, what a document is
- Stable, transferable across systems
- Learned through explanation and analogy

**Syntactic knowledge:** Arbitrary details of command syntax
- Specific keystrokes, menu locations, command names
- Volatile, system-specific
- Learned through memorization and practice

**Direct manipulation works because it operates at the semantic level.** Users think "move this file there" and directly enact that intention. They don't translate the intention into syntactic commands like `mv /source/file.txt /dest/`.

### Cognitive Cost of Syntax

With command languages:
```
Goal → Semantic decomposition → Syntactic specification → Execution
```

With direct manipulation:
```
Goal → Direct enactment → Execution
```

The syntactic specification step is eliminated, reducing cognitive load and error opportunity.

### Design Implications

| Approach | Cognitive Load | Error Rate | Expert Speed |
|----------|----------------|------------|--------------|
| Direct manipulation | Low | Low | Moderate |
| Command language | High (initially) | Higher | Fast (if memorized) |
| Hybrid (WIMP + shortcuts) | Medium | Medium | Adaptive |

**Best practice:** Default to direct manipulation; provide command/keyboard paths for power users who will invest in learning syntax for speed gains.

### When Syntax Wins

Direct manipulation isn't always superior:

- **Batch operations:** "Rename all .txt to .md" is easier to type than to drag
- **Precise specification:** "Move 100px right" is easier to type than to judge
- **Repetition:** Recorded macros beat repeated direct actions
- **Remote/deferred operations:** Scripting can run without supervision

**Design principle:** Support both semantic directness AND syntactic power for different user archetypes and tasks.
