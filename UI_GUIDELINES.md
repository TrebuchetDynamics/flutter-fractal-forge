# UI Guidelines - Flutter Fractal Forge

## Design Philosophy

- **Dark-first**: Dark theme is the primary experience (fractals look best on dark backgrounds)
- **Performance-first**: UI must never block GPU rendering (60 FPS target)
- **Accessibility-first**: WCAG AAA for all text. Every token a user reads
  clears 7:1 on both surfaces — see [Contrast Ratios](#contrast-ratios).

---

## Color Palette

Values below are `AppColors` in `lib/core/theme/app_theme.dart` (the default
dark theme). `HighContrastColors` and `OledColors` in the same file define the
other two themes and deliberately differ.

### Surfaces

| Token | Hex | Usage |
|-------|-----|-------|
| `background` | `#0A0A12` | Main app background |
| `surface` | `#12121C` | Cards, sheets, dialogs |
| `surfaceVariant` | `#1A1A28` | Elevated surfaces, tiles |
| `surfaceElevated` | `#22222E` | Raised surfaces |

### Accents

| Token | Hex | Usage |
|-------|-----|-------|
| `primary` | `#7C4DFF` | Filled buttons, FABs, selection fills |
| `primaryLight` | `#C7A4FF` | Text buttons, accents on a bare surface |
| `primaryDark` | `#5C3DBF` | Pressed/darker accent |
| `secondary` | `#18FFFF` | Secondary actions, links |
| `secondaryLight` | `#76FFFF` | — |
| `secondaryDark` | `#00E5CC` | — |

Use `primaryLight`, not `primary`, for text that sits directly on a surface:
`primary` measures 3.86:1 on `surface`, under the 4.5 WCAG AA threshold for
body text, while `primaryLight` gives 9.02:1. `primary` is fine on a filled
button, which supplies its own background.

### Text and lines

| Token | Hex | Usage |
|-------|-----|-------|
| `textPrimary` | `#F5F5F7` | Primary text |
| `textSecondary` | `#B0B0B8` | Secondary text |
| `textMuted` | `#6E6E7A` | Hints, decorative icons |
| `border` | `#2A2A38` | Borders, drag handles |
| `borderLight` | `#3A3A48` | Emphasised borders |
| `divider` | `#1E1E28` | Dividers |

`textMuted` measures 3.49:1 on a `surfaceVariant` tile, which clears the 3:1
non-text threshold but not the 4.5 needed for body copy — keep it for icons and
decoration, not for text a user has to read.

### Status

| Token | Hex |
|-------|-----|
| `success` | `#4CAF50` |
| `warning` | `#FFB74D` |
| `error` | `#EF5350` |

There is no per-category accent palette in the code; catalog families are
distinguished by thumbnail, not by colour.

---

## Typography

### Font Family

- Primary: System default (Roboto on Android, SF Pro on iOS)
- Monospace: For coordinate display (`0.123456789`)

### Scale

`AppTypography` in `lib/core/theme/app_theme.dart`. The scale is compact —
these are the real sizes, not the Material defaults the names suggest.

| Style | Size | Usage |
|-------|------|-------|
| `headlineLarge` | 20 | Screen titles |
| `headlineMedium` | 18 | Section headers |
| `titleLarge` | 16 | Card titles |
| `titleMedium` | 14 | List items |
| `bodyLarge` | 15 | Primary content |
| `bodyMedium` | 14 | Secondary content |
| `labelLarge` | 14 | Buttons |
| `labelSmall` | 10 | Captions, hints |

Every surface must survive the system text scale. Put a `Text` that sits
directly in a bounded `Row` inside a `Flexible` with an ellipsis, and give a
pinned block a height ceiling with its own scroll — an unconstrained label
grows until it squeezes a sibling `Expanded` to zero and the content beside it
disappears. `test/golden/overflow_detection_test.dart` sweeps 1.0/1.3/2.0/3.0x
at phone widths; the default 800x600 test surface is wide enough to hide these
faults, so always set a phone surface size.

---

## Spacing System

### Base Unit: 4px

`AppSpacing` in `lib/core/theme/app_theme.dart`. Note the names run one step
smaller than the Material-ish scale they resemble: `md` is 12, not 16.

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4px | Tight spacing |
| `sm` | 8px | Icon padding |
| `md` | 12px | List item padding |
| `lg` | 16px | Card padding |
| `xl` | 20px | Section spacing |
| `xxl` | 24px | Screen margins |
| `xxxl` | 32px | Large gaps |

### Radii

| Token | Value |
|-------|-------|
| `cardRadius` | 16px |
| `buttonRadius` | 12px |
| `inputRadius` | 12px |
| `chipRadius` | 8px |

### Safe Area

- Top: Respect system status bar
- Bottom: Respect navigation gestures
- Horizontal: 16px minimum margin

---

## Components

### App Bar

- Height: `kToolbarHeight` (56px); `FractalAppBar` reserves `kToolbarHeight + 18`
- Background: `surface` (`#12121C`)
- Actions: icon buttons, 48x48 touch target

### Bottom Sheet

Use `AppBottomSheet` / `AppDraggableBottomSheet` in
`lib/shared/widgets/app_bottom_sheet.dart` rather than rebuilding the shell.

- Background: `surface`, 28px top radius
- Drag handle: `SheetDragHandle`, 40x4px, radius 2, `border` (`#2A2A38`)
- Max height: `maxHeightFactor`, default 0.68 of screen; landscape clamps to
  0.85–0.92 because phone landscape is short
- Content is inset above the system navigation bar via `viewPadding.bottom`

### Cards (Catalog Items)

- Size: Grid layout (2 columns on phone, 3-4 on tablet)
- Border radius: 12px
- Thumbnail: Aspect ratio 1:1
- Title: Label Large, max 2 lines, ellipsis overflow
- Touch target: Entire card

### Buttons

| Type | Background | Text | Border |
|------|------------|------|--------|
| Filled | `primary` (`#7C4DFF`) | White | None |
| Outlined | Transparent | `primary` | 1px `primary` |
| Text | Transparent | `primaryLight` (`#C7A4FF`) | None |
| FAB | `primary` gradient when active, else `surface` | White / `textPrimary` | 1px white at 14–22% |

Text buttons use `primaryLight` for contrast (see Accents). The viewer's FAB
column is `FloatingActionButtonWidget`, not a Material `FloatingActionButton`:
48px touch target around a 44px visual circle, dimmed to 38% opacity when the
button has no action left.

### Controls (Parameter Sliders)

Theme default (`sliderTheme`): 4px track, 8px thumb radius, `primary` active
track.

The compact HUD (`_CompactHudSliderRow`) overrides this with a 3px track and a
7px thumb, and wraps the `Slider` in a 48px-high `SizedBox` so the draggable
band still meets the minimum touch target — the override alone sizes the box to
24px. Label and value are drawn above the track and excluded from semantics,
because the `Semantics` wrapper around the slider already carries both.

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

`AppAnimations` durations: `fast` 150ms, `normal` 250ms, `slow` 350ms,
`slower` 500ms, `instant` zero. Default curve `easeOutCubic`.

Honour reduced motion: `MediaQuery.disableAnimations` or
`AccessibilityService.reducedMotionEnabled` should suppress the animation only.
Haptics are a separate preference and must keep firing — they are the only
non-visual confirmation that a tap registered.

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

### Contrast Ratios

Measured against the dark theme, `surface` `#12121C` / `surfaceVariant`
`#1A1A28`:

| Token | on surface | on variant | AA (4.5) | AAA (7) |
|-------|-----------|-----------|----------|---------|
| `textPrimary` | 17.08 | 15.78 | pass | pass |
| `textSecondary` | 8.63 | 7.98 | pass | pass |
| `primaryLight` | 9.02 | 8.33 | pass | pass |
| `textMuted` | 3.70 | 3.42 | **fail** | fail |

`textMuted` clears the 3:1 threshold for icons and decoration only; do not use
it for text. Everything a user reads clears AAA.

`test/a11y/accent_contrast_test.dart` locks these ratios by arithmetic, since
Flutter's `textContrastGuideline` only enforces the AA floor. It also asserts
`primary` still fails AA on a bare surface, which is the reason
`primaryLight` exists as a separate token.

What is actually enforced: `test/a11y/semantics/interactive_name_audit_test.dart`
asserts Flutter's `textContrastGuideline`, which is the **AA** 4.5 threshold,
across the app shell, viewer, accessibility settings, export sheet and controls
HUD. Pass the real theme when testing a translucent overlay — the HUD reports
false failures against the default light `Scaffold` because its background
composites over white.

### Screen Reader

- All images have semantic labels
- Buttons have meaningful names (not "Button")
- Charts/diagrams have detailed descriptions
- One control announces as exactly one stop. A `Semantics(label:)` wrapper with
  a gesture widget under it splits into two nodes whenever something between
  them forces a semantics boundary — a `Tooltip`, a `FocusableActionDetector`,
  a `Slider`'s own thumb. Wrap in `MergeSemantics`, or `ExcludeSemantics` the
  subtree when the outer wrapper already carries the whole description.
  `findStackedStops` in `test/a11y/semantics/interactive_name_audit.dart` gates
  this; Flutter's `labeledTapTargetGuideline` does **not** catch it.
- A slider must name what it adjusts. A value alone ("69%") tells a screen
  reader user nothing.
- Toggles carry their state in semantics, not only in colour or a check icon.

### Motion

- Respect `prefers-reduced-motion`
- Disable parallax effects when enabled
- Reduce animation duration by 50%

---

## Dark Theme Implementation

Do not hand-roll a `ThemeData`. `AppTheme.dark`, `AppTheme.highContrast` and
`AppTheme.oled` in `lib/core/theme/app_theme.dart` are the three themes, and
they already wire the tokens above into `colorScheme`, `textTheme`, and the
per-component themes. Change the theme there rather than restyling at a call
site, so a fix reaches every widget that inherits it.

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
- Sizes: 24dp (standard), 48dp (large)
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