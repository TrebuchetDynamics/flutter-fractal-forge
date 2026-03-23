# UI Guidelines - Flutter Fractal Forge

## Design Philosophy

- **Dark-first**: Dark theme is the primary experience (fractals look best on dark backgrounds)
- **Performance-first**: UI must never block GPU rendering (60 FPS target)
- **Accessibility-first**: WCAG AAA compliance required on all interactive elements

---

## Color Palette

### Primary Colors

| Name | Hex | Usage |
|------|-----|-------|
| Background | `#0A0520` | Main app background |
| Surface | `#120A2E` | Cards, sheets, dialogs |
| Surface Variant | `#1A1238` | Elevated surfaces |
| Primary | `#7C4DFF` | Buttons, FABs, selections |
| Primary Variant | `#9E7BFF` | Hover states, accents |
| Secondary | `#00BCD4` | Secondary actions, links |
| On Background | `#FFFFFF` | Primary text |
| On Surface | `#E0E0E0` | Secondary text |
| Error | `#CF6679` | Error states |

### Accent Colors (Fractal Categories)

| Category | Color |
|----------|-------|
| Escape-time | `#4FC3F7` |
| Attractors | `#81C784` |
| Cellular Automata | `#FFB74D` |
| Space-filling | `#F06292` |
| 3D Ray-marched | `#BA68C8` |

---

## Typography

### Font Family

- Primary: System default (Roboto on Android, SF Pro on iOS)
- Monospace: For coordinate display (`0.123456789`)

### Scale

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| Headline Large | 32sp | Bold | Screen titles |
| Headline Medium | 24sp | SemiBold | Section headers |
| Title Large | 20sp | Medium | Card titles |
| Title Medium | 16sp | Medium | List items |
| Body Large | 16sp | Regular | Primary content |
| Body Medium | 14sp | Regular | Secondary content |
| Label Large | 14sp | Medium | Buttons |
| Label Small | 12sp | Regular | Captions, hints |

---

## Spacing System

### Base Unit: 4px

| Token | Value | Usage |
|-------|-------|-------|
| `xxs` | 4px | Tight spacing |
| `xs` | 8px | Icon padding |
| `sm` | 12px | List item padding |
| `md` | 16px | Card padding |
| `lg` | 24px | Section spacing |
| `xl` | 32px | Screen margins |
| `xxl` | 48px | Large gaps |

### Safe Area

- Top: Respect system status bar
- Bottom: Respect navigation gestures
- Horizontal: 16px minimum margin

---

## Components

### App Bar

- Height: 56px
- Background: Surface (`#120A2E`)
- Title: Headline Medium, left-aligned
- Actions: Icon buttons, 48x48 touch target

### Bottom Sheet

- Background: Surface with 16px top radius
- Drag handle: 32x4px, centered, `#FFFFFF` at 20% opacity
- Max height: 90% screen height
- Animation: 300ms ease-out slide

### Cards (Catalog Items)

- Size: Grid layout (2 columns on phone, 3-4 on tablet)
- Border radius: 12px
- Thumbnail: Aspect ratio 1:1
- Title: Label Large, max 2 lines, ellipsis overflow
- Touch target: Entire card

### Buttons

| Type | Background | Text | Border |
|------|------------|------|--------|
| Primary | Primary (`#7C4DFF`) | White | None |
| Secondary | Transparent | Primary | 1px Primary |
| Text | Transparent | Primary | None |
| FAB | Primary | White | None |

### Controls (Parameter Sliders)

- Track height: 4px
- Thumb: 20px diameter
- Value label: Above thumb, Body Medium
- Active track: Primary color
- Inactive track: White at 20% opacity

---

## Navigation

### Screen Flow

```
HomeScreen
├── CatalogScreen
│   └── FractalViewerScreen
│       ├── Controls (Bottom Sheet)
│       ├── Settings (Sheet)
│       └── Export (Sheet)
├── HistoryScreen
├── SettingsScreen
│   ├── AccessibilitySettings
│   └── About
└── OnboardingScreen (first launch)
```

### Transitions

- **Forward**: Slide from right (300ms)
- **Back**: Slide to right (300ms)
- **Modal**: Slide from bottom (250ms)

---

## Viewer Specific

### Gesture Mapping

| Gesture | 2D Fractals | 3D Fractals |
|---------|-------------|-------------|
| Drag | Pan | Rotate |
| Pinch | Zoom | Zoom |
| Double Tap | Reset view | Reset view |
| Long Press | Set Julia seed | — |

### HUD (Heads-Up Display)

- Position: Top of screen, behind safe area
- Style: Semi-transparent black (`#000000` at 60%)
- Content: Coordinates, zoom level, FPS counter
- Auto-hide: After 3 seconds of inactivity

### Controls Overlay

- Position: Bottom of screen
- Trigger: Swipe up or tap visible area
- Content: Iteration slider, palette picker, bailout input

---

## Accessibility Requirements

### Touch Targets

- Minimum: 48x48 dp
- Recommended: 56x56 dp
- Padding between targets: 8px minimum

### Contrast Ratios (WCAG AAA)

- Primary text: 7:1 minimum
- Secondary text: 4.5:1 minimum
- UI elements: 3:1 minimum
- Use `AccessibilityService` to verify

### Screen Reader

- All images have semantic labels
- Buttons have meaningful names (not "Button")
- Charts/diagrams have detailed descriptions

### Motion

- Respect `prefers-reduced-motion`
- Disable parallax effects when enabled
- Reduce animation duration by 50%

---

## Dark Theme Implementation

```dart
// ThemeData for Flutter Fractal Forge
ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Color(0xFF0A0520),
  colorScheme: ColorScheme.dark(
    surface: Color(0xFF120A2E),
    primary: Color(0xFF7C4DFF),
    secondary: Color(0xFF00BCD4),
    error: Color(0xFFCF6679),
  ),
  // ... typography, components
)
```

---

## Performance Guidelines

1. **Never block main thread** during fractal rendering
2. **Use RepaintBoundary** for static UI elements
3. **Lazy load** catalog thumbnails
4. **Cache** shader compilations
5. **Reduce rebuilds** with `Selector` where possible

---

## Asset Requirements

### Icons

- Format: SVG preferred, PNG fallback
- Sizes: 24dp (standard), 48dp (放大)
- Style: Outlined, 2px stroke

### Thumbnails (Catalog)

- Format: PNG with transparency
- Size: 512x512 dp
- Naming: `{fractal_id}.png`

---

## Animation Standards

| Animation | Duration | Curve |
|-----------|----------|-------|
| Page transition | 300ms | easeInOut |
| Sheet open | 250ms | easeOut |
| Button press | 100ms | easeIn |
| Fade | 200ms | linear |
| Scale (feedback) | 150ms | easeOut |

---

<!-- Auto-generated -->