# Animation Timing Reference

Animation as a design tool: when to use it, when to avoid it, what it communicates, and how to implement it.

## Table of Contents
- [Animation Philosophy](#animation-philosophy)
- [When to Animate](#when-to-animate)
- [When NOT to Animate](#when-not-to-animate)
- [Emotional Qualities](#emotional-qualities)
- [Duration Guidelines](#duration-guidelines)
- [Easing Functions](#easing-functions)
- [Spring Physics](#spring-physics)
- [Animation Patterns by Component](#animation-patterns-by-component)
- [Choreography & Sequencing](#choreography--sequencing)
- [Reduced Motion](#reduced-motion)
- [Discovering the Right Animation](#discovering-the-right-animation)

---

## Animation Philosophy

Animation is not decoration. It is communication.

Every animation should answer: **What purpose does this serve?** If you cannot articulate the purpose, the animation may be excise—wasted time and attention.

### What Animation Can Communicate

| Purpose | How Animation Helps |
|---------|---------------------|
| **Object constancy** | Show that A transformed into B, not that A disappeared and B appeared |
| **Causality** | This action caused that result |
| **Spatial relationship** | This came from there, went to here |
| **State change** | Something is different now |
| **Feedback** | Your action was received |
| **Attention direction** | Look here, this is important |
| **Pacing** | This moment deserves weight |
| **Personality** | This system is [playful/serious/calm/energetic] |

### Animation as Excise

Animation becomes excise when:
- User must wait through it repeatedly
- It doesn't communicate anything the user needs
- It delays feedback they're waiting for
- It prioritizes aesthetics over task completion
- Expert users can't skip or accelerate it

**The habituation test:** After performing this action 100 times, will the animation still serve a purpose, or will it just be delay?

---

## When to Animate

### Animate for These Purposes

**Maintaining object constancy**
When an object transforms, animation shows continuity. Without it: "Where did that go? What is this?"
- Opening a folder → items emerge from folder
- Expanding an accordion → content reveals from header
- Modal opening → grows from trigger button

**Communicating causality**
Animation shows cause and effect, reinforcing the user's mental model.
- Drag an item → it follows the cursor → lands where released
- Press button → button depresses → action occurs
- Swipe to delete → item slides away → slot closes

**Reducing change blindness**
Without animation, users may miss changes. Animation draws attention.
- New notification → slides in from edge
- Content update → brief highlight/pulse
- Error appears → field shakes or error fades in

**Providing feedback**
Animation confirms actions were received, especially before results are visible.
- Button press → immediate visual response (scale, color)
- Form submit → button shows loading state
- Save → brief checkmark or pulse

**Conveying emotional tone**
Animation expresses personality and sets expectations.
- Playful app → bouncy springs, overshoots
- Professional tool → crisp, minimal transitions
- Calming experience → slow, gentle easing

### The Quick Test

Before adding animation, ask:
1. What does this animation *communicate*?
2. Will users need this communication on the 100th use?
3. Is this animation faster than the alternative (instant change)?
4. Does this animation serve the user's goal or mine?

---

## When NOT to Animate

### Don't Animate These Situations

**Habitual actions**
Expert users performing routine tasks don't need animation—they've already moved on mentally.
- Rapid keyboard shortcuts
- Frequent toggles
- Repeated actions in a workflow

**When speed is critical**
Animation that blocks task completion is excise.
- Browsing many items quickly
- Data entry workflows
- Comparison shopping

**When users indicate reduced motion**
Respect `prefers-reduced-motion`. Some users experience motion sickness, distraction, or have vestibular disorders.

**When animation would obscure**
Sometimes instant changes are clearer than animated ones.
- Small text changes
- Number updates (often clearer to just change)
- Rapid state cycling

**When it's purely aesthetic**
If the animation serves no cognitive or communicative purpose, question whether it's needed.

### Alternatives to Animation

| Instead of... | Consider... |
|---------------|-------------|
| Slow fade transitions | Instant change with subtle highlight |
| Sliding panels | Cut with clear spatial layout |
| Progress animation | Static progress bar |
| Loading spinner | Skeleton screen (no animation) |
| Bouncy micro-interactions | Crisp state changes |

---

## Emotional Qualities

Animation isn't just timing—it carries emotional meaning.

### Spring Characteristics and Personality

| Spring Type | Personality | Use For |
|-------------|-------------|---------|
| **Stiff, fast** | Precise, professional, efficient | Business apps, productivity tools |
| **Gentle, slow** | Calm, comfortable, trustworthy | Healthcare, finance, meditation |
| **Bouncy** | Playful, young, energetic | Games, social apps, celebrations |
| **Snappy** | Responsive, modern, confident | Interactive tools, creative apps |

### Easing and Meaning

| Easing | Emotional Quality |
|--------|-------------------|
| **Ease-out (decelerate)** | Welcoming, arriving, settling in |
| **Ease-in (accelerate)** | Departing, dismissing, decisive exit |
| **Linear** | Mechanical, neutral, continuous process |
| **Ease-in-out** | Natural, breathing, cyclical |
| **Overshoot** | Energetic, playful, attention-grabbing |

### Matching Animation to Context

| Context | Appropriate Animation |
|---------|----------------------|
| Error recovery | Fast, minimal (don't delay) |
| Celebration | Bouncy, extended (mark the moment) |
| Navigation | Quick, directional (maintain orientation) |
| Loading | Calm, rhythmic (patience) |
| Confirmation | Brief, satisfying (closure) |
| Danger/warning | Sharp, attention-grabbing (urgency) |

---

## Duration Guidelines

### By Interaction Scale

| Scale | Duration | Use Cases | User Perception |
|-------|----------|-----------|-----------------|
| Micro | 50-150ms | Button press, toggle | Instant feedback |
| Small | 150-250ms | Tooltip, dropdown | Brief, responsive |
| Medium | 250-400ms | Modal, sidebar | Noticeable, smooth |
| Large | 400-600ms | Page transition | Deliberate, weighty |

### The Cognitive Thresholds

- **< 100ms**: Perceived as instant. No easing needed.
- **100-300ms**: Motion is perceptible but feels responsive.
- **300-500ms**: Animation is noticed as animation.
- **> 500ms**: Animation demands attention, feels slow unless serving a purpose.

### Entry vs Exit

Exit animations should be faster than entry:
- **Entry**: 250-350ms — Welcoming, gives time to perceive
- **Exit**: 150-250ms — Decisive, gets out of the way

**Why?** Users trigger exits intentionally; they're ready to move on. Entries surprise users; they need time to orient.

### By Distance

| Distance | Duration | Rationale |
|----------|----------|-----------|
| < 100px | 150-200ms | Close movements should be quick |
| 100-300px | 200-350ms | Medium travel, medium time |
| 300-500px | 300-450ms | Longer journeys need time |
| > 500px | 400-600ms | Very long movements need tracking time |

---

## Easing Functions

### CSS Cubic Bezier Reference

```
ease:        cubic-bezier(0.25, 0.1, 0.25, 1.0)
ease-in:     cubic-bezier(0.42, 0, 1.0, 1.0)
ease-out:    cubic-bezier(0, 0, 0.58, 1.0)
ease-in-out: cubic-bezier(0.42, 0, 0.58, 1.0)
linear:      cubic-bezier(0, 0, 1, 1)
```

### Recommended Curves

**Standard (ease-out)** — Default for most UI animations
```
cubic-bezier(0.2, 0, 0, 1)
```

**Decelerate** — Elements entering from offscreen
```
cubic-bezier(0, 0, 0.2, 1)
```

**Accelerate** — Elements leaving the screen
```
cubic-bezier(0.4, 0, 1, 1)
```

**Sharp** — Size/shape changes
```
cubic-bezier(0.4, 0, 0.6, 1)
```

**Overshoot** — Playful bounce (use sparingly)
```
cubic-bezier(0.34, 1.56, 0.64, 1)
```

### Choosing Easing

| Scenario | Easing | Rationale |
|----------|--------|-----------|
| Element appearing | ease-out | Arrives with energy, settles smoothly |
| Element disappearing | ease-in | Accelerates away decisively |
| Element responding to user | ease-out | Immediate response, smooth result |
| Looping animation | ease-in-out | Natural, breathing rhythm |
| Background/passive | linear | Doesn't draw attention |
| Celebratory moment | overshoot | Playful, attention-grabbing |

---

## Spring Physics

Springs feel natural because they model physical behavior. Use springs when direct manipulation feeling is important.

### Spring Parameters

| Parameter | Effect | Range |
|-----------|--------|-------|
| **Stiffness** (tension) | How snappy/rigid | 100-500 |
| **Damping** (friction) | How quickly it settles | 10-40 |
| **Mass** | Weight/inertia | 0.5-2 |

### Common Presets

**Gentle** — Smooth, flowing
```
stiffness: 120, damping: 14
```
Use for: Large panels, page transitions, calming interfaces

**Snappy** — Responsive, modern
```
stiffness: 300, damping: 20
```
Use for: Buttons, toggles, interactive elements

**Bouncy** — Playful, energetic
```
stiffness: 200, damping: 10
```
Use for: Celebrations, gamified elements, youthful brands

**Stiff** — Precise, minimal oscillation
```
stiffness: 400, damping: 30
```
Use for: Professional tools, precise controls

### Library Syntax

**Framer Motion (React)**
```jsx
transition={{ type: "spring", stiffness: 300, damping: 20 }}
```

**React Spring**
```jsx
config: { tension: 300, friction: 20 }
```

**SwiftUI**
```swift
.animation(.spring(response: 0.5, dampingFraction: 0.7))
```

---

## Animation Patterns by Component

### Buttons

| State | Animation | Duration/Spring |
|-------|-----------|-----------------|
| Hover | Background/shadow change | 150ms ease-out |
| Press | Scale to 0.95-0.98 | 50-100ms ease-out |
| Release | Return to normal | 150ms ease-out |
| Loading | Spinner (if needed) | Continuous |

### Modals

**Open**
- Backdrop: opacity 0→1, 200ms ease-out
- Modal: scale 0.95→1, opacity 0→1, 250ms ease-out

**Close**
- Modal: opacity 1→0, 150ms ease-in
- Backdrop: opacity 1→0, 200ms ease-in

### Dropdowns/Menus

**Open**
- opacity 0→1, translateY(-8px)→0, 150-200ms ease-out

**Close**
- opacity 1→0, 100-150ms ease-in

### Toasts/Notifications

**Enter**
- Slide from edge + fade, 250ms ease-out

**Exit**
- Fade + slide out, 150ms ease-in

### Cards/List Items

**Hover lift**
- translateY(0→-4px), shadow increase, 200ms ease-out

**Selection**
- Background/border change, 150ms ease-out

---

## Choreography & Sequencing

### Stagger Pattern

Delay each element progressively for a wave effect.

```
Base delay: 30-50ms per item
Max total delay: 300-500ms (cap for long lists)
```

**Example (5 items, 40ms stagger):**
- Item 1: 0ms
- Item 2: 40ms
- Item 3: 80ms
- Item 4: 120ms
- Item 5: 160ms

### Orchestration Principles

1. **Container before content**: Shell appears, then fills
2. **Important elements last**: CTAs appear after supporting content
3. **Group related elements**: Animate together or with minimal stagger
4. **Maintain rhythm**: Consistent intervals feel intentional

---

## Reduced Motion

### Detection

**CSS**
```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

**JavaScript**
```js
const prefersReducedMotion = window.matchMedia(
  '(prefers-reduced-motion: reduce)'
).matches;
```

### Graceful Alternatives

| Full Motion | Reduced Motion Alternative |
|-------------|---------------------------|
| Slide in | Instant appear or quick fade |
| Bounce | Direct position, no overshoot |
| Parallax | Static positioning |
| Auto-play video | Paused with play button |
| Complex choreography | Simple fade |

### What to Keep

Even with reduced motion:
- Fast opacity changes (< 150ms)
- Color/state changes
- Focus indicators (instant)
- Static progress indicators

---

## Discovering the Right Animation

### Don't Start with Specifications

Animation timing should emerge from exploration, not be dictated upfront.

**Sketch first:**
1. Draw key frames on paper
2. Act out the motion with your hands
3. Video prototype with rough timing
4. Adjust based on feel

### Finding the Right Duration

1. Start with a rough guess
2. Make it 2x faster — does it feel abrupt?
3. Make it 2x slower — does it feel sluggish?
4. Narrow in on the sweet spot
5. Test with users; watch for impatience or confusion

### Finding the Right Easing

1. Start with ease-out (almost always works)
2. Try ease-in-out — does it feel more natural?
3. Try spring — does it feel more physical?
4. Match to emotional context

### Questions for Review

- Is this animation communicating something essential?
- Would a user performing this 100 times want this animation?
- Does it respect users who prefer reduced motion?
- Does the timing feel responsive, not sluggish?
- Does the easing match the emotional context?
