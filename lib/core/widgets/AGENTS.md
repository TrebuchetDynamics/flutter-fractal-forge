<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# widgets

## Purpose
Shared, reusable widgets used across multiple features. Provides accessibility wrappers, animation effects, and error handling boundaries.

## Key Files

| File | Description |
|------|-------------|
| `accessibility_widgets.dart` | Widgets with built-in accessibility support (semantic labels, focus management) |
| `animated_widgets.dart` | Pre-built animation widgets (fade, slide, scale transitions) |
| `animation_effects.dart` | Celebration effects, morphing transitions, visual feedback animations |
| `error_boundary.dart` | `ErrorBoundary` widget that catches and displays rendering errors gracefully |

## For AI Agents

### Working In This Directory
- These widgets are feature-agnostic - usable from any screen
- `ErrorBoundary` wraps the fractal renderer to catch GPU/shader errors
- Animation effects include splash screen (`FractalSplashScreen`) and morph transitions
- Accessibility widgets enforce proper semantic annotations

### Testing Requirements
- Error boundary tested in `test/error_boundary_test.dart`
- Accessibility tested in `test/accessibility_test.dart`

## Dependencies

### Internal
- `theme/` - AppColors and theme constants

<!-- MANUAL: -->
