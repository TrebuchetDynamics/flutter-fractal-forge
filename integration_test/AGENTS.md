<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# integration_test

## Purpose
Integration tests that run on real devices/emulators. Cover end-to-end user flows, GPU rendering validation, screenshot generation, performance benchmarks, and catalog thumbnail generation.

## Key Files

| File | Description |
|------|-------------|
| `app_test.dart` | Full app integration smoke test |
| `user_flows_test.dart` | End-to-end user journey tests (catalog -> viewer -> export) |
| `render_validation_test.dart` | GPU render output correctness validation |
| `generate_gpu_thumbnails_test.dart` | Generates catalog thumbnail images via GPU rendering |
| `catalog_thumbnail_smoke_test.dart` | Quick smoke test for thumbnail generation |
| `cpu_fallback_gestures_test.dart` | Gesture handling when GPU is unavailable (CPU fallback) |
| `full_screenshots_test.dart` | Generate full app screenshots for store listing |
| `screenshots_test.dart` | Basic screenshot capture tests |
| `shader_benchmark_test.dart` | GPU shader performance benchmarks |
| `perf_smoke_test.dart` | Quick performance regression check |

## For AI Agents

### Working In This Directory
- Run: `/home/xel/flutter/bin/flutter test integration_test/`
- Requires a running device or emulator (Linux desktop or Android)
- Some tests generate files to `assets/catalog_thumbs/`
- GPU thumbnail tests need a GPU-capable environment

### Testing Requirements
- Integration tests use `IntegrationTestWidgetsFlutterBinding`
- Tests may take several minutes due to GPU rendering
- Screenshot tests save to local filesystem

## Dependencies

### Internal
- `lib/` - Full application code
- `assets/catalog_thumbs/` - Output directory for generated thumbnails

### External
- `integration_test` SDK package

<!-- MANUAL: -->
