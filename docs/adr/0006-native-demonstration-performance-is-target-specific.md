# Native Rust demonstration performance is target-specific

Accepted: the owner accepted Q2 of the Rust migration Grill With Docs round through
LGTM. Target 60 Hz for the native interactive architecture demonstration on defined
hardware and a defined scenario. Treat 120 Hz as an additional target on compatible
hardware, not a universal requirement for every fractal or precision level.

## Context

[Current diagnostics](../engineering/performance/PERFORMANCE.md) depend on device,
GPU, driver, renderer and view. Their 55/30 FPS labels and broad smoke-test limits
are not product acceptance for the Rust demonstration. The
[migration plan](../planning/refactor-plan.md#flutter-shell-and-rust-engine-migration)
requires a real pinch-to-Rust-to-wgpu-to-Flutter composition path, not successful
shader compilation or a nonblack screenshot.

## Considered Options

- Require 60/120 Hz universally across all modules, depth levels and devices.
- Bind the demonstration target to a declared hardware/scenario measurement, with
  60 Hz as the initial target and 120 Hz additional where supported.

## Consequences

Choose the second option. Before measuring, record target hardware, display refresh,
OS/driver/backend, source/build, module, parameters, viewport/DPR, zoom and input
trace, warmup, observation window and frame/latency measurement procedure. Define
the pass statistic and permitted stalls before the run; a favorable mean or Flutter
UI animation alone does not prove engine throughput. These remaining protocol
details are engineering work for the evidence-backed qualification plan, not
measurements or acceptance thresholds invented here.

Correctness, honest precision labels, no per-frame pixel transport through Dart,
session/revision safety and lifecycle requirements remain mandatory. This decision
does not weaken the native texture gate, make the existing smoke test a 60 Hz proof
or require 60 Hz during CPU precision refinement and export.

Use the standing Waydroid target for Android functional/lifecycle qualification.
Its results remain container evidence; they do not establish physical-device
performance or hardware GPU timing. Do not replace Waydroid with a demand for a
physical phone. Missing hardware timing remains an explicitly unmeasured claim,
not a reason to block independent offline implementation or to mark performance
passed. No hardware benchmark was run by this decision.

Term: [Native architecture demonstration](../engineering/GLOSSARY.md#native-architecture-demonstration).
