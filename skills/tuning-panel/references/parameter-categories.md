# Parameter Categories Reference

Exhaustive lists of parameters to surface for different tuning domains. When in doubt, include the parameter—visibility costs little, missing parameters break flow.

## Animation Parameters

### Timing
| Parameter | Type | Typical Range | Notes |
|-----------|------|---------------|-------|
| duration | number | 0-2000ms | Total animation time |
| delay | number | 0-1000ms | Before animation starts |
| iterationCount | number/infinite | 1-10 | Loop count |
| direction | enum | normal, reverse, alternate | Playback direction |
| fillMode | enum | none, forwards, backwards, both | End state behavior |

### Easing
| Parameter | Type | Options | Notes |
|-----------|------|---------|-------|
| easing | enum | linear, ease, ease-in, ease-out, ease-in-out | Preset curves |
| cubicBezier | [n,n,n,n] | 0-1 for each | Custom curve |
| steps | number | 1-60 | Step-based animation |
| stepsPosition | enum | start, end | Where step occurs |

### Spring Physics
| Parameter | Type | Typical Range | Notes |
|-----------|------|---------------|-------|
| stiffness | number | 50-500 | Spring tension |
| damping | number | 1-50 | Oscillation reduction |
| mass | number | 0.1-10 | Affects momentum |
| velocity | number | -100-100 | Initial velocity |
| restSpeed | number | 0.001-1 | Stop threshold |
| restDelta | number | 0.001-1 | Position threshold |

### Keyframes
| Parameter | Type | Notes |
|-----------|------|-------|
| keyframeTimes | number[] | Progress points (0-1) |
| keyframeValues | any[] | Values at each keyframe |
| keyframeEasings | string[] | Easing between keyframes |

---

## Layout Parameters

### Spacing (All Support Per-Side)
| Parameter | Type | Typical Range | Notes |
|-----------|------|---------------|-------|
| padding | number | 0-64px | Inner spacing |
| paddingTop/Right/Bottom/Left | number | 0-64px | Per-side padding |
| paddingX/Y | number | 0-64px | Horizontal/vertical |
| margin | number | 0-64px | Outer spacing |
| marginTop/Right/Bottom/Left | number | 0-64px | Per-side margin |
| gap | number | 0-32px | Flex/grid gap |
| rowGap | number | 0-32px | Grid row spacing |
| columnGap | number | 0-32px | Grid column spacing |

### Sizing
| Parameter | Type | Typical Range | Notes |
|-----------|------|---------------|-------|
| width | number/string | 0-1000px, auto, 100% | Element width |
| height | number/string | 0-1000px, auto, 100% | Element height |
| minWidth | number | 0-500px | Minimum constraint |
| maxWidth | number | 100-2000px | Maximum constraint |
| minHeight | number | 0-500px | Minimum constraint |
| maxHeight | number | 100-2000px | Maximum constraint |
| aspectRatio | number | 0.25-4 | Width/height ratio |

### Flexbox
| Parameter | Type | Options | Notes |
|-----------|------|---------|-------|
| flexDirection | enum | row, column, row-reverse, column-reverse | Main axis |
| justifyContent | enum | start, center, end, space-between, space-around, space-evenly | Main axis alignment |
| alignItems | enum | start, center, end, stretch, baseline | Cross axis alignment |
| alignContent | enum | start, center, end, space-between, space-around, stretch | Multi-line alignment |
| flexWrap | enum | nowrap, wrap, wrap-reverse | Line wrapping |
| flexGrow | number | 0-5 | Growth factor |
| flexShrink | number | 0-5 | Shrink factor |
| flexBasis | number/string | 0-500px, auto | Initial size |

### Grid
| Parameter | Type | Notes |
|-----------|------|-------|
| gridTemplateColumns | string | Column definitions |
| gridTemplateRows | string | Row definitions |
| gridColumn | string | Column placement |
| gridRow | string | Row placement |
| justifyItems | enum | Item horizontal alignment |
| alignSelf | enum | Override cross-axis |

### Position
| Parameter | Type | Typical Range | Notes |
|-----------|------|---------------|-------|
| position | enum | static, relative, absolute, fixed, sticky | Position type |
| top | number | -100-500px | Top offset |
| right | number | -100-500px | Right offset |
| bottom | number | -100-500px | Bottom offset |
| left | number | -100-500px | Left offset |
| zIndex | number | -10-100 | Stacking order |

---

## Visual Parameters

### Colors
| Parameter | Type | Notes |
|-----------|------|-------|
| color | color | Text color |
| backgroundColor | color | Background fill |
| borderColor | color | Border stroke |
| outlineColor | color | Focus outline |
| accentColor | color | Interactive elements |
| caretColor | color | Text cursor |
| textDecorationColor | color | Underline/strike |

### Opacity & Blend
| Parameter | Type | Typical Range | Notes |
|-----------|------|---------------|-------|
| opacity | number | 0-1 | Element transparency |
| mixBlendMode | enum | normal, multiply, screen, overlay, darken, lighten | Layer blending |
| backgroundBlendMode | enum | Same as mixBlendMode | Background blending |

### Borders
| Parameter | Type | Typical Range | Notes |
|-----------|------|---------------|-------|
| borderWidth | number | 0-8px | Stroke width |
| borderStyle | enum | solid, dashed, dotted, double, none | Stroke style |
| borderRadius | number | 0-32px | Corner rounding |
| borderTopLeftRadius | number | 0-32px | Per-corner |
| borderTopRightRadius | number | 0-32px | Per-corner |
| borderBottomLeftRadius | number | 0-32px | Per-corner |
| borderBottomRightRadius | number | 0-32px | Per-corner |

### Shadows
| Parameter | Type | Typical Range | Notes |
|-----------|------|---------------|-------|
| shadowOffsetX | number | -50-50px | Horizontal offset |
| shadowOffsetY | number | -50-50px | Vertical offset |
| shadowBlur | number | 0-50px | Blur radius |
| shadowSpread | number | -20-50px | Size adjustment |
| shadowColor | color | With alpha | Shadow color |
| shadowInset | boolean | - | Inner shadow |

### Effects
| Parameter | Type | Typical Range | Notes |
|-----------|------|---------------|-------|
| blur | number | 0-20px | Gaussian blur |
| brightness | number | 0-2 | 1 = normal |
| contrast | number | 0-2 | 1 = normal |
| saturate | number | 0-2 | 1 = normal |
| hueRotate | number | 0-360deg | Color shift |
| grayscale | number | 0-1 | Desaturation |
| sepia | number | 0-1 | Sepia tone |
| invert | number | 0-1 | Color inversion |

### Backdrop Effects
| Parameter | Type | Typical Range | Notes |
|-----------|------|---------------|-------|
| backdropBlur | number | 0-30px | Behind-element blur |
| backdropBrightness | number | 0-2 | Behind-element brightness |
| backdropSaturate | number | 0-2 | Behind-element saturation |

---

## Typography Parameters

### Font
| Parameter | Type | Options/Range | Notes |
|-----------|------|---------------|-------|
| fontFamily | string | System fonts, web fonts | Font face |
| fontSize | number | 10-72px | Text size |
| fontWeight | number | 100-900 | Boldness (use slider) |
| fontStyle | enum | normal, italic, oblique | Slant style |
| fontStretch | enum | condensed, normal, expanded | Width variant |

### Spacing
| Parameter | Type | Typical Range | Notes |
|-----------|------|---------------|-------|
| lineHeight | number | 1-2.5 | Line spacing (unitless) |
| letterSpacing | number | -0.1-0.5em | Character spacing |
| wordSpacing | number | -0.2-1em | Word spacing |
| textIndent | number | 0-48px | First line indent |

### Alignment & Transform
| Parameter | Type | Options | Notes |
|-----------|------|---------|-------|
| textAlign | enum | left, center, right, justify | Horizontal alignment |
| verticalAlign | enum | baseline, top, middle, bottom | Vertical alignment |
| textTransform | enum | none, uppercase, lowercase, capitalize | Case transform |

### Decoration
| Parameter | Type | Options | Notes |
|-----------|------|---------|-------|
| textDecoration | enum | none, underline, overline, line-through | Line decoration |
| textDecorationStyle | enum | solid, dashed, dotted, wavy | Decoration style |
| textDecorationThickness | number | 1-4px | Decoration weight |
| textUnderlineOffset | number | 0-8px | Underline distance |

### Advanced
| Parameter | Type | Notes |
|-----------|------|-------|
| textShadow | composite | X, Y, blur, color |
| textOverflow | enum | clip, ellipsis |
| whiteSpace | enum | normal, nowrap, pre, pre-wrap |
| wordBreak | enum | normal, break-all, break-word |

---

## Transform Parameters

### 2D Transforms
| Parameter | Type | Typical Range | Notes |
|-----------|------|---------------|-------|
| translateX | number | -500-500px | Horizontal shift |
| translateY | number | -500-500px | Vertical shift |
| rotate | number | -360-360deg | Rotation angle |
| scaleX | number | 0-3 | Horizontal scale |
| scaleY | number | 0-3 | Vertical scale |
| scale | number | 0-3 | Uniform scale |
| skewX | number | -45-45deg | Horizontal skew |
| skewY | number | -45-45deg | Vertical skew |

### 3D Transforms
| Parameter | Type | Typical Range | Notes |
|-----------|------|---------------|-------|
| translateZ | number | -500-500px | Depth shift |
| rotateX | number | -180-180deg | X-axis rotation |
| rotateY | number | -180-180deg | Y-axis rotation |
| rotateZ | number | -360-360deg | Z-axis rotation |
| perspective | number | 100-2000px | 3D perspective |
| perspectiveOrigin | string | Center point |

### Transform Origin
| Parameter | Type | Notes |
|-----------|------|-------|
| transformOriginX | number/string | 0-100%, px, left/center/right |
| transformOriginY | number/string | 0-100%, px, top/center/bottom |
| transformOriginZ | number | Depth origin |

---

## Physics Simulation Parameters

### Gravity & Forces
| Parameter | Type | Typical Range | Notes |
|-----------|------|---------------|-------|
| gravity | number | 0-20 | Downward force |
| gravityX | number | -10-10 | Horizontal gravity |
| gravityY | number | -10-10 | Vertical gravity |
| wind | number | -5-5 | Constant force |
| drag | number | 0-1 | Air resistance |

### Collision
| Parameter | Type | Typical Range | Notes |
|-----------|------|---------------|-------|
| restitution | number | 0-1 | Bounciness |
| friction | number | 0-1 | Surface friction |
| density | number | 0.1-10 | Mass per area |
| frictionStatic | number | 0-1 | Static friction |
| frictionAir | number | 0-0.1 | Air friction |

### Constraints
| Parameter | Type | Notes |
|-----------|------|-------|
| stiffness | number | Constraint rigidity |
| damping | number | Constraint damping |
| length | number | Rest length |

---

## 3D/WebGL Parameters

### Camera
| Parameter | Type | Typical Range | Notes |
|-----------|------|---------------|-------|
| fov | number | 30-120deg | Field of view |
| near | number | 0.01-10 | Near clipping |
| far | number | 100-10000 | Far clipping |
| zoom | number | 0.1-10 | Camera zoom |

### Lighting
| Parameter | Type | Notes |
|-----------|------|-------|
| intensity | number | Light brightness |
| distance | number | Falloff distance |
| decay | number | Falloff rate |
| angle | number | Spotlight cone |
| penumbra | number | Edge softness |
| castShadow | boolean | Shadow casting |

### Material
| Parameter | Type | Notes |
|-----------|------|-------|
| roughness | number | Surface roughness (0-1) |
| metalness | number | Metal appearance (0-1) |
| emissive | color | Self-illumination |
| emissiveIntensity | number | Emission strength |
| clearcoat | number | Clear coating (0-1) |
| transmission | number | Transparency (0-1) |
| ior | number | Index of refraction |

---

## Audio Parameters

### Playback
| Parameter | Type | Typical Range | Notes |
|-----------|------|---------------|-------|
| volume | number | 0-1 | Loudness |
| playbackRate | number | 0.25-4 | Speed |
| pan | number | -1-1 | Left/right balance |
| muted | boolean | - | Silent |

### Effects
| Parameter | Type | Notes |
|-----------|------|-------|
| reverbMix | number | Wet/dry mix |
| reverbDecay | number | Decay time |
| delayTime | number | Echo delay |
| delayFeedback | number | Echo repeats |
| lowpassFreq | number | Filter cutoff |
| highpassFreq | number | Filter cutoff |

### Envelope (ADSR)
| Parameter | Type | Typical Range | Notes |
|-----------|------|---------------|-------|
| attack | number | 0-2s | Rise time |
| decay | number | 0-2s | Fall to sustain |
| sustain | number | 0-1 | Hold level |
| release | number | 0-5s | Fade out |

---

## Responsive/Adaptive Parameters

### Breakpoints
| Parameter | Type | Notes |
|-----------|------|-------|
| mobileValue | any | Value at mobile breakpoint |
| tabletValue | any | Value at tablet breakpoint |
| desktopValue | any | Value at desktop breakpoint |

### Motion Preferences
| Parameter | Type | Notes |
|-----------|------|-------|
| reducedMotionValue | any | Value when prefers-reduced-motion |
| fullMotionValue | any | Standard value |

---

## Interaction Parameters

### Hover/Active States
| Parameter | Type | Notes |
|-----------|------|-------|
| hoverScale | number | Scale on hover |
| hoverOpacity | number | Opacity on hover |
| hoverY | number | Y offset on hover |
| activeScale | number | Scale when pressed |
| focusRingWidth | number | Focus outline size |
| focusRingOffset | number | Focus outline gap |

### Gestures
| Parameter | Type | Notes |
|-----------|------|-------|
| dragElastic | number | Drag overshoot (0-1) |
| dragMomentum | boolean | Momentum after release |
| dragConstraints | object | Drag boundaries |
| swipeThreshold | number | Swipe trigger distance |
| swipeVelocity | number | Swipe trigger speed |

---

## Selection Guidelines

### Always Include
- Any hardcoded numeric value in the target code
- All timing values (duration, delay)
- All spacing values (padding, margin, gap)
- All color values
- All sizing constraints

### Include When Relevant
- Easing/spring physics for any animation
- Typography params when tuning text
- Transform params when tuning motion
- Filter params when tuning visual effects

### Group Logically
1. Primary values (most impact) at top
2. Secondary values in collapsed folders
3. Actions (export, reset) at bottom
