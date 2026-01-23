# SwiftUI Tuning Panels

Native parameter tuning panels for SwiftUI using built-in controls and state bindings.

## Basic Panel

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
}
#endif
```

## Control Types

### Slider (Numbers)
```swift
Slider(value: $value, in: 0...100, step: 1) {
    Text("Value: \(value, specifier: "%.0f")")
}
```

### Stepper
```swift
Stepper("Count: \(count)", value: $count, in: 0...10)
```

### Toggle (Boolean)
```swift
Toggle("Enabled", isOn: $isEnabled)
```

### Picker (Enum/Options)
```swift
Picker("Easing", selection: $easing) {
    Text("Linear").tag(Easing.linear)
    Text("Ease In").tag(Easing.easeIn)
    Text("Ease Out").tag(Easing.easeOut)
}
```

### ColorPicker
```swift
ColorPicker("Accent Color", selection: $color)
ColorPicker("With Opacity", selection: $color, supportsOpacity: true)
```

### TextField (Strings)
```swift
TextField("Label", text: $label)
```

## Organization

### Sections
```swift
Form {
    Section("Animation") {
        // animation controls
    }

    Section("Layout") {
        // layout controls
    }

    Section("Colors") {
        // color controls
    }
}
```

### Disclosure Groups (Collapsible)
```swift
DisclosureGroup("Advanced Options") {
    Slider(value: $advancedValue, in: 0...100)
}
```

## Presentation Methods

### Sheet
```swift
.sheet(isPresented: $showTuning) {
    TuningPanel(duration: $duration, ...)
}
```

### Popover
```swift
.popover(isPresented: $showTuning) {
    TuningPanel(duration: $duration, ...)
}
```

### Inspector (macOS)
```swift
.inspector(isPresented: $showTuning) {
    TuningPanel(duration: $duration, ...)
}
```

### Overlay
```swift
.overlay(alignment: .trailing) {
    if showTuning {
        TuningPanel(duration: $duration, ...)
    }
}
```

## Debug Mode Patterns

### Build Flag
```swift
#if DEBUG
@State private var showTuningPanel = false

var body: some View {
    content
        .sheet(isPresented: $showTuningPanel) {
            TuningPanel(values: $animationValues)
        }
}
#endif
```

### Keyboard Shortcut (macOS)
```swift
Button("Show Tuning") {
    showTuning.toggle()
}
.keyboardShortcut("d", modifiers: [.command, .shift])
```

### Shake Gesture (iOS)
```swift
.onShake {
    showTuningPanel.toggle()
}
```

## LLM Export Implementation

Use a tuple array to track defaults alongside current values:

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

### Copy to Clipboard (macOS)
```swift
func copyExportToClipboard() {
    let export = exportForLLM()
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(export, forType: .string)
}
```

### Copy to Clipboard (iOS)
```swift
func copyExportToClipboard() {
    let export = exportForLLM()
    UIPasteboard.general.string = export
}
```

## Benefits of Tuple Array Approach

- **Single source of truth** for defaults (no separate dictionary)
- **Category grouping** built into the data structure
- **Easy to add/remove** parameters
- **Works well** with Swift's strong typing

## Complete Panel Example

```swift
#if DEBUG
struct AnimationTuningPanel: View {
    @Binding var duration: Double
    @Binding var springResponse: Double
    @Binding var springDamping: Double
    @Binding var opacity: Double
    @Binding var cornerRadius: Double

    var body: some View {
        Form {
            Section("Animation") {
                LabeledSlider("Duration", value: $duration, range: 0...2, format: "%.2f s")
                LabeledSlider("Response", value: $springResponse, range: 0...1, format: "%.2f")
                LabeledSlider("Damping", value: $springDamping, range: 0...1, format: "%.2f")
            }

            Section("Visual") {
                LabeledSlider("Opacity", value: $opacity, range: 0...1, format: "%.2f")
                LabeledSlider("Corner Radius", value: $cornerRadius, range: 0...32, format: "%.0f")
            }

            Section {
                Button("Copy for LLM") {
                    copyExportToClipboard()
                }
                .buttonStyle(.borderedProminent)

                Button("Reset to Defaults") {
                    resetToDefaults()
                }
            }
        }
        .formStyle(.grouped)
        .frame(minWidth: 300)
    }

    func resetToDefaults() {
        duration = 0.3
        springResponse = 0.2
        springDamping = 0.8
        opacity = 1.0
        cornerRadius = 12.0
    }
}

struct LabeledSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let format: String

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(label): \(String(format: format, value))")
                .font(.caption)
            Slider(value: $value, in: range)
        }
    }
}
#endif
```
