# Renderer Backend Capability Matrix (2026-02-12)

## Verdict legend
- **PASS**: backend renders with sane output + progression checks.
- **PARTIAL**: backend works with limits or missing complete measurements.
- **FAIL**: backend unavailable or invalid output.

## Environments

| Environment | GPU | CPU fallback | Verdict | Reason |
|---|---|---|---|---|
| Android emulator (`ranchu`/`emulation`, `sdk_gphone64_x86_64`) | Partial | Pass | **PASS (overall)** | Deterministic policy routes emulator to CPU (`android_emulator`) for stable output; GPU measurable via probe path but not default.
| Real Android device | Unavailable | Unavailable | **FAIL (not testable in this run)** | No physical device connected in this session (`adb devices` only listed emulator).
| Web (Chrome build target) | Unknown | Unknown | **PARTIAL** | `flutter build web` succeeded; runtime backend probe not executed in browser session in this run.

## Deterministic backend policy

Priority order implemented:
1. `forced_by_flag` (`FORCE_CPU_FALLBACK=true`)
2. `manual_toggle`
3. `module_unsupported` (non-2D)
4. `android_emulator`
5. `gpu_health_check_failed`
6. `deep_zoom_precision`
7. GPU healthy path (`none`)

Policy output is exposed in:
- logs (`[renderer] backend_decision backend=... reason=...`)
- viewer status text (release-safe wording)
- GPU debug JSON report (`backendReasonCode`)

## Visual correctness checks

Implemented deterministic checks in `render_validation.dart`:
- center pixel non-black
- non-black histogram ratio sanity
- frame progression across frame pair
- iteration delta visibility across frame pair

Coverage:
- CPU path: validated each CPU render cycle (debug logs)
- GPU path: measured from live `RenderRepaintBoundary` frame pair probe

## Release-safe UX behavior

### Kept
- Debug controls remain in debug builds (`kDebugMode` overlays + indicators).

### Production-safe changes
- Removed confusing internal labels from always-on renderer surfaces.
- Added concise fallback copy: "Using stable renderer..." / "Stable renderer active".
- Renderer indicator ribbon now debug-only.

## Evidence references
- Logs directory: `agent_test_logs/release_pipeline_20260212/`
- Screenshots directory: `agent_test_logs/release_pipeline_20260212/screens/`
