# React Tuning Panels with Leva

Complete guide for building parameter tuning panels in React using Leva.

## Installation

```bash
npm install leva
# or
pnpm add leva
```

## Basic Setup

```tsx
import { useControls } from 'leva';

function Component() {
  const { opacity, scale } = useControls({
    opacity: { value: 1, min: 0, max: 1, step: 0.01 },
    scale: { value: 1, min: 0.1, max: 3, step: 0.1 },
  });

  return <div style={{ opacity, transform: `scale(${scale})` }} />;
}
```

## Control Types

### Number (Slider)
```tsx
const { value } = useControls({
  value: { value: 50, min: 0, max: 100, step: 1 },
});
```

### Number (Scrubber)
```tsx
const { value } = useControls({
  value: 50, // Scrubber when no constraints
});
```

### Range (Two-Handle Slider)
```tsx
const { range } = useControls({
  range: { value: [25, 75], min: 0, max: 100 },
});
```

### Color
```tsx
const { color } = useControls({
  color: '#ff0000',
  colorRgb: { r: 255, g: 0, b: 0 },
  colorRgba: { r: 255, g: 0, b: 0, a: 0.5 },
});
```

### Select/Dropdown
```tsx
const { easing } = useControls({
  easing: { value: 'easeOut', options: ['linear', 'easeIn', 'easeOut', 'easeInOut'] },
});

// With labeled options
const { easing } = useControls({
  easing: {
    value: 'ease-out',
    options: {
      'Linear': 'linear',
      'Ease In': 'ease-in',
      'Ease Out': 'ease-out',
    },
  },
});
```

### Boolean
```tsx
const { enabled } = useControls({
  enabled: true,
});
```

### Vector2/Vector3
```tsx
const { position } = useControls({
  position: { value: { x: 0, y: 0 }, step: 1 },
});

const { position3d } = useControls({
  position3d: { value: { x: 0, y: 0, z: 0 }, step: 1 },
});
```

## Organization

### Folders (Collapsible Groups)
```tsx
import { useControls, folder } from 'leva';

const values = useControls({
  animation: folder({
    duration: { value: 300, min: 0, max: 2000 },
    easing: { value: 'easeOut', options: ['linear', 'easeIn', 'easeOut'] },
  }),

  layout: folder({
    padding: { value: 16, min: 0, max: 64 },
    gap: { value: 8, min: 0, max: 32 },
  }, { collapsed: true }), // Start collapsed
});
```

### Buttons
```tsx
import { useControls, button } from 'leva';

const values = useControls({
  // ... other controls
  'Reset': button(() => resetValues()),
  'Export': button(() => exportForLLM()),
});
```

### Panel Positioning
```tsx
import { Leva } from 'leva';

<Leva
  collapsed={false}
  oneLineLabels={false}
  flat={false}
  theme={{
    sizes: { rootWidth: '320px' },
    colors: { accent1: '#6366f1' },
  }}
/>
```

### Conditional Rendering
```tsx
const { type } = useControls({ type: { value: 'A', options: ['A', 'B'] } });

const typeAControls = useControls(
  'Type A Options',
  { specific: 100 },
  { render: (get) => get('type') === 'A' }
);
```

## Debug Mode Patterns

### Environment Variable
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

### Keyboard Shortcut (⌘⇧D)
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

### URL Parameter
```tsx
const showDevTools = new URLSearchParams(window.location.search).has('debug');
```

## LLM Export Implementation

**CRITICAL:** Track defaults and filter to show only changed values.

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
    const numVal = Number(val);
    const numDefault = Number(defaultVal);
    if (!isNaN(numVal) && !isNaN(numDefault)) {
      return Math.abs(numVal - numDefault) > 0.001;
    }
    return val !== defaultVal;
  })
  .map(([key, val]) => {
    const defaultVal = defaults[key as keyof typeof defaults];
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

## Common Mistakes

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

## Persistence Patterns

### localStorage
```tsx
useEffect(() => {
  localStorage.setItem('tuning-values', JSON.stringify(values));
}, [values]);

const initialValues = JSON.parse(localStorage.getItem('tuning-values') || '{}');
```

### URL Sharing
```tsx
const shareUrl = () => {
  const params = new URLSearchParams();
  Object.entries(values).forEach(([k, v]) => params.set(k, String(v)));
  return `${location.origin}${location.pathname}?${params}`;
};
```

### Presets
```tsx
const PRESETS = {
  snappy: { duration: 150, easing: 'easeOut', stiffness: 400 },
  smooth: { duration: 400, easing: 'easeInOut', stiffness: 180 },
  bouncy: { duration: 600, easing: 'easeOut', stiffness: 120, damping: 8 },
};

const { preset } = useControls({
  preset: {
    value: 'smooth',
    options: Object.keys(PRESETS),
    onChange: (p) => applyPreset(PRESETS[p]),
  },
});
```
