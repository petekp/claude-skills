---
name: Tuning Panel
description: This skill should be used when the user asks to "create a tuning panel", "add parameter controls", "build a debug panel", "tweak parameters visually", "fine-tune values", "dial in the settings", "adjust parameters interactively", or when the user is iteratively tuning animations, layouts, colors, typography, physics, or any numeric/visual parameters. Also triggers when user mentions "leva", "dat.GUI", "tweakpane", or similar parameter GUI libraries.
version: 0.1.0
---

# Tuning Panel Skill

Create bespoke parameter tuning panels that give users visual control over values they're iterating on. These panels surface all relevant parameters for the current task, enable real-time adjustment, and export tuned values in an LLM-friendly format.

## Core Philosophy

**Err on the side of exhaustive.** When a user is tuning something, surface every parameter that could reasonably affect the outcome. Missing a parameter forces context-switching; having "too many" parameters costs only scroll distance.

**Platform-native approach.** Use the most appropriate library for the codebase:
- React → `leva` (preferred) or `react-dat-gui`
- Vue → `tweakpane` with Vue bindings
- Vanilla JS → `tweakpane` or `dat.GUI`
- Swift/SwiftUI → Native controls with `@State` bindings
- Flutter → Debug overlay with `ValueNotifier`

## Implementation Workflow

### Step 1: Identify All Tunable Parameters

Analyze the code being tuned and extract every parameter that affects the output. Organize by category:

**Animation Parameters:**
- Duration (ms)
- Delay (ms)
- Easing function (with presets + custom bezier)
- Direction, iteration count, fill mode
- Spring physics: stiffness, damping, mass, velocity

**Layout Parameters:**
- Spacing: padding, margin, gap (all sides)
- Sizing: width, height, min/max constraints
- Position: x, y, z-index
- Flex/Grid: alignment, justify, grow, shrink

**Visual Parameters:**
- Colors: with alpha, HSL mode for easier tuning
- Opacity, blur, shadows (offset, blur, spread, color)
- Border: width, radius (per corner), style
- Transforms: scale, rotate, translate, skew

**Typography Parameters:**
- Font size, line height, letter spacing, word spacing
- Font weight (as slider 100-900)
- Text alignment, decoration, transform

**Custom Domain Parameters:**
- Physics: gravity, friction, bounce, mass
- Audio: volume, pan, pitch, attack, decay
- 3D: FOV, near/far planes, light intensity

### Step 2: Create Debug-Mode Panel

Wrap the tuning panel in a debug/development mode check so it never appears in production:

```tsx
// React pattern
const TuningPanel = () => {
  if (process.env.NODE_ENV !== 'development') return null;
  // ... panel implementation
};
```

```swift
// Swift pattern
#if DEBUG
struct TuningPanel: View { ... }
#endif
```

### Step 3: Implement Platform-Specific Panel

Consult `references/platform-libraries.md` for detailed implementation patterns. Key principles:

1. **Group related parameters** using folders/sections
2. **Use appropriate control types**: sliders for numbers, color pickers for colors, dropdowns for enums
3. **Set sensible min/max/step values** based on the parameter domain
4. **Include presets** for common configurations
5. **Add reset buttons** to return to defaults

### Step 4: Add LLM Export Functionality

Include a mechanism to export current values in a format optimized for pasting to an LLM:

```tsx
const exportForLLM = () => {
  const formatted = `
## Current Tuning Values

Apply these values to the component:

\`\`\`
${Object.entries(values)
  .map(([key, val]) => `${key}: ${JSON.stringify(val)}`)
  .join('\n')}
\`\`\`

These values were tuned from the defaults:
${Object.entries(values)
  .filter(([key, val]) => val !== defaults[key])
  .map(([key, val]) => `- ${key}: ${defaults[key]} → ${val}`)
  .join('\n')}
`;
  navigator.clipboard.writeText(formatted);
};
```

The export should include:
- All current values in a code-ready format
- A diff showing what changed from defaults
- Context about what was being tuned

## Parameter Discovery Strategies

When analyzing code to find tunable parameters:

1. **Search for magic numbers** - Any hardcoded numeric value
2. **Look for style objects** - CSS-in-JS, inline styles, theme values
3. **Find animation definitions** - Framer Motion, CSS transitions, GSAP
4. **Identify color values** - Hex, RGB, HSL anywhere in the file
5. **Check component props** - Props with numeric or color defaults
6. **Examine CSS custom properties** - `--var-name` declarations

## Debug Mode Patterns

### React (Environment Variable)
```tsx
const DevTools = lazy(() => import('./TuningPanel'));

function App() {
  return (
    <>
      <MainContent />
      {process.env.NODE_ENV === 'development' && (
        <Suspense fallback={null}>
          <DevTools />
        </Suspense>
      )}
    </>
  );
}
```

### React (Keyboard Shortcut)
```tsx
const [showPanel, setShowPanel] = useState(false);

useEffect(() => {
  const handler = (e: KeyboardEvent) => {
    if (e.metaKey && e.shiftKey && e.key === 'D') {
      setShowPanel(prev => !prev);
    }
  };
  window.addEventListener('keydown', handler);
  return () => window.removeEventListener('keydown', handler);
}, []);
```

### Swift (Debug Build Flag)
```swift
#if DEBUG
@State private var showTuningPanel = false

var body: some View {
  content
    .sheet(isPresented: $showTuningPanel) {
      TuningPanel(values: $animationValues)
    }
    .onShake { showTuningPanel.toggle() }
}
#endif
```

### URL Parameter
```tsx
const showDevTools = new URLSearchParams(window.location.search).has('debug');
```

## Leva Quick Reference (React)

Leva is the recommended library for React projects:

```tsx
import { useControls, folder, button } from 'leva';

const Component = () => {
  const values = useControls({
    // Grouped parameters
    animation: folder({
      duration: { value: 300, min: 0, max: 2000, step: 10 },
      easing: { value: 'easeOut', options: ['linear', 'easeIn', 'easeOut', 'easeInOut'] },
      delay: { value: 0, min: 0, max: 1000, step: 10 },
    }),

    layout: folder({
      padding: { value: 16, min: 0, max: 64, step: 1 },
      gap: { value: 8, min: 0, max: 32, step: 1 },
      borderRadius: { value: 8, min: 0, max: 32, step: 1 },
    }),

    colors: folder({
      background: '#1a1a2e',
      foreground: '#eee',
      accent: { value: '#6366f1', label: 'Accent Color' },
    }),

    // Actions
    'Copy for LLM': button(() => exportForLLM(values)),
    'Reset All': button(() => resetToDefaults()),
  });

  return <div style={{ padding: values.padding, gap: values.gap }}>...</div>;
};
```

## Export Format Specification

The LLM export should produce markdown that another Claude instance can immediately act on:

```markdown
## Tuned Parameters for [ComponentName]

I've dialed in these values for the [animation/layout/etc.]:

### Final Values
```typescript
const config = {
  duration: 450,
  easing: [0.32, 0.72, 0, 1],
  stiffness: 180,
  damping: 24,
};
```

### Changes from Defaults
| Parameter | Default | Tuned | Reason |
|-----------|---------|-------|--------|
| duration | 300ms | 450ms | Slower feels more premium |
| damping | 20 | 24 | Reduces overshoot |

### Apply These Values
Update the component at `src/components/Card.tsx:42` with the config above.
```

## Additional Resources

### Reference Files
- **`references/platform-libraries.md`** - Detailed setup and API for each platform library
- **`references/parameter-categories.md`** - Exhaustive list of parameters by domain

### Example Files
- **`examples/react-leva-animation.tsx`** - Complete animation tuning panel
- **`examples/export-format.md`** - Full LLM export template
