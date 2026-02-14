<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# debug

## Purpose
Debug and diagnostic overlays for development. Provides real-time performance metrics, shader compilation status, and rendering diagnostics.

## Key Files

| File | Description |
|------|-------------|
| `debug_overlay.dart` | `DebugOverlay` - shows FPS, frame time, memory usage, and render state |
| `performance_overlay.dart` | `PerformanceOverlay` - focused performance metrics display |
| `shader_debug_overlay.dart` | `ShaderDebugOverlay` - shader compilation status and uniform values |
| `shader_lab_screen.dart` | `ShaderLabScreen` - interactive shader testing and experimentation screen |

## For AI Agents

### Working In This Directory
- Debug overlays only visible in debug builds (`kDebugMode`)
- ShaderLab is a standalone screen for testing shader parameters
- Performance overlay uses `PerformanceService` for metrics

### Testing Requirements
- `test/debug_overlay_widget_test.dart`

## Dependencies

### Internal
- `core/services/performance_service.dart` - Performance metrics
- `core/services/shader_service.dart` - Shader compilation info

<!-- MANUAL: -->
