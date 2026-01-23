# Vanilla JS Tuning Panels

Parameter tuning panels for plain JavaScript using Tweakpane or dat.GUI.

## Tweakpane (Recommended)

Modern, TypeScript-first, highly customizable.

### Installation
```bash
npm install tweakpane
```

### Basic Setup
```typescript
import { Pane } from 'tweakpane';

const PARAMS = {
  duration: 300,
  easing: 'easeOut',
  color: '#6366f1',
};

const pane = new Pane({ title: 'Animation Tuning' });

pane.addBinding(PARAMS, 'duration', { min: 0, max: 2000, step: 10 });
pane.addBinding(PARAMS, 'easing', {
  options: { Linear: 'linear', 'Ease Out': 'easeOut' }
});
pane.addBinding(PARAMS, 'color');
```

### Control Types

#### Number (Slider)
```typescript
pane.addBinding(PARAMS, 'value', { min: 0, max: 100, step: 1 });
```

#### Select/Dropdown
```typescript
pane.addBinding(PARAMS, 'easing', {
  options: {
    'Linear': 'linear',
    'Ease In': 'ease-in',
    'Ease Out': 'ease-out',
  },
});
```

#### Color
```typescript
pane.addBinding(PARAMS, 'color'); // Hex string
```

#### Boolean
```typescript
pane.addBinding(PARAMS, 'enabled'); // true/false
```

#### Point/Vector
```typescript
pane.addBinding(PARAMS, 'position', {
  x: { min: -100, max: 100 },
  y: { min: -100, max: 100 },
});
```

### Organization

#### Folders
```typescript
const animFolder = pane.addFolder({ title: 'Animation' });
animFolder.addBinding(PARAMS, 'duration');

const layoutFolder = pane.addFolder({ title: 'Layout', expanded: false });
layoutFolder.addBinding(PARAMS, 'padding');
```

#### Tabs
```typescript
const tab = pane.addTab({
  pages: [
    { title: 'Animation' },
    { title: 'Layout' },
    { title: 'Colors' },
  ],
});

tab.pages[0].addBinding(PARAMS, 'duration');
tab.pages[1].addBinding(PARAMS, 'padding');
tab.pages[2].addBinding(PARAMS, 'color');
```

#### Buttons
```typescript
pane.addButton({ title: 'Export for LLM' }).on('click', () => {
  exportForLLM();
});

pane.addButton({ title: 'Reset' }).on('click', () => {
  resetToDefaults();
});
```

#### Read-Only Display
```typescript
pane.addBinding(PARAMS, 'fps', { readonly: true });
```

### Change Listeners
```typescript
pane.addBinding(PARAMS, 'duration').on('change', (ev) => {
  console.log('Duration changed:', ev.value);
  updateAnimation();
});
```

---

## dat.GUI (Alternative)

Classic library with wide browser support.

### Installation
```bash
npm install dat.gui
```

### Basic Setup
```javascript
import * as dat from 'dat.gui';

const params = {
  duration: 300,
  easing: 'easeOut',
  color: '#6366f1',
};

const gui = new dat.GUI();
gui.add(params, 'duration', 0, 2000).step(10);
gui.add(params, 'easing', ['linear', 'easeIn', 'easeOut']);
gui.addColor(params, 'color');
```

### Folders
```javascript
const animFolder = gui.addFolder('Animation');
animFolder.add(params, 'duration', 0, 2000);
animFolder.open();

const layoutFolder = gui.addFolder('Layout');
layoutFolder.add(params, 'padding', 0, 64);
```

### Change Listeners
```javascript
gui.add(params, 'duration', 0, 2000).onChange((value) => {
  updateAnimation();
});
```

---

## Debug Mode Patterns

### URL Parameter
```typescript
const showDevTools = new URLSearchParams(window.location.search).has('debug');

if (showDevTools) {
  const pane = new Pane({ title: 'Tuning' });
  // ... add controls
}
```

### Keyboard Shortcut
```typescript
let pane: Pane | null = null;

document.addEventListener('keydown', (e) => {
  if (e.metaKey && e.shiftKey && e.key === 'd') {
    if (pane) {
      pane.dispose();
      pane = null;
    } else {
      pane = new Pane({ title: 'Tuning' });
      setupControls(pane);
    }
  }
});
```

### Development Environment Check
```typescript
if (process.env.NODE_ENV === 'development') {
  const pane = new Pane({ title: 'Tuning' });
  // ... add controls
}
```

---

## LLM Export Implementation

```typescript
const DEFAULTS = {
  duration: 300,
  delay: 0,
  stiffness: 100,
  damping: 10,
  opacity: 1.0,
};

const PARAMS = { ...DEFAULTS };

function exportForLLM() {
  const changed = Object.entries(PARAMS)
    .filter(([key, val]) => {
      const defaultVal = DEFAULTS[key];
      if (typeof val === 'number' && typeof defaultVal === 'number') {
        return Math.abs(val - defaultVal) > 0.001;
      }
      return val !== defaultVal;
    });

  if (changed.length === 0) {
    return '## Parameters\n\nNo changes from defaults.';
  }

  const lines = changed.map(([key, val]) => {
    const defaultVal = DEFAULTS[key];
    const displayKey = key.replace(/([A-Z])/g, ' $1')
      .replace(/^./, (s) => s.toUpperCase());
    return `- ${displayKey}: ${defaultVal} → ${val}`;
  });

  return `## Tuned Parameters

### Changed Values
${lines.join('\n')}

### Full Config
\`\`\`javascript
const config = ${JSON.stringify(PARAMS, null, 2)};
\`\`\``;
}

// Add export button
pane.addButton({ title: 'Export for LLM' }).on('click', () => {
  const output = exportForLLM();
  navigator.clipboard.writeText(output);
  alert('Copied to clipboard!');
});
```

---

## Persistence Patterns

### localStorage
```typescript
// Save on change
pane.on('change', () => {
  localStorage.setItem('tuning-values', JSON.stringify(PARAMS));
});

// Load on init
const saved = localStorage.getItem('tuning-values');
if (saved) {
  Object.assign(PARAMS, JSON.parse(saved));
}
```

### URL Sharing
```typescript
function getShareUrl() {
  const params = new URLSearchParams();
  Object.entries(PARAMS).forEach(([k, v]) => params.set(k, String(v)));
  return `${location.origin}${location.pathname}?${params}`;
}

function loadFromUrl() {
  const urlParams = new URLSearchParams(location.search);
  for (const [key, value] of urlParams) {
    if (key in DEFAULTS) {
      PARAMS[key] = typeof DEFAULTS[key] === 'number'
        ? Number(value)
        : value;
    }
  }
}
```

### Presets
```typescript
const PRESETS = {
  snappy: { duration: 150, easing: 'easeOut', stiffness: 400 },
  smooth: { duration: 400, easing: 'easeInOut', stiffness: 180 },
  bouncy: { duration: 600, easing: 'easeOut', stiffness: 120, damping: 8 },
};

pane.addBinding({ preset: 'smooth' }, 'preset', {
  options: Object.keys(PRESETS).reduce((acc, k) => ({ ...acc, [k]: k }), {}),
}).on('change', (ev) => {
  Object.assign(PARAMS, PRESETS[ev.value]);
  pane.refresh();
});
```

---

## Complete Example

```typescript
import { Pane } from 'tweakpane';

const DEFAULTS = {
  duration: 300,
  delay: 0,
  easing: 'easeOut',
  opacity: 1.0,
  scale: 1.0,
  color: '#6366f1',
};

const PARAMS = { ...DEFAULTS };

// Only create in debug mode
if (new URLSearchParams(location.search).has('debug')) {
  const pane = new Pane({ title: 'Animation Tuning' });

  const animFolder = pane.addFolder({ title: 'Timing' });
  animFolder.addBinding(PARAMS, 'duration', { min: 0, max: 2000, step: 10 });
  animFolder.addBinding(PARAMS, 'delay', { min: 0, max: 1000, step: 10 });
  animFolder.addBinding(PARAMS, 'easing', {
    options: { Linear: 'linear', 'Ease Out': 'easeOut', 'Ease In Out': 'easeInOut' },
  });

  const visualFolder = pane.addFolder({ title: 'Visual' });
  visualFolder.addBinding(PARAMS, 'opacity', { min: 0, max: 1, step: 0.01 });
  visualFolder.addBinding(PARAMS, 'scale', { min: 0.1, max: 2, step: 0.1 });
  visualFolder.addBinding(PARAMS, 'color');

  pane.addButton({ title: 'Export for LLM' }).on('click', () => {
    navigator.clipboard.writeText(exportForLLM());
    alert('Copied!');
  });

  pane.addButton({ title: 'Reset' }).on('click', () => {
    Object.assign(PARAMS, DEFAULTS);
    pane.refresh();
  });

  // Apply changes
  pane.on('change', () => {
    applyAnimation();
  });
}
```
