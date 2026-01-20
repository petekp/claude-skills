/**
 * Complete Animation Tuning Panel Example
 *
 * This example shows how to create an exhaustive tuning panel for
 * animation parameters using leva. Toggle with Cmd+Shift+D.
 */

import { useControls, folder, button, Leva } from 'leva';
import { motion } from 'motion/react';
import { useState, useEffect } from 'react';

// Default values - keep these separate for reset and diff export
const DEFAULTS = {
  // Spring physics
  stiffness: 180,
  damping: 20,
  mass: 1,
  velocity: 0,

  // Timing
  duration: 0.4,
  delay: 0,

  // Transform
  scale: 1.05,
  y: -4,
  rotate: 0,

  // Visual
  opacity: 1,
  shadowY: 8,
  shadowBlur: 24,
  shadowOpacity: 0.15,

  // Layout
  padding: 24,
  borderRadius: 12,
  gap: 16,

  // Colors
  background: '#ffffff',
  accent: '#6366f1',
  text: '#1a1a2e',
};

export function AnimatedCard() {
  const [showPanel, setShowPanel] = useState(false);

  // Keyboard shortcut to toggle panel
  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (e.metaKey && e.shiftKey && e.key === 'd') {
        e.preventDefault();
        setShowPanel((prev) => !prev);
      }
    };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, []);

  // Only render controls in development
  const isDev = process.env.NODE_ENV === 'development';

  const values = useControls(
    {
      spring: folder(
        {
          stiffness: { value: DEFAULTS.stiffness, min: 50, max: 500, step: 10 },
          damping: { value: DEFAULTS.damping, min: 1, max: 50, step: 1 },
          mass: { value: DEFAULTS.mass, min: 0.1, max: 5, step: 0.1 },
          velocity: { value: DEFAULTS.velocity, min: -50, max: 50, step: 1 },
        },
        { collapsed: false }
      ),

      timing: folder(
        {
          duration: { value: DEFAULTS.duration, min: 0, max: 2, step: 0.05 },
          delay: { value: DEFAULTS.delay, min: 0, max: 1, step: 0.05 },
        },
        { collapsed: true }
      ),

      transform: folder(
        {
          scale: { value: DEFAULTS.scale, min: 0.8, max: 1.3, step: 0.01 },
          y: { value: DEFAULTS.y, min: -20, max: 20, step: 1 },
          rotate: { value: DEFAULTS.rotate, min: -15, max: 15, step: 0.5 },
        },
        { collapsed: false }
      ),

      visual: folder(
        {
          opacity: { value: DEFAULTS.opacity, min: 0, max: 1, step: 0.05 },
          shadowY: { value: DEFAULTS.shadowY, min: 0, max: 30, step: 1 },
          shadowBlur: { value: DEFAULTS.shadowBlur, min: 0, max: 50, step: 1 },
          shadowOpacity: { value: DEFAULTS.shadowOpacity, min: 0, max: 0.5, step: 0.01 },
        },
        { collapsed: true }
      ),

      layout: folder(
        {
          padding: { value: DEFAULTS.padding, min: 8, max: 48, step: 2 },
          borderRadius: { value: DEFAULTS.borderRadius, min: 0, max: 32, step: 1 },
          gap: { value: DEFAULTS.gap, min: 0, max: 32, step: 2 },
        },
        { collapsed: true }
      ),

      colors: folder(
        {
          background: DEFAULTS.background,
          accent: DEFAULTS.accent,
          text: DEFAULTS.text,
        },
        { collapsed: true }
      ),

      // Actions
      'Copy for LLM': button(() => copyForLLM(values)),
      'Reset All': button(() => window.location.reload()),
    },
    { collapsed: !showPanel }
  );

  // Animation configuration derived from tuned values
  const springConfig = {
    type: 'spring' as const,
    stiffness: values.stiffness,
    damping: values.damping,
    mass: values.mass,
    velocity: values.velocity,
  };

  const hoverAnimation = {
    scale: values.scale,
    y: values.y,
    rotate: values.rotate,
    boxShadow: `0 ${values.shadowY}px ${values.shadowBlur}px rgba(0,0,0,${values.shadowOpacity})`,
  };

  return (
    <>
      {/* Panel visibility control */}
      {isDev && <Leva hidden={!showPanel} />}

      {/* The animated component */}
      <motion.div
        style={{
          padding: values.padding,
          borderRadius: values.borderRadius,
          backgroundColor: values.background,
          color: values.text,
          display: 'flex',
          flexDirection: 'column',
          gap: values.gap,
          boxShadow: `0 4px 12px rgba(0,0,0,0.08)`,
          cursor: 'pointer',
        }}
        whileHover={hoverAnimation}
        transition={springConfig}
      >
        <h3 style={{ margin: 0, color: values.accent }}>Animated Card</h3>
        <p style={{ margin: 0, opacity: 0.7 }}>
          Hover to see the animation. Press Cmd+Shift+D to toggle tuning panel.
        </p>
      </motion.div>

      {/* Dev mode hint */}
      {isDev && !showPanel && (
        <div
          style={{
            position: 'fixed',
            bottom: 16,
            right: 16,
            padding: '8px 12px',
            background: 'rgba(0,0,0,0.8)',
            color: 'white',
            borderRadius: 6,
            fontSize: 12,
            fontFamily: 'monospace',
          }}
        >
          ⌘⇧D to tune
        </div>
      )}
    </>
  );
}

/**
 * Export current values in LLM-friendly format
 */
function copyForLLM(values: typeof DEFAULTS) {
  // Find what changed from defaults
  const changes = Object.entries(values)
    .filter(([key, val]) => val !== DEFAULTS[key as keyof typeof DEFAULTS])
    .map(([key, val]) => ({
      key,
      from: DEFAULTS[key as keyof typeof DEFAULTS],
      to: val,
    }));

  const markdown = `## Tuned Animation Parameters

I've dialed in these values for the card hover animation:

### Spring Configuration
\`\`\`typescript
const springConfig = {
  type: 'spring',
  stiffness: ${values.stiffness},
  damping: ${values.damping},
  mass: ${values.mass},
  velocity: ${values.velocity},
};
\`\`\`

### Hover Animation
\`\`\`typescript
const hoverAnimation = {
  scale: ${values.scale},
  y: ${values.y},
  rotate: ${values.rotate},
  boxShadow: \`0 ${values.shadowY}px ${values.shadowBlur}px rgba(0,0,0,${values.shadowOpacity})\`,
};
\`\`\`

### Layout Values
\`\`\`typescript
const layout = {
  padding: ${values.padding},
  borderRadius: ${values.borderRadius},
  gap: ${values.gap},
};
\`\`\`

### Colors
\`\`\`typescript
const colors = {
  background: '${values.background}',
  accent: '${values.accent}',
  text: '${values.text}',
};
\`\`\`

### Changes from Defaults
${
  changes.length > 0
    ? changes.map((c) => `- **${c.key}**: ${c.from} → ${c.to}`).join('\n')
    : '_No changes from defaults_'
}

### Apply These Values
Update the component with the configurations above. The spring config creates ${
    values.damping < 15 ? 'a bouncy' : values.damping > 25 ? 'a smooth' : 'a balanced'
  } feel with ${values.stiffness > 300 ? 'snappy' : values.stiffness < 150 ? 'gentle' : 'moderate'} response.`;

  navigator.clipboard.writeText(markdown);
  console.log('Copied tuning values to clipboard!');
  alert('Copied to clipboard! Paste into your LLM conversation.');
}
