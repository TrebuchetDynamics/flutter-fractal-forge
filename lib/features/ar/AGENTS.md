<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# ar

## Purpose
AR (Augmented Reality) camera overlay feature. Composites fractal rendering on top of a live camera feed for creating AR fractal videos and images.

## Key Files

| File | Description |
|------|-------------|
| `ar_overlay_screen.dart` | `ArOverlayScreen` - full-screen camera feed with fractal overlay, quality controls, and capture buttons |

## For AI Agents

### Working In This Directory
- AR mode uses `transparentBackground: true` on FractalController
- Requires camera permission (handled via `permission_handler`)
- AR quality presets stored via `ArQualityStore`
- Video capture via `ArVideoExporter` service

### Testing Requirements
- Widget test in `test/ar_overlay_screen_widget_test.dart`
- Camera mocking required for tests

## Dependencies

### Internal
- `core/services/ar_export_service.dart`, `ar_quality_store.dart`, `ar_video_exporter.dart`
- `renderer/` - Fractal rendering with transparency

### External
- `camera` - Camera feed

<!-- MANUAL: -->
