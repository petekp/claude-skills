# Input and Physicality

Input devices, two-handed interaction, haptics, and the physical act of interaction.

## Table of Contents
- [Input Devices Matter](#input-devices-matter)
- [Two-Handed Interaction](#two-handed-interaction)
- [Haptic Design](#haptic-design)
- [Sketching and Prototyping](#sketching-and-prototyping)
- [Post-WIMP Alternatives](#post-wimp-alternatives)
- [Emerging Modalities](#emerging-modalities)

---

## Input Devices Matter

The device in the user's hand shapes what interactions are possible and natural.

### Device Characteristics

| Device | DOF | Precision | Speed | Fatigue | Best For |
|--------|-----|-----------|-------|---------|----------|
| Mouse | 2D + buttons | High | Fast | Low | Precise pointing, extended use |
| Trackpad | 2D + gestures | Medium | Medium | Low | Multi-touch gestures, laptop use |
| Touch (finger) | 2D + multitouch | Low | Fast | Medium | Direct manipulation, casual use |
| Stylus/Pen | 2D + pressure + tilt | Very high | Medium | Medium | Drawing, writing, precise selection |
| Trackball | 2D + buttons | High | Medium | Very low | Precision without arm movement |
| Scroll wheel | 1D | Medium | Fast | Very low | Vertical navigation, value adjustment |
| Keyboard | Discrete | Exact | Fast | Low | Text, commands, shortcuts |

### Matching Input to Task

| Task | Best Input | Why |
|------|------------|-----|
| Precise positioning | Pen > Mouse > Touch | Control and accuracy |
| Quick selection | Touch > Mouse > Pen | Speed and directness |
| Extended work | Mouse/Trackball > Touch | Fatigue reduction |
| Drawing/writing | Pen with pressure | Natural expression |
| Text entry | Keyboard > Voice > Touch | Speed and accuracy |
| 3D navigation | 6-DOF controller > Mouse | Degree of freedom match |
| Audio mixing | Physical faders > Sliders | Tactile feedback, multiple channels |

### Degree of Integration Revisited

**Degree of integration = Input DOF / Output DOF**

| Interaction | Input DOF | Output DOF | Integration | Improvement |
|-------------|-----------|------------|-------------|-------------|
| Scrollbar for 2D pan | 1 | 2 | 0.5 | Use 2D panning gesture |
| 3 sliders for color | 1+1+1 | 3 | 1.0 (but sequential) | Color picker with 2D + slider |
| Mouse for 3D rotation | 2 | 3 | 0.67 | Virtual trackball, or 3D mouse |
| Text field for angle | ~0 (symbolic) | 1 | ~0 | Rotation dial or drag |

**Design principle:** When input DOF is lower than output DOF, users must perform multiple sequential operations for what could be one integrated action.

### Physical Controllers

Beyond mouse and keyboard, consider:

**Dedicated knobs/dials:**
- Infinite rotation with detents for precision
- Direct tactile feedback
- Can control without looking
- Example: Volume knob, scroll wheel, jog dial

**Sliders/faders:**
- Linear movement maps to linear values
- Can see/feel current position without feedback
- Multiple faders for multiple channels
- Example: Audio mixer, brightness control

**Buttons with states:**
- Toggle switches, pressure-sensitive buttons
- Physical state matches digital state
- Example: Mute buttons with LED, piano keys

**When to consider physical controls:**
- Professional/frequent use justifies hardware investment
- Multiple simultaneous adjustments needed
- Eyes-free operation valuable
- Tactile feedback important for task

---

## Two-Handed Interaction

Humans naturally use two hands. Most interfaces only engage one.

### Guiard's Kinematic Chain Model

**Non-dominant hand:**
- Sets frame of reference
- Coarse positioning
- Lower frequency movements
- Leads in time

**Dominant hand:**
- Fine manipulation within frame
- Precise actions
- Higher frequency movements
- Follows non-dominant

**Example:** Writing
- Non-dominant: Holds and positions paper
- Dominant: Writes

### Two-Handed Patterns in UI

| Pattern | Non-Dominant | Dominant | Benefit |
|---------|--------------|----------|---------|
| **Toolglass** | Positions translucent palette | Clicks through to act | Reduces mode switching |
| **Pan-zoom-draw** | Pan/zoom canvas | Draw/select | Continuous context + action |
| **Keyboard + mouse** | Modifier keys, shortcuts | Pointing, clicking | Speeds expert interaction |
| **Tablet + stylus** | Touch for gestures | Pen for precision | Best of both inputs |

### Designing for Two Hands

**For touch tablets:**
- Consider split-screen controls (left thumb, right thumb)
- Palm rejection when one hand rests on screen
- Gestures that use both hands (pinch to zoom)

**For desktop:**
- Keyboard shortcuts that complement mouse actions
- Consider non-dominant-hand devices (scroll wheel, trackpad alongside mouse)
- Modifier keys transform mouse actions

**Questions to ask:**
- Can both hands be productively engaged simultaneously?
- Does the non-dominant hand have meaningful work?
- Are we forcing sequential interaction that could be parallel?

---

## Haptic Design

Touch is a sense we largely ignore in digital interaction.

### Haptic Modalities

**Vibrotactile:** Vibrations felt through skin
- Most common in phones, game controllers
- Can convey: confirmation, alerts, texture, rhythm

**Force feedback:** Resistance to movement
- Gaming controllers, some styluses
- Can convey: weight, boundaries, magnetic snapping

**Surface haptics:** Variable friction on touchscreens
- Emerging technology
- Can convey: texture, edges, buttons

### Haptic Design Patterns

| Purpose | Haptic Response | Platform Example |
|---------|-----------------|------------------|
| **Confirmation** | Single short tap | iOS button press |
| **Success** | Double tap or pulse | Transaction complete |
| **Warning** | Triple tap or buzz | Battery low |
| **Selection** | Light tick | Picker wheel detent |
| **Error** | Sharp buzz | Rejected action |
| **Progress** | Rhythmic pulse | Countdown, progress |
| **Boundary** | Resistance/edge | Scroll limit, snap points |

### Haptic Design Principles

**Match expectation:**
- Physical buttons should feel like pressing
- Sliders should feel like sliding
- Boundaries should feel like edges

**Don't overuse:**
- Every haptic event competes for attention
- Reserve strong haptics for important moments
- Users will disable excessive haptics

**Coordinate with audio/visual:**
- Haptic + sound + visual = strongest feedback
- Haptic alone can work eyes-free
- Timing must be synchronized (<50ms difference)

**Consider context:**
- Haptics audible in quiet rooms
- Haptics can be felt by adjacent people (shared surfaces)
- Some users disable haptics (respect preference)

### Audio-Haptic Coupling

The satisfying "click" of a keyboard is audio-haptic.

**Design for the combination:**
- Key press: tactile snap + audible click
- Button: tactile depression + subtle sound
- Notification: vibration + chime

**The uncanny valley:** Haptics without sound (or vice versa) can feel wrong. Either commit to the full sensory experience or keep it subtle.

---

## Sketching and Prototyping

Design doesn't begin with specifications—it begins with exploration.

### The Role of Sketching

**Sketching is thinking.** The act of drawing externalizes thought, reveals assumptions, and enables critique.

**Sketches are not prototypes:**

| Sketch | Prototype |
|--------|-----------|
| Quick, disposable | Invested, refined |
| Explores many ideas | Tests one idea |
| Ambiguous, evocative | Specific, testable |
| Invites interpretation | Answers questions |
| "What if...?" | "Does this work?" |

### What to Sketch

**Before specifying timing, sketch the interaction:**
- Paper frames showing state changes
- Sticky notes for flow steps
- Whiteboard diagrams of user paths
- Video scenarios with paper cutouts

**Before specifying gestures, act them out:**
- How does this feel in the hand?
- What would you naturally try?
- Where do your eyes go?

### Prototyping Fidelity

| Fidelity | Tools | Tests | When |
|----------|-------|-------|------|
| **Paper** | Paper, markers, scissors | Flow, layout, concept | Early exploration |
| **Wireframe** | Figma, Sketch (static) | Information hierarchy | Structure validation |
| **Click-through** | Figma, InVision | Navigation, basic flow | Flow validation |
| **Animated** | Principle, Framer | Timing, transitions | Motion design |
| **Coded** | HTML/CSS, SwiftUI | Real interaction | Final validation |

**Key principle:** Use the lowest fidelity that can answer your question. High fidelity takes more time and creates attachment that resists change.

### Wizard of Oz Testing

Simulate intelligence/complexity with a human behind the curtain:
- Test voice interfaces by typing responses
- Test AI features with human judgment
- Test complex backends with manual data

**When to use:** The technology doesn't exist yet, or building it is expensive, but you need to validate the interaction concept.

---

## Post-WIMP Alternatives

Windows, Icons, Menus, Pointing (WIMP) is not the only paradigm.

### Zoomable User Interfaces (ZUI)

**Concept:** All content exists on an infinite canvas; navigation is zoom and pan.

**Benefits:**
- No mode for "opening" files—just zoom in
- Spatial memory for location
- Continuous context (see overview and detail)
- Natural for maps, timelines, canvases

**Examples:** Miro, Figma canvas, Google Maps, Prezi

**Design considerations:**
- Need clear landmarks for navigation
- Performance at scale
- Search/jump for known targets

### Marking Menus

**Concept:** Gesture-based menu selection where direction indicates choice.

**How it works:**
- Hold to reveal pie menu (novice)
- Or stroke in direction without waiting (expert)
- Direction encodes selection: up = cut, right = copy, down = paste

**Benefits:**
- Muscle memory develops quickly
- Expert mode is faster than any visible menu
- 8 items per level, can nest for 64+ commands

**Design considerations:**
- 8-direction limit per level
- Must be discoverable initially
- Works best with pen/touch

### Toolglasses and Magic Lenses

**Toolglass:** Translucent palette held by non-dominant hand, clicked through with dominant hand.

**Magic lens:** A filter you move over content to see/modify it differently (e.g., magnifier, X-ray view, color filter).

**Benefits:**
- Eliminates mode switching
- Tool and target selected simultaneously
- Two-handed efficiency

**Design considerations:**
- Requires two input points (multitouch, two devices)
- Visual clutter of overlay
- Discoverability

### Gestural Shortcuts

Beyond pointing: shapes drawn in space that trigger commands.

**Examples:**
- Pigtail gesture for undo
- Check mark for approve
- X for delete
- Circle to select region

**Benefits:**
- Fast once learned
- No visible UI needed
- Can combine with speech

**Design considerations:**
- Discoverability problem
- Recognition accuracy
- Cultural variation in gesture meaning

---

## Emerging Modalities

### Eye Tracking

**Capabilities:**
- Know where user is looking
- Gaze as pointing (dwell to select)
- Attention analytics

**Design considerations:**
- "Midas touch" problem: looking isn't the same as intending
- Need explicit confirmation for action
- Privacy implications

**Current use:** Accessibility (eye gaze interfaces), attention research, VR foveated rendering

### Voice

**Capabilities:**
- Natural language commands
- Hands-free operation
- Conversational interaction

**Design considerations:**
- Social acceptability (not in public/quiet spaces)
- Discoverability (what can I say?)
- Error recovery (misrecognition)
- Privacy (always listening?)

**Best combined with:** Visual feedback showing interpretation, touch for correction

### Spatial Computing (VR/AR)

**Capabilities:**
- 3D spatial manipulation
- Gaze + hand tracking
- Room-scale interaction
- Environmental awareness

**Design considerations:**
- Fatigue from extended arm use ("gorilla arm")
- Lack of haptic feedback in air
- Locomotion in virtual space
- Text input remains challenging

**Emerging patterns:**
- Pinch gestures for selection
- Gaze for pointing, hand for action
- Spatial UI attached to surfaces/objects
- Eye tracking for foveated rendering and intent

### Multi-Modal Integration

The future is not replacing modalities but combining them:

| Modalities | Combined Use |
|------------|--------------|
| Voice + gaze | "Delete that" (gaze targets, voice commands) |
| Voice + gesture | "Move this here" (gesture indicates this/here) |
| Touch + pen | Finger for gestures, pen for precision |
| Touch + gaze | Look to preview, touch to select |

**Design principle:** Each modality contributes what it does best. Voice for commands, gaze for targeting, hands for manipulation, haptics for feedback.
