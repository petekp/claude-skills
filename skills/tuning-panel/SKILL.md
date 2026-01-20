---
name: tuning-panel
description: This skill should be used when the user asks to "create a tuning panel", "add parameter controls", "build a debug panel", "tweak parameters visually", "fine-tune values", "dial in the settings", "adjust parameters interactively", or when the user is iteratively tuning animations, layouts, colors, typography, physics, or any numeric/visual parameters. Also triggers when user mentions "leva", "dat.GUI", "tweakpane", or similar parameter GUI libraries.
license: MIT
metadata:
  author: petepetrash
  version: "0.1.0"
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

**CRITICAL:** The export functionality must properly track and display only the values that have actually been changed from defaults. This is essential for users to see what they've tuned.

#### Implementation Requirements

1. **Store defaults at component level** - Define a `defaults` object before `useControls()`
2. **Use proper comparison** - Handle floating point numbers with tolerance (e.g., 0.001)
3. **Filter changed values only** - Don't show "X → X" for unchanged values
4. **Format clearly** - Make parameter names human-readable

#### Correct Implementation Pattern

```tsx
export default function TunableComponent() {
  // CRITICAL: Store defaults at component level for comparison
  const defaults = {
    duration: 300,
    delay: 0,
    stiffness: 100,
    damping: 10,
    opacity: 1.0,
  };

  const config = useControls({
    animation: folder({
      duration: { value: 300, min: 0, max: 2000, step: 10 },
      delay: { value: 0, min: 0, max: 1000, step: 10 },
    }),
    physics: folder({
      stiffness: { value: 100, min: 0, max: 300, step: 1 },
      damping: { value: 10, min: 0, max: 100, step: 1 },
    }),
    visual: folder({
      opacity: { value: 1.0, min: 0, max: 1, step: 0.01 },
    }),

    'Export for LLM': button(() => {
      const formatted = `## Tuned Parameters

Apply these values to the component:

\`\`\`typescript
const config = {
${Object.entries(config)
  .filter(([key]) => key !== 'Export for LLM')
  .map(([key, val]) => `  ${key}: ${JSON.stringify(val)},`)
  .join('\n')}
};
\`\`\`

### Changes from Defaults
${Object.entries(config)
  .filter(([key, val]) => {
    const defaultVal = defaults[key as keyof typeof defaults];
    if (defaultVal === undefined) return false;
    // Use tolerance for floating point comparison
    const numVal = Number(val);
    const numDefault = Number(defaultVal);
    if (!isNaN(numVal) && !isNaN(numDefault)) {
      return Math.abs(numVal - numDefault) > 0.001;
    }
    return val !== defaultVal;
  })
  .map(([key, val]) => {
    const defaultVal = defaults[key as keyof typeof defaults];
    // Convert camelCase to Title Case for display
    const displayKey = key.replace(/([A-Z])/g, ' $1')
      .replace(/^./, str => str.toUpperCase());
    const formattedDefault = typeof defaultVal === 'number'
      ? defaultVal.toFixed(2) : defaultVal;
    const formattedVal = typeof val === 'number'
      ? val.toFixed(2) : val;
    return `- ${displayKey}: ${formattedDefault} → ${formattedVal}`;
  })
  .join('\n') || '(No changes from defaults)'}
`;
      navigator.clipboard.writeText(formatted);
      alert('Tuned parameters copied to clipboard!');
    }),
  });

  return <Component {...config} />;
}
```

#### Common Mistakes to Avoid

❌ **DON'T hardcode defaults in the export string:**
```tsx
// BAD - Shows "Default: 300 → ${config.duration}" even if unchanged
`- Duration: 300 → ${config.duration}`
```

❌ **DON'T use strict equality for numbers:**
```tsx
// BAD - Floating point comparison may fail
.filter(([key, val]) => val !== defaults[key])
```

❌ **DON'T forget to store defaults:**
```tsx
// BAD - No defaults object to compare against
const config = useControls({
  duration: { value: 300, min: 0, max: 2000 },
});
```

✅ **DO store defaults and filter properly:**
```tsx
// GOOD - Proper defaults tracking and comparison
const defaults = { duration: 300, delay: 0 };
const config = useControls({ /* ... */ });
const changed = Object.entries(config).filter(([k, v]) =>
  Math.abs(Number(v) - Number(defaults[k])) > 0.001
);
```

#### Swift/SwiftUI Pattern

For SwiftUI tuning panels, use a tuple array to compare defaults against current values:

```swift
func exportForLLM() -> String {
    // Tuple: (category, paramName, defaultValue, currentValue)
    let allParams: [(String, String, Double, Double)] = [
        ("Animation", "duration", 0.3, duration),
        ("Animation", "springResponse", 0.2, springResponse),
        ("Animation", "springDamping", 0.8, springDamping),
        ("Visual", "opacity", 1.0, opacity),
        ("Visual", "cornerRadius", 12.0, cornerRadius),
    ]

    // Filter to only changed values (with floating-point tolerance)
    let changed = allParams.filter { abs($0.2 - $0.3) > 0.001 }

    if changed.isEmpty {
        return "## Parameters\n\nNo changes from defaults."
    }

    // Group by category for readable output
    var grouped: [String: [(String, Double, Double)]] = [:]
    for (category, name, defaultVal, currentVal) in changed {
        grouped[category, default: []].append((name, defaultVal, currentVal))
    }

    var output = "## Parameters\n\n### Changed Values\n```swift\n"
    for category in grouped.keys.sorted() {
        output += "// \(category)\n"
        for (name, defaultVal, currentVal) in grouped[category]! {
            output += "\(name): \(String(format: "%.2f", defaultVal)) → \(String(format: "%.2f", currentVal))\n"
        }
    }
    output += "```"
    return output
}
```

**Key benefits of the tuple array approach:**
- Single source of truth for defaults (no separate `defaults` dictionary to maintain)
- Category grouping built into the data structure
- Easy to add/remove parameters
- Works well with Swift's strong typing

The export should include:
- All current values in a code-ready format
- **Only changed values** in the diff section (critical!)
- Context about what was being tuned
- Human-readable parameter names

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

## Configuration Extraction Best Practices

### Preserve Tuned Defaults

When extracting a configuration class from existing code, **use the values from reset functions as defaults**, not generic starting points.

**Why:** Reset functions contain carefully tuned values that the UI was designed around. Generic defaults (like `0.5` for opacity or `12.0` for spacing) may produce completely different visual results.

**Bad:** Using generic defaults
```swift
class GlassConfig {
    // Generic defaults - NOT what the design uses
    @Published var stripeWidth: Double = 12.0
    @Published var stripeSpacing: Double = 24.0
    @Published var glowIntensity: Double = 0.5
}
```

**Good:** Using tuned defaults from existing code
```swift
class GlassConfig {
    // Values extracted from resetWorkingStripes()
    @Published var stripeWidth: Double = 24.0      // Was tuned up
    @Published var stripeSpacing: Double = 38.49   // Precisely tuned
    @Published var glowIntensity: Double = 1.50    // Much higher than "default"
}
```

**Extraction checklist:**
1. Find all `reset*()` functions in the codebase
2. Extract their assigned values as your defaults
3. If no reset function exists, check for values in the most recent working version
4. Document where defaults came from in comments

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

**Token efficiency is critical.** Export only changed values to minimize clipboard size and LLM context consumption. A panel with 100+ parameters should produce ~5 lines of output if only 3 values changed.

The LLM export should produce markdown that another Claude instance can immediately act on:

**When nothing changed:**
```markdown
## Parameters

No changes from defaults.
```

**When values were tuned:**
```markdown
## Tuned Parameters for [ComponentName]

### Changed Values
```swift
// Animation
springResponse: 0.20 → 0.15
springDamping: 0.80 → 0.65

// Visual
cornerRadius: 12.00 → 16.00
```

### Apply These Values
Update the component at `src/components/Card.tsx:42` with the values above.
```

**Why this matters:**
- A tuning panel might expose 140+ parameters
- Exporting all values wastes tokens and obscures what actually changed
- The `default → current` format makes diffs immediately scannable
- Grouped output keeps related changes together

## Additional Resources

### Reference Files
- **`references/platform-libraries.md`** - Detailed setup and API for each platform library
- **`references/parameter-categories.md`** - Exhaustive list of parameters by domain

### Example Files
- **`examples/react-leva-animation.tsx`** - Complete animation tuning panel
- **`examples/export-format.md`** - Full LLM export template
