# Runtime Performance Diagnostics

This document describes the implemented frame metrics and the available performance checks. It does not set a universal frame-rate promise for each fractal. Results depend on the device, GPU, driver, renderer, and view.

## Runtime metrics

`PerformanceService` records Flutter engine `FrameTiming` samples. Each sample includes total frame, build, and raster durations. The service marks a frame as dropped when its total duration exceeds `16.67 ms`.

The service retains at most 300 samples. It updates summary metrics every 30 samples and logs a snapshot every 60 samples. Its `isGood` label requires at least 55 FPS and fewer than 5% dropped frames. Its `isAcceptable` label requires at least 30 FPS and fewer than 15% dropped frames. These are diagnostic labels, not product acceptance criteria.

Memory metrics can be absent when the platform memory reader does not return a value. Do not treat an absent value as zero usage.

The `shaderCompilations` metric is currently set to zero by the service. It does not identify compilation stalls. The shader loader records a `compileMs` value and a cache flag in load logs. The value covers the loader's elapsed path; it is not an isolated GPU compilation measurement. The performance overlay does not connect those events to frame samples.

## Shader loading and caches

`FractalRenderer` loads programs through Flutter's `FragmentProgram.fromAsset` API. The loader shares concurrent loads for the same asset and keeps up to 256 `FragmentProgram` entries in an LRU cache. The renderer keeps a separate cache of up to 24 `FragmentShader` instances. The loader makes at most three attempts for a failed load before reporting an error.

These limits describe the current implementation. They do not prove a latency or memory improvement on every device. See [`SHADER_OPTIMIZATIONS.md`](SHADER_OPTIMIZATIONS.md) for shader-source and uniform-layout notes.

## Available checks

Run the service and cache tests for deterministic behavior:

```bash
flutter test test/services/performance_service_test.dart
flutter test test/shaders/shader_resource_cache_test.dart
```

Run the engine-backed smoke test on a configured device:

```bash
flutter test integration_test/performance/perf_smoke_test.dart -d linux
```

The smoke test collects Flutter frame timings for five seconds. It requires at least 60 samples and a P95 frame time below 80 ms. This is a broad regression check, not a per-fractal performance baseline. On another target, replace `linux` with an ID reported by `flutter devices`.

The shader benchmark is here:

```bash
flutter test integration_test/performance/shader_benchmark_test.dart -d linux
```

It attempts to load and draw four named legacy shader assets. It does not cover the full shader catalog or the production module renderer. Its `Ticker` samples are driven by `WidgetTester.pump(Duration(milliseconds: 16))`. They are test-pump intervals, not engine `FrameTiming` measurements. The 50 ms assertion does not validate GPU frame throughput. A failed asset load is logged and omitted from the assertion, so a passing result does not prove that all four assets loaded. Use the smoke test above or the Linux catalog audit for engine frame timings. The unit-test file `test/shaders/shader_benchmark_test.dart` is intentionally skipped and is not a benchmark entry point.

For per-module visual and frame-timing audits on Linux, use [`LINUX_FRACTAL_AUDIT.md`](LINUX_FRACTAL_AUDIT.md). Its retained reports use Mesa llvmpipe software rendering. They are not hardware-GPU performance results. Rerun performance candidates on the target GPU with the audit's documented settings before drawing performance conclusions.

## Browser HD export latency (#13)

The [production browser pilot](../../planning/visual-fidelity-audit-next.md#production-browser-qualification-13)
uses the real **Save image** action and a completed PNG download. The clock
starts immediately before Playwright clicks Save image and stops when
`download.saveAs` completes. This includes action dispatch, rendering, encoding,
browser download and local file completion, but not opening/configuring the
sheet or verifying the decoded PNG afterward. For each 3D selector set, three
warmups precede 15 completed 1280×720 exports. All inputs other than the palette
selector are identical within a module's pair. The median is the 8th sorted
sample and nearest-rank p95 is the 15th.

Observed on 2026-11-26, app source `01208be28c8fd9dc819ed17746779fab8447bf16`,
headless Chromium 147.0.7727.15 and SwiftShader software (shared host):

| Module | Selector | Timing pane (CSS px, DPR 1) | HD output | Median (ms) | p95 (ms) |
| --- | ---: | --- | --- | ---: | ---: |
| Mandelbulb | 0 (legacy) | 1280×900 | 1280×720 | 1600 | 1894 |
| Mandelbulb | 4 (sculptural) | 1280×900 | 1280×720 | 1512 | 3493 |
| Mandelbox | 2 (legacy) | 768×540 | 1280×720 | 3585 | 5512 |
| Mandelbox | 8 (sculptural) | 768×540 | 1280×720 | 5070 | 7085 |

Mandelbox uses the same aspect ratio in a smaller timing pane to reduce
software redraw cost while operating the export sheet. Do not compare the two
modules as a controlled performance experiment. Mandelbulb's lower median does
not establish a speedup; its upper tail increased in this run.

This is browser export-pipeline latency, not isolated shader/draw or GPU
readback time. The 15% native treatment budget does not apply. Do not infer an
FPS or hardware result from these measurements.
