# Goals, Context, and Meaning

User goals, personas, dramatic structure, and emotional design in interaction.

## Table of Contents
- [Goal-Directed Design](#goal-directed-design)
- [User Archetypes](#user-archetypes)
- [Dramatic Structure](#dramatic-structure)
- [Emotional Design](#emotional-design)
- [Designing for Transformation](#designing-for-transformation)

---

## Goal-Directed Design

### The Fundamental Shift

Traditional interaction design asks: "How should this button behave?"
Goal-directed design asks: "What is the user trying to accomplish, and should there be a button at all?"

### Identifying User Goals

**Life goals:** Fundamental motivations (feel competent, be respected, have fun)
**Experience goals:** How users want to feel (confident, in control, not stupid)
**End goals:** What users want to accomplish (send the message, find the file, complete the purchase)

Design primarily for end goals, but never violate experience goals. Life goals inform tone and positioning.

### The Goal Hierarchy

```
Life goal: Feel competent and respected
    ↓
Experience goal: Feel confident, not confused
    ↓
End goal: Submit expense report
    ↓
Tasks: Photograph receipt, enter amount, select category, submit
    ↓
Actions: Tap camera, position phone, tap shutter...
```

Most interaction design focuses on actions and tasks. But tasks are negotiable—the goal is not. If users could submit expenses without photographing receipts, they would. Every task is potential excise.

### Excise Analysis

**Excise:** Work the user must do that doesn't directly accomplish their goal.

| Type | Example | Remedy |
|------|---------|--------|
| Navigation excise | Digging through menus | Surface frequent actions, command palette |
| Data entry excise | Re-typing known information | Auto-fill, smart defaults |
| Cognitive excise | Remembering across screens | Persistent context, visible state |
| Confirmation excise | Approving obvious actions | Undo instead of confirm |
| Waiting excise | Watching progress bars | Optimistic UI, background processing |

**For every interaction, ask:** Does this step directly serve the user's end goal, or is it serving the system's needs?

---

## User Archetypes

### The Perpetual Intermediate

Most users are neither novices nor experts. They are **perpetual intermediates** who:

- Learned enough to accomplish their tasks
- Will not invest time learning advanced features
- Use a small, stable subset of functionality
- Forget features they use rarely
- Develop personal workarounds

**Design implications:**
- The common path must be fast and obvious
- Advanced features should be discoverable but not intrusive
- Don't assume users will learn keyboard shortcuts
- Don't assume users read documentation
- Recognize that "intuitive" means "matches existing mental models"

### Archetype Spectrum

| Archetype | Characteristics | Design Priority |
|-----------|-----------------|-----------------|
| **First-timer** | No mental model, cautious, needs orientation | Progressive disclosure, clear signifiers, forgiveness |
| **Casual user** | Infrequent use, forgets between sessions | Recognition over recall, sensible defaults, clear labels |
| **Perpetual intermediate** | Stable workflow, won't learn more | Fast common path, don't require learning |
| **Power user** | Optimizes workflow, learns shortcuts | Keyboard efficiency, customization, density options |
| **Expert** | Pushes system limits, knows internals | Extensibility, scripting, raw access |

**Key insight:** Design for the perpetual intermediate as the default, with graceful paths to novice (simpler) and expert (more powerful) experiences.

### Creating Lightweight Personas

For interaction design, full personas aren't always necessary. Instead, consider:

**The archetype question:** Is this user a first-timer, casual, intermediate, power user, or expert?

**The context question:** Where are they? What device? How much time? What's their emotional state?

**The goal question:** What end goal brought them here? What experience goal must we not violate?

---

## Dramatic Structure

### Interaction as Drama

Every interaction has a beginning, middle, and end. Every interaction is a scene in a larger performance.

**Aristotle's structure applied:**
- **Setup:** User enters the interaction—what state are they in? What do they expect?
- **Rising action:** Building toward the goal—each step should feel like progress
- **Climax:** The moment of commitment—pressing Submit, confirming Delete, completing Purchase
- **Resolution:** Confirmation of outcome—what just happened? What comes next?

### Dramatic Tension

Tension is not always bad. Appropriate tension creates engagement.

**Tension that engages:**
- Anticipation before revealing results
- The weight of an important decision
- The satisfaction of overcoming a challenge
- The relief of successful completion

**Tension that frustrates:**
- Uncertainty about whether action was received
- Fear of irreversible mistakes without recourse
- Confusion about current state
- Waiting without progress indication

**Design principle:** Don't eliminate all tension—channel it appropriately.

### The Emotional Arc

| Story Beat | User Experience | Design Response |
|------------|-----------------|-----------------|
| Call to adventure | User has a goal | Clear entry point, inviting UI |
| Crossing threshold | Beginning the task | Orientation, visible first step |
| Tests and challenges | Working through task | Progress feedback, error recovery |
| Ordeal | Moment of commitment | Appropriate weight, confirmation |
| Reward | Goal accomplished | Clear success, celebration if warranted |
| Return | Moving on | Next steps, graceful exit |

### Empty States as Dramatic Moments

An empty state is not just "no data"—it's a narrative moment.

| Empty State | Narrative | Design |
|-------------|-----------|--------|
| Initial empty | "Your story hasn't begun" | Invitation, possibility, clear CTA |
| Cleared empty | "You've completed everything" | Celebration, accomplishment |
| No results | "We couldn't find that" | Guidance, alternatives |
| Error empty | "Something went wrong" | Empathy, clear recovery path |

An empty inbox says "You are free." An empty document says "The page awaits." These require different treatments.

---

## Emotional Design

### The Three Levels

**Visceral (immediate):**
What does the user feel upon first seeing this?
- First impressions
- Aesthetic response
- Gut reaction: attractive, scary, trustworthy?

**Behavioral (during use):**
What does the user feel while interacting?
- Sense of control
- Pleasure or frustration
- Flow state or interruption
- Competence or confusion

**Reflective (after):**
What does the user feel about the experience?
- Did I accomplish my goal?
- Would I use this again?
- Would I recommend this?
- What story do I tell about this experience?

### Emotional Qualities in Interaction

| Interaction | Can convey... |
|-------------|---------------|
| **Speed** | Efficiency (fast) or thoughtfulness (deliberate) |
| **Weight** | Importance (heavy) or ease (light) |
| **Sound** | Confirmation (click), completion (chime), error (buzz) |
| **Animation** | Playfulness (bounce), precision (snap), calm (ease) |
| **Language** | Formality, personality, empathy |
| **Spacing** | Breathing room, density, focus |

### Designing for Specific Emotions

**Confidence:**
- Clear affordances—never wonder "can I click this?"
- Visible system state—never wonder "what mode am I in?"
- Predictable responses—same action, same result
- Visible recovery—undo available, changes reversible

**Accomplishment:**
- Clear progress toward goal
- Meaningful completion markers
- Appropriate celebration (not excessive)
- Smooth transition to "what's next"

**Trust:**
- Honest feedback—never false success messages
- Transparent process—show what's happening
- Respectful data handling—no dark patterns
- Graceful error handling—no blame

**Delight (use sparingly):**
- Unexpected micro-moments of pleasure
- Personality in transitions
- Easter eggs for those who find them
- Polish in the details

---

## Designing for Transformation

### The User's Journey

Users don't just complete tasks—they become different through interaction.

**Before:** User doesn't know X / can't do Y / hasn't decided Z
**After:** User knows X / can do Y / has committed to Z

**Design question:** How does completing this interaction change the user's situation? Their capabilities? Their relationship with the system?

### Onboarding as Transformation

New user onboarding isn't just "showing features"—it's transforming a stranger into a competent user.

**Transformation stages:**
1. **Stranger:** Doesn't know what this is or why they should care
2. **Visitor:** Curious but uncommitted, easily lost
3. **Beginner:** Committed but needs guidance at every step
4. **Regular:** Knows enough to accomplish goals
5. **Advocate:** Invested, may help others

**Design for transition points:**
- Stranger → Visitor: Clear value proposition
- Visitor → Beginner: Low-commitment first success
- Beginner → Regular: Repeated successes, building confidence
- Regular → Advocate: Investment, personalization, mastery

### Marking Moments

Some moments deserve emphasis:

**First-time moments:**
- First successful [action]
- First completed [workflow]
- First [milestone]

**Completion moments:**
- Finishing a sequence
- Achieving a goal
- Reaching a threshold

**Commitment moments:**
- Making a choice
- Spending money
- Sharing with others

**Design principle:** Mark these moments appropriately. A first purchase deserves more ceremony than a search query. But don't over-celebrate trivial accomplishments—it feels patronizing.

---

## Applying This Perspective

### Before Designing Any Interaction

1. **What is the user's end goal?** (Not what they're doing, but why)
2. **What archetype are they?** (First-timer to expert spectrum)
3. **What is the emotional context?** (Rushed? Anxious? Playful?)
4. **What is the dramatic moment?** (Beginning? Climax? Resolution?)
5. **How are they transformed?** (What's different after?)

### Questions to Challenge Your Design

- Does every step serve the user's goal, or are some serving the system?
- Could a perpetual intermediate complete this without learning anything new?
- Where is the climax of this interaction? Is it weighted appropriately?
- What emotion should the user feel at each stage?
- If this interaction were a scene in a play, what story is it telling?

### Warning Signs

- You're designing a feature without knowing who uses it
- Every user gets the same experience regardless of expertise
- The interaction ends without clear resolution
- You can't articulate what emotion the user should feel
- Tasks exist because "the system needs" rather than "the user wants"
