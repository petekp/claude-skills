# The World-Class SwiftUI UI Playbook

Complete reference for designing and implementing Apple-level SwiftUI interfaces.

---

## 1) Design "Physics" Apple-Level UIs Obey

### Visual Hierarchy via Layout, Not Decoration

With modern Apple UI (especially Liquid Glass), emphasis shifts from borders/backgrounds to **grouping + spacing + structure**.

**Tactics:**
- **Grouping** shows relationship
- **Distance** shows separation
- **Alignment** shows intent
- **Tint** only for meaning/primary action (never decoration)

### Typography Rules

- Prefer semantic styles: `.font(.title)`, `.font(.headline)`, `.font(.body)`
- Avoid hard sizing (`.font(.system(size: 17))`) unless tested with Dynamic Type
- Use sparingly: `.minimumScaleFactor(0.8)`, `.lineLimit(...)`
- Use `.multilineTextAlignment(.leading)` for most reading
- Use `@ScaledMetric` for padding around text-heavy elements

### Spacing Scale

Pick and stick to: **4, 8, 12, 16, 20, 24, 32, 40**

- Larger jumps (24-40) for section breaks
- Small steps (8-16) inside components
- **Spacing communicates hierarchy** as much as font weight

### Shape: Concentricity

Modern Apple UI emphasizes **concentricity**—nested rounded corners sharing centers.

**iOS 26+:** Use `ConcentricRectangle()` for inner surfaces matching outer container shape.

```swift
ZStack {
    ConcentricRectangle()
        .fill(.background)
        .padding(8)
    // inner content...
}
.ignoresSafeArea()
```

---

## 2) Liquid Glass Design System (iOS 26+)

### Core Concept: Content vs Controls Layer

Liquid Glass is a **distinct functional layer** for controls/navigation floating above content.

**Tactics:**
- Avoid controls directly on busy content without separating surface
- For loud content (photos/video): add system material behind controls or reposition content

### Remove Custom Bar Decoration

Remove custom `toolbarBackground`, heavy overlays, manual darkening. Let system scroll edge effects provide legibility.

**Don't:** Stack your own blur/dim layers under toolbars.

### Tinting Rules

Tint only:
- Primary CTA
- State/priority indicators

Don't tint:
- Every toolbar icon
- Every button in a cluster
- Decorative accents

### Scroll Edge Effects

- Use **one** per view/pane
- Soft on iOS/iPadOS; hard on macOS
- Don't apply where no floating UI exists
- Don't mix/stack styles

### Tab Bar Features (iOS 26)

**Minimize on scroll:**
```swift
.tabBarMinimizeBehavior(.onScrollDown)
```

**Bottom accessory for persistent features:**
```swift
.tabViewBottomAccessory { /* playback controls */ }
```

Design rule: Persistent accessory ≠ contextual CTA.

### Search Patterns

**Pattern A: Toolbar search**
- Place `searchable` high in hierarchy
- Use `.searchToolbarBehavior(.minimize)` when secondary

**Pattern B: Dedicated search tab**
- Assign search role to tab
- Search field replaces tab bar when selected

### Sheets

iOS 26 partial sheets are inset with Liquid Glass background. Remove custom sheet backgrounds to let system material work.

### Custom Glass in SwiftUI

```swift
// Basic glass
Text("Label")
    .glassEffect()              // capsule shape default

// Interactive (for controls)
Button("Action") { }
    .glassEffect(.interactive)  // scale/bounce/shimmer

// Custom shape
Text("Badge")
    .glassEffect(in: RoundedRectangle(cornerRadius: 8))

// Group nearby glass
@Namespace private var glassNS

GlassEffectContainer {
    HStack {
        GlassBadge(text: "Gold")
        GlassBadge(text: "Visited")
    }
    .glassEffectID("badges", in: glassNS)
}

// Morphing transitions
.glassEffectID("panel", in: namespace)
```

**Key rule:** Glass can't sample other glass—use `GlassEffectContainer` for nearby elements.

---

## 3) Design System Implementation

### Token System Structure

```swift
struct AppTheme {
    var spacing = Spacing()
    var radius = Radius()
    var motion = Motion()
}

extension AppTheme {
    struct Spacing {
        let xxs: CGFloat = 4
        let xs: CGFloat  = 8
        let sm: CGFloat  = 12
        let md: CGFloat  = 16
        let lg: CGFloat  = 24
        let xl: CGFloat  = 32
        let xxl: CGFloat = 40
    }

    struct Radius {
        let sm: CGFloat = 10
        let md: CGFloat = 16
        let lg: CGFloat = 24
    }

    struct Motion {
        let quick = Animation.snappy(duration: 0.2)
        let standard = Animation.snappy(duration: 0.35)
        let emphasize = Animation.bouncy(duration: 0.45)
    }
}

private struct ThemeKey: EnvironmentKey {
    static let defaultValue = AppTheme()
}

extension EnvironmentValues {
    var theme: AppTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

extension View {
    func theme(_ theme: AppTheme) -> some View {
        environment(\.theme, theme)
    }
}
```

### Scaled Spacing Pattern

```swift
struct Card: ViewModifier {
    @ScaledMetric(relativeTo: .body) private var padding: CGFloat = 16
    func body(content: Content) -> some View {
        content.padding(padding)
    }
}
```

### Semantic Colors and Materials

- Prefer: `.primary`, `.secondary`, `.tertiary`, `.quaternary`
- Use: `.background`, `.secondarySystemBackground`
- For glass: use `Material`, `glassEffect` (not custom blurs)

---

## 4) Layout Patterns

### Adaptive Structure

Design "anatomy" once, let it scale. Use:
- `NavigationSplitView` for iPad/Mac hierarchical
- `TabView` for top-level switching
- `NavigationStack` for deep flows

### Container Selection

| Container | Best For |
|-----------|----------|
| `List` | Large dynamic datasets, selection, swipe, edit mode, accessibility |
| `ScrollView` + `LazyVStack` | Custom surfaces, cards, mixed content |
| `Grid` | Forms, settings, dense structured |
| `LazyVGrid` | Responsive galleries |

### Stable Identity

```swift
// Good
ForEach(items, id: \.id) { item in ... }

// Bad - regenerates each render
ForEach(items, id: \.self) { item in ... }

// Never do
ForEach(items) { item in
    Row().id(UUID())  // Resets state every render
}
```

### Dynamic Type-Proof Layouts

```swift
// Switch layout based on fit
ViewThatFits {
    HStack { content }
    VStack { content }
}

// Priority for important text
HStack {
    Text(title).layoutPriority(1)
    Spacer()
    badge
}

// Force multi-line expansion
Text(longTitle)
    .fixedSize(horizontal: false, vertical: true)
```

### Safe Area Patterns

```swift
// Floating CTA bar
.safeAreaInset(edge: .bottom) {
    PrimaryCTABar()
}

// Background extension (iOS 26)
.backgroundExtensionEffect()  // Extends behind sidebars with mirror+blur
```

---

## 5) Toolbars and Navigation

### Toolbar Grouping

- Group by **function and frequency**
- Remove items or move secondary to menu if crowded
- Don't group symbols with text (reads as one button)

### ToolbarSpacer

```swift
.toolbar(id: "main") {
    ToolbarItem(id: "tag") { TagButton() }
    ToolbarItem(id: "share") { ShareButton() }

    ToolbarSpacer(.fixed)

    ToolbarItem(id: "more") { MoreButton() }
}
```

### Hide Shared Background

For items that shouldn't participate in grouped glass:

```swift
.toolbar {
    ToolbarItem(placement: .principal) {
        Avatar()
    }
    .sharedBackgroundVisibility(.hidden)
}
```

### Badges on Toolbar Items

Use for "something changed" indicators. Keep rare—too many becomes noise.

---

## 6) Lists and Scroll Effects

### Signature Effect Pattern

Use `scrollTransition` for scroll-driven motion. Pick **one** effect per surface.

```swift
.scrollTransition(axis: .horizontal) { content, phase in
    content
        .rotationEffect(.degrees(phase.value * 2.5))
        .offset(y: phase.isIdentity ? 0 : 8)
}
```

### Visual Effect (Geometry-Aware)

```swift
.visualEffect { content, proxy in
    content
        .opacity(proxy.frame(in: .scrollView).minY > 0 ? 1 : 0.5)
}
```

Great for: subtle parallax, fade near edges, depth shifts.

### Scroll Edge Effect Tuning

```swift
.scrollEdgeEffectStyle(.soft)  // iOS/iPadOS typical
.scrollEdgeEffectStyle(.hard)  // macOS for stronger separation
```

---

## 7) Animation Patterns

### State-Driven Animation

```swift
// Model state
@State private var isExpanded = false

// Animate between states
Button("Toggle") {
    withAnimation(.snappy) {
        isExpanded.toggle()
    }
}

// Or implicit
.animation(.snappy, value: isExpanded)
```

### Custom Transition

```swift
struct SlideAndFade: Transition {
    func body(content: Content, phase: TransitionPhase) -> some View {
        content
            .offset(y: phase.isIdentity ? 0 : 20)
            .opacity(phase.isIdentity ? 1 : 0)
    }
}

// Usage
.transition(SlideAndFade())
```

Use for: onboarding reveals, mode switches, panel show/hide.
Avoid for: simple list updates, frequent toggles.

### Text Renderer (Advanced)

Line-by-line or glyph-by-glyph animation via `TextRenderer`. Use only for marketing-quality onboarding or key value proposition emphasis.

### Shaders

Use `layerEffect` with `keyframeAnimator` for:
- Touch ripples
- Subtle texture fills
- "Premium" interactions

Always: Reduce Motion fallback, rare and meaningful.

---

## 8) Data Flow Architecture

### Identity, Lifetime, Dependencies

- **Identity** determines if view is "same thing" across updates (changing resets state)
- **Lifetime** affects when state created/destroyed (mis-scoped @StateObject causes repeated loads)
- **Dependencies** drive invalidation (reduce in expensive subtrees)

### Observation Pattern

```swift
@Observable
class ViewModel {
    var items: [Item] = []
    var isLoading = false
}

// View only re-renders when accessed properties change
struct ItemList: View {
    var viewModel: ViewModel

    var body: some View {
        List(viewModel.items) { item in
            ItemRow(item: item)
        }
    }
}
```

### Architecture Selection

- **MVVM**: Simple and effective for most features
- **Unidirectional (TCA-style)**: Complex navigation + async + lots of state + edge cases

### Compose Small Views

Extract: row rendering, headers, cards, toolbars. Keep each focused and previewable.

---

## 9) Performance

### SwiftUI Instrument (Instruments 26)

1. Reproduce hitch/hang
2. Record with SwiftUI template
3. Check: "Long View Body Updates", representable updates
4. Identify triggering state changes
5. Reduce dependency scope or move work off main thread

### Body Must Be Cheap

**Don't do in body:**
- Sorting/filtering large arrays
- Date formatting in loops
- Image decoding
- Any synchronous I/O

**Do:**
- Precompute in model layer
- Cache derived values
- Move formatting to precomputed strings

### Dependency Hygiene

- Keep `@State` local to smallest subtree
- Pass `Binding` or derived values, not whole model
- Use `Equatable` conformance where it helps
- Ensure stable `id` in lists

---

## 10) Accessibility

### Dynamic Type

- System text styles only
- Don't clip large text
- Layout adapts: stacks turn vertical, rows multi-line
- Toolbars use menus when crowded

### VoiceOver

- Use `Label` and `LabeledContent` (better semantics)
- Add `.accessibilityLabel`, `.accessibilityValue`, `.accessibilityHint`
- Focus order matches reading order

### Motion and Transparency

If Reduce Motion enabled:
- Remove large parallax
- Use opacity instead of scale/rotation

If Reduce Transparency enabled:
- Don't rely on translucency for boundaries
- Increase separation via layout and solid surfaces

### Touch Targets

Minimum 44×44pt. For small icons:

```swift
Button {
    // action
} label: {
    Image(systemName: "star")
        .padding(12)  // Expands touch target
}
.contentShape(Rectangle())
```

---

## 11) Implementation Recipes

### Screen Scaffold

```swift
struct Screen<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                content
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .navigationTitle(title)
    }
}
```

### Liquid Glass Badge (iOS 26+)

```swift
struct GlassBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .glassEffect()
    }
}
```

### Empty State

```swift
struct EmptyState: View {
    let icon: String
    let title: String
    let message: String
    let action: (() -> Void)?
    let actionLabel: String?

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: icon)
        } description: {
            Text(message)
        } actions: {
            if let action, let label = actionLabel {
                Button(label, action: action)
            }
        }
    }
}
```

---

## 12) ADA-Level Review Checklist

### Visual Hierarchy
- [ ] One clear hero element
- [ ] One primary action per moment
- [ ] Secondary actions grouped or in menus
- [ ] No unnecessary decoration behind toolbars/tab bars

### Motion & Feedback
- [ ] Motion communicates causality
- [ ] Effects rare and purposeful
- [ ] Reduce Motion fallback exists

### Liquid Glass (iOS 26+)
- [ ] Glass for navigation/control layer only
- [ ] No glass-on-glass clutter
- [ ] Tint only for meaning/primary actions
- [ ] Scroll edge effects only where appropriate
- [ ] Nearby glass grouped in `GlassEffectContainer`

### Accessibility
- [ ] Dynamic Type works at XXL+
- [ ] VoiceOver labels/hints on non-obvious controls
- [ ] Contrast sufficient with Increased Contrast
- [ ] 44×44pt touch targets

### Performance
- [ ] No heavy work in body
- [ ] Stable identity in lists
- [ ] Instrumented if any hitch

---

## 13) LLM Output Structure

When generating SwiftUI UI, structure output as:

1. **UX Intent** — goal, primary action, states
2. **Hierarchy & Layout** — hero, grouping, navigation
3. **Design Tokens** — spacing/radius/type used
4. **Interaction Spec** — tap/drag/scroll behaviors
5. **Animation Plan** — where, why, fallbacks
6. **Accessibility Plan**
7. **Performance Notes**
8. **SwiftUI Code** — componentized, previewable

---

## Source References

- [WWDC25: Instruments for SwiftUI](https://developer.apple.com/videos/play/wwdc2025/306/)
- [WWDC25: Get to know the new design system](https://developer.apple.com/videos/play/wwdc2025/356/)
- [WWDC25: Adopting SwiftUI](https://developer.apple.com/videos/play/wwdc2025/323/)
- [WWDC25: Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/)
- [WWDC24: Create custom visual effects](https://developer.apple.com/videos/play/wwdc2024/10151/)
- [WWDC23: Discover Observation](https://developer.apple.com/videos/play/wwdc2023/10149/)
- [WWDC21: Demystify SwiftUI](https://developer.apple.com/videos/play/wwdc2021/10022/)
- [ConcentricRectangle Documentation](https://developer.apple.com/documentation/swiftui/concentricrectangle)
- [ToolbarSpacer Documentation](https://developer.apple.com/documentation/swiftui/toolbarspacer)
- [Apple Design Awards 2025](https://www.apple.com/newsroom/2025/06/apple-unveils-winners-and-finalists-of-the-2025-apple-design-awards/)
