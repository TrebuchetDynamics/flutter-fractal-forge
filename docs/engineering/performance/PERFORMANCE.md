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
