<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# integration_test

## Purpose
Integration tests that run on real devices/emulators. Cover end-to-end user flows, GPU rendering validation, screenshot generation, performance benchmarks, and catalog thumbnail generation.

## Key Files

| File | Description |
|------|-------------|
| `flows/app_test.dart` | Full app integration smoke test |
| `flows/user_flows_test.dart` | End-to-end user journey tests (catalog -> viewer -> export) |
| `rendering/render_validation_test.dart` | GPU render output correctness validation |
| `catalog/generate_gpu_thumbnails_test.dart` | Generates catalog thumbnail images via GPU rendering |
| `catalog/catalog_thumbnail_smoke_test.dart` | Quick smoke test for thumbnail generation |
| `flows/cpu_fallback_gestures_test.dart` | Gesture handling when GPU is unavailable (CPU fallback) |
| `screenshots/full_screenshots_test.dart` | Generate full app screenshots for store listing |
| `screenshots/screenshots_test.dart` | Basic screenshot capture tests |
| `performance/shader_benchmark_test.dart` | GPU shader performance benchmarks |
| `performance/perf_smoke_test.dart` | Quick performance regression check |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `accessibility/` | Semantics and accessibility integration audits |
| `catalog/` | Catalog coverage, thumbnail smoke checks, and GPU thumbnail generation |
| `flows/` | End-to-end navigation, viewer, gesture, and critical journey tests |
| `helpers/` | Shared test helpers for integration widgets and gestures |
| `performance/` | Performance smoke checks and shader benchmarks |
| `rendering/` | Renderer correctness, GPU evidence, and shader pipeline diagnostics |
| `screenshots/` | Screenshot walkthroughs and generated store/backend captures |

## For AI Agents

### Working In This Directory
- Run: `flutter test integration_test/`
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

<!-- karpathy-guidelines:start -->
## Karpathy-Inspired Agent Guardrails

Source: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

These guardrails supplement the local instructions above. Local project, safety, and user-specific rules win on conflict.

Tradeoff: they bias toward caution over speed for non-trivial work; use judgment for obvious one-line fixes.

### Think Before Coding

- State assumptions before implementing; ask when uncertainty would change the solution.
- Surface multiple interpretations and tradeoffs instead of silently picking one.
- Push back when a simpler approach meets the goal.

### Simplicity First

- Build the minimum code that solves the requested problem.
- Avoid speculative features, single-use abstractions, and unnecessary configurability.
- If the solution is growing large, stop and simplify before continuing.

### Surgical Changes

- Touch only files and lines required by the request.
- Preserve existing style, comments, and nearby code unless the task requires changing them.
- Clean up only dead code introduced by your own change; mention unrelated dead code instead of deleting it.

### Goal-Driven Execution

- Convert the request into verifiable success criteria before editing.
- For multi-step work, state a short plan with a verification check for each step.
- Loop until the relevant tests, builds, or manual checks prove the goal is met.
<!-- karpathy-guidelines:end -->

<!-- karpathy-project-adjustment:start -->
## Project-Specific Karpathy Adjustment

This section localizes the Karpathy guardrails for `workspace-sidon/trebuchet-dynamics/flutter-fractal-forge/integration_test`. Source inspiration: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

- Project family: Sidon fractal/rendering and visual-app workspace.
- Local focus: GPU/fractal rendering, Flutter/Electron apps, shaders, accessibility, and measurable visual behavior.
- Stack cues: Flutter/Dart.
- Evidence to prefer: test output, analyzer/linter output, screenshot/pixel checks when relevant, shader compile logs, frame/performance metrics, and exact UI state text.
- Surgical boundary: do not rely on visual vibes; validate rendering numerically and describe results in screen-reader-friendly text.
- Stop and ask when: a visual requirement lacks measurable acceptance criteria or accessibility impact is uncertain.
<!-- karpathy-project-adjustment:end -->
