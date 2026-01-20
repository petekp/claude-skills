# Platform-Specific Tuning Libraries

Detailed implementation guides for parameter tuning panels across platforms.

## React: Leva (Recommended)

### Installation
```bash
npm install leva
# or
pnpm add leva
```

### Basic Setup
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

### Control Types

**Number (Slider)**
```tsx
const { value } = useControls({
  value: { value: 50, min: 0, max: 100, step: 1 },
});
```

**Number (Scrubber) - No min/max**
```tsx
const { value } = useControls({
  value: 50, // Scrubber when no constraints
});
```

**Range (Two-Handle Slider)**
```tsx
const { range } = useControls({
  range: { value: [25, 75], min: 0, max: 100 },
});
```

**Color**
```tsx
const { color } = useControls({
  color: '#ff0000', // Hex
  colorRgb: { r: 255, g: 0, b: 0 }, // RGB object
  colorRgba: { r: 255, g: 0, b: 0, a: 0.5 }, // With alpha
});
```

**Select/Dropdown**
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
      'Ease In Out': 'ease-in-out',
    },
  },
});
```

**Boolean**
```tsx
const { enabled } = useControls({
  enabled: true,
});
```

**String**
```tsx
const { label } = useControls({
  label: 'Hello World',
});
```

**Vector2 (Point)**
```tsx
const { position } = useControls({
  position: { value: { x: 0, y: 0 }, step: 1 },
});
```

**Vector3**
```tsx
const { position } = useControls({
  position: { value: { x: 0, y: 0, z: 0 }, step: 1 },
});
```

**Image**
```tsx
const { image } = useControls({
  image: { image: undefined }, // Opens file picker
});
```

### Organization

**Folders (Collapsible Groups)**
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

**Buttons**
```tsx
import { useControls, button } from 'leva';

const values = useControls({
  // ... other controls
  'Reset': button(() => resetValues()),
  'Export': button(() => exportForLLM()),
});
```

**Multiple Stores**
```tsx
import { useControls, useCreateStore, LevaPanel } from 'leva';

const store = useCreateStore();

const values = useControls({ /* ... */ }, { store });

// Render panel elsewhere
<LevaPanel store={store} />
```

### Panel Positioning
```tsx
import { Leva } from 'leva';

// In your app root
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

---

## React: react-dat-gui

Alternative for simpler needs or dat.GUI familiarity.

### Installation
```bash
npm install react-dat-gui
```

### Usage
```tsx
import DatGui, { DatNumber, DatColor, DatSelect, DatFolder } from 'react-dat-gui';
import 'react-dat-gui/dist/index.css';

function Component() {
  const [data, setData] = useState({
    duration: 300,
    color: '#ff0000',
    easing: 'easeOut',
  });

  return (
    <>
      <DatGui data={data} onUpdate={setData}>
        <DatFolder title="Animation">
          <DatNumber path="duration" label="Duration (ms)" min={0} max={2000} step={10} />
          <DatSelect path="easing" options={['linear', 'easeIn', 'easeOut']} />
        </DatFolder>
        <DatColor path="color" label="Color" />
      </DatGui>
      <AnimatedComponent {...data} />
    </>
  );
}
```

---

## Vanilla JS: Tweakpane

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
pane.addBinding(PARAMS, 'easing', { options: { Linear: 'linear', 'Ease Out': 'easeOut' } });
pane.addBinding(PARAMS, 'color');

// Add button
pane.addButton({ title: 'Export for LLM' }).on('click', () => {
  console.log(JSON.stringify(PARAMS, null, 2));
});
```

### Folders
```typescript
const animFolder = pane.addFolder({ title: 'Animation' });
animFolder.addBinding(PARAMS, 'duration');

const layoutFolder = pane.addFolder({ title: 'Layout', expanded: false });
layoutFolder.addBinding(PARAMS, 'padding');
```

### Monitoring (Read-Only Display)
```typescript
pane.addBinding(PARAMS, 'fps', { readonly: true });
```

### Tabs
```typescript
const tab = pane.addTab({
  pages: [{ title: 'Animation' }, { title: 'Layout' }, { title: 'Colors' }],
});

tab.pages[0].addBinding(PARAMS, 'duration');
tab.pages[1].addBinding(PARAMS, 'padding');
tab.pages[2].addBinding(PARAMS, 'color');
```

---

## Vanilla JS: dat.GUI

Classic library, wide browser support.

### Installation
```bash
npm install dat.gui
```

### Usage
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

// Folder
const animFolder = gui.addFolder('Animation');
animFolder.add(params, 'duration');
animFolder.open();
```

---

## SwiftUI (Native)

Use SwiftUI's built-in controls with state bindings.

### Basic Panel
```swift
#if DEBUG
struct TuningPanel: View {
    @Binding var duration: Double
    @Binding var damping: Double
    @Binding var stiffness: Double
    @Binding var accentColor: Color

    var body: some View {
        Form {
            Section("Animation") {
                Slider(value: $duration, in: 0...2) {
                    Text("Duration: \(duration, specifier: "%.2f")s")
                }

                Slider(value: $damping, in: 0...50) {
                    Text("Damping: \(damping, specifier: "%.1f")")
                }

                Slider(value: $stiffness, in: 0...500) {
                    Text("Stiffness: \(stiffness, specifier: "%.0f")")
                }
            }

            Section("Colors") {
                ColorPicker("Accent", selection: $accentColor)
            }

            Section {
                Button("Copy for LLM") {
                    copyExportToClipboard()
                }
            }
        }
        .frame(width: 300)
    }

    func copyExportToClipboard() {
        let export = """
        ## Tuned Animation Values

        ```swift
        let animation = Animation.spring(
            response: \(duration),
            dampingFraction: \(damping / 50),
            blendDuration: 0
        )
        ```
        """
        NSPasteboard.general.setString(export, forType: .string)
    }
}
#endif
```

### Presentation Methods
```swift
// Sheet
.sheet(isPresented: $showTuning) { TuningPanel(...) }

// Popover
.popover(isPresented: $showTuning) { TuningPanel(...) }

// Inspector (macOS)
.inspector(isPresented: $showTuning) { TuningPanel(...) }

// Overlay
.overlay(alignment: .trailing) {
    if showTuning { TuningPanel(...) }
}
```

### Keyboard Shortcut Toggle (macOS)
```swift
.keyboardShortcut("d", modifiers: [.command, .shift])

// Or with onKeyPress
.onKeyPress(.init("d"), phases: .down) { keyPress in
    if keyPress.modifiers.contains([.command, .shift]) {
        showTuning.toggle()
        return .handled
    }
    return .ignored
}
```

---

## Flutter

Use debug overlay with ChangeNotifier.

### Basic Implementation
```dart
class TuningValues extends ChangeNotifier {
  double _duration = 0.3;
  double get duration => _duration;
  set duration(double value) {
    _duration = value;
    notifyListeners();
  }

  // Add other parameters...
}

class TuningPanel extends StatelessWidget {
  final TuningValues values;

  const TuningPanel({required this.values});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          ListTile(
            title: Text('Duration: ${values.duration.toStringAsFixed(2)}s'),
            subtitle: Slider(
              value: values.duration,
              min: 0,
              max: 2,
              onChanged: (v) => values.duration = v,
            ),
          ),
          // More controls...
          ElevatedButton(
            onPressed: _exportForLLM,
            child: Text('Copy for LLM'),
          ),
        ],
      ),
    );
  }
}

// In debug mode
assert(() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Overlay.of(context).insert(
      OverlayEntry(builder: (_) => TuningPanel(values: tuningValues)),
    );
  });
  return true;
}());
```

---

## Vue: Tweakpane with Vue Bindings

### Installation
```bash
npm install tweakpane
```

### Composable Pattern
```vue
<script setup lang="ts">
import { ref, onMounted, onUnmounted, watch } from 'vue';
import { Pane } from 'tweakpane';

const duration = ref(300);
const easing = ref('easeOut');

let pane: Pane | null = null;

onMounted(() => {
  if (import.meta.env.DEV) {
    pane = new Pane({ title: 'Animation Tuning' });

    const params = { duration: duration.value, easing: easing.value };

    pane.addBinding(params, 'duration', { min: 0, max: 2000 })
      .on('change', (e) => { duration.value = e.value; });

    pane.addBinding(params, 'easing', { options: ['linear', 'easeIn', 'easeOut'] })
      .on('change', (e) => { easing.value = e.value; });
  }
});

onUnmounted(() => {
  pane?.dispose();
});
</script>

<template>
  <div :style="{ transition: `all ${duration}ms ${easing}` }">
    Content
  </div>
</template>
```

---

## Common Patterns

### Persistence (localStorage)
```typescript
// Save on change
useEffect(() => {
  localStorage.setItem('tuning-values', JSON.stringify(values));
}, [values]);

// Load on mount
const initialValues = JSON.parse(localStorage.getItem('tuning-values') || '{}');
```

### URL Parameters for Sharing
```typescript
// Encode values to URL
const shareUrl = () => {
  const params = new URLSearchParams();
  Object.entries(values).forEach(([k, v]) => params.set(k, String(v)));
  return `${location.origin}${location.pathname}?${params}`;
};

// Parse on load
const urlParams = new URLSearchParams(location.search);
const initialDuration = Number(urlParams.get('duration')) || defaults.duration;
```

### Presets
```typescript
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
