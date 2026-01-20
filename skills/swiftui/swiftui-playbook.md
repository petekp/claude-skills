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

### NSViewRepresentable Layout Pitfalls (macOS)

Wrapping SwiftUI views in `NSViewRepresentable` (via `NSHostingView`) introduces different sizing behavior that can break layout unexpectedly.

**Common mistake:** Creating custom window drag areas with `Color.clear.frame(maxWidth: .infinity, maxHeight: .infinity)` wrapped in NSViewRepresentable.

**What happens:** The `maxHeight: .infinity` constraint propagates through the NSHostingView wrapper differently than pure SwiftUI, causing parent containers (VStack, HStack) to expand incorrectly and push content out of position.

**Correct pattern for window dragging:**

```swift
// In App.swift / WindowGroup configuration
window.isMovableByWindowBackground = true  // Let macOS handle it natively

// Only prevent on elements that need drag-and-drop
final class NonDraggableHostingView<Content: View>: NSHostingView<Content> {
    override var mouseDownCanMoveWindow: Bool { false }
}

struct PreventWindowDrag<Content: View>: NSViewRepresentable {
    let content: Content

    func makeNSView(context: Context) -> NonDraggableHostingView<Content> {
        NonDraggableHostingView(rootView: content)
    }

    func updateNSView(_ nsView: NonDraggableHostingView<Content>, context: Context) {
        nsView.rootView = content
    }
}

extension View {
    func preventWindowDrag() -> some View {
        PreventWindowDrag(content: self)
    }
}

// Usage on draggable cards
ProjectCardView(...)
    .preventWindowDrag()  // Only this card won't trigger window drag
```

**Rule:** Don't fight macOS—use native `isMovableByWindowBackground` and surgically disable on specific elements, rather than trying to create custom drag areas with SwiftUI views wrapped in NSViewRepresentable.

### Swift ViewBuilder vs TableColumnBuilder Ambiguity

**Problem:** Compiler error about `Group` or unexpected behavior when using `Group { }` in certain contexts.

**Root cause:** Swift's `Group` has multiple initializers. In some contexts (especially with complex nested views), the compiler may pick `TableColumnBuilder` instead of `ViewBuilder`.

**Solution:** Explicitly specify the content parameter or annotate with `@ViewBuilder`:

```swift
// Option 1: Explicit content parameter
Group(content: {
    SectionA()
    SectionB()
})

// Option 2: @ViewBuilder annotation on computed property
@ViewBuilder
var body: some View {
    Group {
        SectionA()
        SectionB()
    }
}
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

### Hero Transitions with matchedGeometryEffect

**Common mistake:** Applying `matchedGeometryEffect` to entire view hierarchies with different content structures causes jittery animations—SwiftUI can't interpolate between incompatible layouts.

**Correct pattern:** Match only the container shape, crossfade the content.

```swift
@Namespace private var namespace
@State private var isExpanded = false

ZStack(alignment: .topLeading) {
    // Background shape morphs (position, size, corner radius)
    RoundedRectangle(cornerRadius: isExpanded ? 12 : 10, style: .continuous)
        .fill(isExpanded ? Color.card : Color.white.opacity(0.05))
        .matchedGeometryEffect(id: "container", in: namespace)

    // Content crossfades (no matchedGeometryEffect)
    if isExpanded {
        expandedContent
            .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
    } else {
        collapsedContent
            .transition(.opacity)
    }
}
.animation(.spring(response: 0.4, dampingFraction: 0.85), value: isExpanded)
```

**Why this works:** The background shape has consistent geometry (just different sizes), so SwiftUI interpolates smoothly. The content—which has incompatible structures—simply crossfades.

This is how Apple implements App Store card transitions.

### Origin-Based Modal Animation

Animate a modal expanding from (and collapsing to) a specific trigger location.

**Key challenges solved:**
- `onChange(of:)` doesn't fire on initial mount—need `onAppear` for initial state
- Conditional rendering (`if isPresented`) removes view immediately—no exit animation
- Nested `scaleEffect` with different anchors conflict

**Implementation pattern:**

```swift
// 1. Named coordinate space at container level
ContentView()
    .coordinateSpace(name: "container")

// 2. Capture trigger frame in that space
Button(action: { action(buttonFrame) }) { ... }
    .background(GeometryReader { geo in
        Color.clear.preference(key: FramePreferenceKey.self,
                               value: geo.frame(in: .named("container")))
    })
    .onPreferenceChange(FramePreferenceKey.self) { buttonFrame = $0 }

// 3. Modal: separate visibility state from animation state
@State private var isVisible = false    // Tree presence
@State private var animatedIn = false   // Animation driver

var anchorPoint: UnitPoint {
    guard let origin = originFrame, origin != .zero else { return .center }
    return UnitPoint(x: origin.midX / containerSize.width,
                     y: origin.midY / containerSize.height)
}

var body: some View {
    ZStack {
        if isVisible {
            content
                .scaleEffect(animatedIn ? 1 : 0.3, anchor: anchorPoint)
                .opacity(animatedIn ? 1 : 0)
        }
    }
    .onAppear {
        if isPresented {  // Handle already-true on mount
            isVisible = true
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                animatedIn = true
            }
        }
    }
    .onChange(of: isPresented) { _, show in
        if show {
            isVisible = true
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                animatedIn = true
            }
        } else {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                animatedIn = false
            } completion: {
                isVisible = false  // Remove after animation
            }
        }
    }
}
```

**Why this works:**
- Named coordinate space ensures consistent measurements between trigger and modal
- `isVisible` keeps view in tree during exit animation
- `animatedIn` provides state that changes (unlike `isPresented` already true on mount)
- `completion:` sequences removal after animation finishes

### Text Renderer (Advanced)

Line-by-line or glyph-by-glyph animation via `TextRenderer`. Use only for marketing-quality onboarding or key value proposition emphasis.

### Shaders

Use `layerEffect` with `keyframeAnimator` for:
- Touch ripples
- Subtle texture fills
- "Premium" interactions

Always: Reduce Motion fallback, rare and meaningful.

### Effect Modifier Order: Blur and Clip

**Problem:** Content with blur applied extends beyond rounded corners, causing visual overflow.

**Why:** Gaussian blur samples neighboring pixels, expanding the rendered area beyond the original view bounds. A clip applied *before* blur constrains the input, but the blur output still extends past the boundary.

**Correct pattern:** Apply `.clipShape()` AFTER `.blur()` to trim the output.

```swift
// Wrong - blur extends beyond clip
.clipShape(RoundedRectangle(cornerRadius: 22))
.blur(radius: 8)

// Correct - blur output is trimmed
.blur(radius: 8)
.clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
```

**Related caveat:** `.ignoresSafeArea()` can override ancestor clip shapes. If content still pokes out corners after clipping, check for safe area modifiers on child views.

### Overlay Technique for Drag-and-Drop Reordering

**Problem:** SwiftUI's declarative `.animation()` modifier conflicts with imperative `DragGesture` control. When you have a list that animates on reorder AND a dragged item following the cursor, both systems fight—causing jitter, bouncing, or erratic behavior.

**Root cause:** `withAnimation` and `.animation()` modifiers affect ALL state changes within their scope. When a drag gesture continuously updates position while the list is also animating reorder changes, SwiftUI tries to animate both simultaneously with conflicting intent.

**Solution: The Overlay Technique**

Render the dragged item in a separate overlay layer, completely isolated from the list's animation system.

```swift
@State private var draggingId: String?
@State private var dragPosition: CGPoint = .zero
@State private var containerFrame: CGRect = .zero
@State private var isAnimatingRelease = false

var body: some View {
    ZStack(alignment: .topLeading) {
        // Layer 1: The list (items animate freely)
        listContent
            .background(GeometryReader { geo in
                Color.clear.onAppear { containerFrame = geo.frame(in: .global) }
            })

        // Layer 2: Dragged item overlay (follows cursor directly)
        if let item = draggingItem {
            ItemRow(item: item)
                .frame(height: rowHeight)
                .scaleEffect(isAnimatingRelease ? 1.0 : 1.03)
                .shadow(color: .black.opacity(isAnimatingRelease ? 0 : 0.3),
                        radius: isAnimatingRelease ? 0 : 12, y: 4)
                .position(x: containerFrame.width / 2,
                          y: dragPosition.y - containerFrame.minY)
                .animation(.spring(response: 0.3, dampingFraction: 1.0), value: dragPosition)
                .allowsHitTesting(false)
        }
    }
}

private var listContent: some View {
    VStack(spacing: rowSpacing) {
        ForEach(items) { item in
            ItemRow(item: item)
                .opacity(draggingId == item.id ? 0 : 1)  // Hide original
                .gesture(DragGesture(coordinateSpace: .global)
                    .onChanged { handleDrag(item: item, position: $0.location) }
                    .onEnded { _ in handleDragEnd() })
        }
    }
    // Safe to animate—dragged item is in overlay, not here
    .animation(.spring(response: 0.3, dampingFraction: 0.9), value: items.map(\.id))
}

private func handleDragEnd() {
    guard let id = draggingId else { return }
    let targetIndex = items.firstIndex { $0.id == id } ?? 0
    let targetY = containerFrame.minY + (CGFloat(targetIndex) * (rowHeight + rowSpacing)) + (rowHeight / 2)

    // Animate overlay to final position
    isAnimatingRelease = true
    dragPosition = CGPoint(x: dragPosition.x, y: targetY)

    // Clean up after animation
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        draggingId = nil
        dragPosition = .zero
        isAnimatingRelease = false
    }
}
```

**Why this works:**
1. **List items** use `.animation()` modifier—declarative, animates when array identity changes
2. **Overlay item** uses `.position()` following cursor—imperative, updates directly
3. **No conflict** because they're in separate layers; SwiftUI never tries to animate both
4. **Release animation**: Animate `dragPosition` to target slot before hiding overlay

**macOS floating window caveat:** When `window.isMovableByWindowBackground = true`, background clicks move the window—intercepting drag gestures. Wrap draggable content in an `NSViewRepresentable` that returns `false` from `mouseDownCanMoveWindow`:

```swift
private struct NonMovableBackground: NSViewRepresentable {
    private class NonMovableNSView: NSView {
        override var mouseDownCanMoveWindow: Bool { false }
    }
    func makeNSView(context: Context) -> NSView {
        let view = NonMovableNSView()
        view.wantsLayer = true
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}

// Usage: wrap each draggable row
ItemRow(item: item)
    .background(NonMovableBackground())
```

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

### Static Singleton Initialization Deadlock

**Problem:** App crashes with `EXC_BREAKPOINT` in `dispatch_once_wait` during static singleton initialization.

**Root cause:** A static singleton's initializer references a computed property that accesses the same singleton, creating a circular dependency during `dispatch_once`.

**Example of the bug:**
```swift
class GlassConfig: ObservableObject {
    static let shared = GlassConfig()  // Triggers init()

    // BAD: .statusWorking accesses GlassConfig.shared → deadlock
    @Published var vignetteColor: Color = .statusWorking
}

extension Color {
    static var statusWorking: Color {
        let config = GlassConfig.shared  // Deadlock here!
        return Color(hue: config.workingHue, ...)
    }
}
```

**Solution:** Use raw values in singleton property initializers, never computed properties that might reference the singleton:

```swift
// GOOD: Raw value, no external dependencies
@Published var vignetteColor: Color = Color(hue: 0.103, saturation: 1.0, brightness: 1.0)
```

**Debugging tip:** LLDB backtrace will show the circular call pattern clearly:
```
frame #2: GlassConfig.shared.unsafeMutableAddressor()
frame #3: static Color.statusWorking.getter()
frame #4: GlassConfig.init()
frame #6: one-time initialization function for shared()
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
