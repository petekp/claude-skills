---
name: interaction-design
description: Apply interaction design principles to create intuitive, responsive interfaces. Use when designing component behaviors, micro-interactions, loading states, transitions, user flows, accessibility patterns, or when the user asks about UX, animation timing, keyboard navigation, or progressive disclosure.
---

# Interaction Design

Guide for designing intuitive, responsive, and accessible user interactions.

## Core Principles

### Feedback & Responsiveness
- Every user action deserves acknowledgment (visual, auditory, or haptic)
- Response time expectations: instant (<100ms), fast (<1s), or progress indication
- Optimistic UI: update immediately, reconcile errors gracefully
- Skeleton screens > spinners for perceived performance

### Progressive Disclosure
- Show only what's needed at each step
- Reveal complexity gradually through interaction
- Use sensible defaults; make advanced options discoverable
- Reduce cognitive load by chunking information

### Direct Manipulation
- Objects should feel tangible and respond to interaction
- Maintain visible connection between action and result
- Support undo/redo for reversible actions
- Provide clear affordances for interactive elements

### Consistency & Standards
- Follow platform conventions (web, iOS, Android)
- Maintain internal consistency across the application
- Use familiar patterns before inventing new ones
- Ensure predictable behavior across similar components

## Micro-Interactions

### State Transitions
- **Hover**: 150-200ms ease-out for color/shadow changes
- **Focus**: Immediate visible indicator (outline, ring)
- **Active/Pressed**: Scale down slightly (0.95-0.98) or darken
- **Disabled**: Reduced opacity (0.5-0.6), cursor: not-allowed
- **Loading**: Pulsing skeleton, spinner, or progress bar

### Animation Timing
- **Micro**: 100-200ms (button states, toggles)
- **Small**: 200-300ms (dropdowns, tooltips)
- **Medium**: 300-400ms (modals, panels)
- **Large**: 400-600ms (page transitions, complex reveals)
- Use ease-out for entering, ease-in for exiting

### Easing Functions
- `ease-out`: Elements entering view (feels welcoming)
- `ease-in`: Elements leaving view (feels decisive)
- `ease-in-out`: Elements moving within view
- `spring`: Natural, playful interactions

## User Flow Design

### Navigation Patterns
- Maintain user's mental model of location
- Provide escape hatches (back, cancel, close)
- Support both linear and non-linear navigation
- Preserve state when navigating away and returning

### Onboarding
- Defer account creation until value is demonstrated
- Use progressive onboarding over tutorial dumps
- Highlight features contextually when relevant
- Allow skipping with graceful degradation

### Error Recovery
- Prevent errors through constraints and validation
- Inline validation at the right moment (not too eager)
- Clear error messages: what happened, why, how to fix
- Preserve user input during error states
- Offer recovery actions, not just error descriptions

### Empty States
- Explain what belongs here and how to add it
- Provide clear call-to-action
- Use illustration/imagery to reduce starkness
- Consider first-run vs. cleared vs. no-results states

## Component Behaviors

### Forms & Inputs
- Label always visible (not just placeholder)
- Validate on blur, re-validate on change after error
- Show character counts for limited fields
- Auto-focus first field; support tab navigation
- Disable submit during processing; show progress

### Modals & Dialogs
- Trap focus within modal
- Close on Escape key and backdrop click (when appropriate)
- Return focus to trigger element on close
- Prevent background scrolling
- Stack modals carefully (avoid when possible)

### Dropdowns & Menus
- Open on click (not hover) for accessibility
- Support keyboard navigation (arrows, Enter, Escape)
- Highlight current selection
- Position to avoid viewport edges
- Close on outside click or Escape

### Drag & Drop
- Clear visual indication of draggable items
- Ghost/preview during drag
- Valid drop zones highlighted
- Animate items into new positions
- Provide keyboard alternative

## Accessibility Patterns

### Keyboard Navigation
- All interactive elements focusable via Tab
- Logical focus order matching visual layout
- Skip links for repetitive navigation
- Arrow keys for related controls (tabs, menus)
- Enter/Space for activation; Escape for dismissal

### Screen Readers
- Semantic HTML as foundation
- ARIA labels for icon-only buttons
- Live regions for dynamic content
- Announce loading states and completions
- Meaningful link/button text (not "click here")

### Motion & Vestibular
- Respect `prefers-reduced-motion`
- Provide alternatives to motion-based interactions
- Avoid parallax and excessive animation
- Allow pausing auto-playing content

### Color & Contrast
- Don't rely on color alone for meaning
- Minimum 4.5:1 contrast for text
- 3:1 for large text and UI components
- Test with color blindness simulators

## Loading & Progress

### Loading States
- Immediate feedback that action was received
- Skeleton screens for predictable layouts
- Spinners for unpredictable durations
- Progress bars when duration is known
- Stagger skeleton animations for natural feel

### Optimistic Updates
- Update UI immediately on user action
- Sync with server in background
- Handle conflicts gracefully
- Rollback with clear explanation on failure

### Streaming & Incremental
- Show content as it arrives
- Maintain scroll position during updates
- Indicate when more content is loading
- Handle connection interruptions

## Reference Materials

See additional files in this skill directory for:
- Seminal interaction design literature and excerpts
- Platform-specific guidelines
- Case studies and examples
