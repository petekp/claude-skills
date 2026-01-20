# LLM Export Format Template

This template shows the ideal format for exporting tuned parameters so another Claude instance can immediately apply them.

---

## Example Export Output

```markdown
## Tuned Parameters for CardHoverAnimation

I've dialed in these values for the hover animation on the product card:

### Final Configuration

```typescript
// Spring physics - tuned for premium feel
const springConfig = {
  type: 'spring',
  stiffness: 220,      // Slightly snappy
  damping: 28,         // Minimal overshoot
  mass: 0.8,           // Light, responsive
};

// Hover transform - subtle but noticeable
const hoverAnimation = {
  scale: 1.02,
  y: -6,
  rotate: 0,
  boxShadow: '0 12px 32px rgba(0,0,0,0.12)',
};

// Layout values
const layout = {
  padding: 20,
  borderRadius: 16,
  gap: 12,
};

// Color palette
const colors = {
  background: '#fafafa',
  accent: '#4f46e5',
  text: '#18181b',
};
```

### Changes from Defaults

| Parameter | Default | Tuned | Rationale |
|-----------|---------|-------|-----------|
| stiffness | 180 | 220 | Faster initial response |
| damping | 20 | 28 | Reduces oscillation for cleaner settle |
| mass | 1 | 0.8 | Lighter feel, more immediate |
| y | -4 | -6 | More pronounced lift effect |
| shadowBlur | 24px | 32px | Softer, more diffuse shadow |
| borderRadius | 12px | 16px | Rounder corners match design system |

### Tuning Rationale

The goal was a "premium" hover feel:
- **Quick response** (high stiffness) makes the UI feel responsive
- **Low overshoot** (high damping) avoids playful/bouncy feel
- **Subtle scale** (1.02) gives depth without distraction
- **Pronounced lift** (-6px y) combined with larger shadow creates elevation

### Apply These Values

Update `src/components/ProductCard.tsx` lines 45-62 with the configuration above.

Alternatively, extract to a shared animation config:

```typescript
// src/config/animations.ts
export const cardHover = {
  spring: { type: 'spring', stiffness: 220, damping: 28, mass: 0.8 },
  hover: { scale: 1.02, y: -6 },
  shadow: { rest: '0 4px 12px rgba(0,0,0,0.08)', hover: '0 12px 32px rgba(0,0,0,0.12)' },
};
```
```

---

## Export Format Requirements

### Required Sections

1. **Title** - What was tuned and where
2. **Final Configuration** - Code-ready values
3. **Changes from Defaults** - What was modified
4. **Apply Instructions** - Where to put the values

### Optional Sections

- **Tuning Rationale** - Why these values work
- **Alternative Approaches** - Other configs tried
- **Presets** - Named configurations for different feels

---

## Format by Platform

### React (Leva/Framer Motion)

```typescript
const config = {
  spring: { stiffness: 180, damping: 20 },
  values: { scale: 1.05, y: -4 },
};
```

### Swift (SwiftUI)

```swift
let animation = Animation.spring(
    response: 0.4,
    dampingFraction: 0.7,
    blendDuration: 0
)
```

### CSS

```css
.element {
  transition: transform 400ms cubic-bezier(0.32, 0.72, 0, 1);
}
.element:hover {
  transform: scale(1.02) translateY(-4px);
}
```

### Tailwind

```html
<div class="transition-transform duration-400 ease-out hover:scale-102 hover:-translate-y-1">
```

---

## Implementation Notes

### Clipboard Copy Function

```typescript
function exportForLLM(currentValues: Values, defaults: Values, context: string) {
  const changes = Object.entries(currentValues)
    .filter(([key, val]) => val !== defaults[key])
    .map(([key, val]) => ({
      param: key,
      from: defaults[key],
      to: val,
    }));

  const markdown = `## Tuned Parameters for ${context}

### Final Values
\`\`\`typescript
${JSON.stringify(currentValues, null, 2)}
\`\`\`

### Changes from Defaults
${changes.map(c => `- **${c.param}**: \`${c.from}\` → \`${c.to}\``).join('\n')}
`;

  navigator.clipboard.writeText(markdown);
}
```

### Toast/Alert Feedback

Always confirm the copy action:
```typescript
// Simple
alert('Copied to clipboard!');

// Better (with toast library)
toast.success('Tuning values copied! Paste into Claude.');

// Best (inline feedback)
setCopied(true);
setTimeout(() => setCopied(false), 2000);
```
