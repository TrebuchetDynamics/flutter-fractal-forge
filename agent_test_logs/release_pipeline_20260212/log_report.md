# Renderer log report (2026-02-12)

## Backend decisions observed
Source: `flutter test` console output (viewer/widget runs)

- `[renderer] backend_decision backend=gpu reason=none module=mandelbrot detail=healthy_gpu_target`
- `[renderer] backend_decision backend=cpu reason=module_unsupported module=mandelbulb detail=cpu_path_only_for_unsupported_gpu_module`
- Multiple modules in test run resolved to `backend=gpu reason=none`.

## First-frame timing
- **GPU first-frame timing log line is instrumented** (`[renderer] first_frame_ms=... backend=gpu` in `fractal_renderer.dart`).
- **Measured value in this session:** unavailable (runtime `flutter run` attach did not complete before timeout).

## Render-check instrumentation
- CPU path logs (`[renderer] render_check backend=cpu ...`) are emitted during CPU render in debug mode.
- GPU path render-check summary logs (`[renderer] render_check backend=gpu ...`) are emitted by viewer health probe.

## Emulator profile
See `device_props.txt`:
- `ro.hardware.egl=emulation`
- `ro.hardware.vulkan=ranchu`
- model=`sdk_gphone64_x86_64`
