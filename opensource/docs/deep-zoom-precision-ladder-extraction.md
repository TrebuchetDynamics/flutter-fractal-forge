# Deep-Zoom Precision Ladder Extraction

Status: first Reference Corpus mining lane. This note distills deep-zoom patterns that can inform Flutter Fractal Forge's `Precision Ladder` without treating upstream code as app source.

## Current app seam

Flutter Fractal Forge already has a deep-zoom routing seam:

- `lib/features/renderer/policy/precision_ladder_policy.dart` selects `gpuFloat`, `gpuDoubleFloat`, `gpuPerturbation`, or `cpu`.
- `lib/features/renderer/policy/deep_zoom_precision_policy.dart` owns zoom thresholds and hysteresis inputs.
- `lib/features/renderer/cpu/cpu_render_isolate.dart` is the current CPU Precision execution seam.
- `test/deep_zoom_precision_policy_test.dart` checks threshold and routing behavior.

## Extracted patterns

1. **Reference-orbit split is the core deep-zoom shape.** Mature deep-zoom renderers compute one high-precision reference orbit, then render nearby pixels with lower-precision deltas. This maps cleanly to our existing split between `CPU Precision` and `Extended GPU Preview`.
2. **Glitch detection is required before calling perturbation exact.** KF2, DeepDrill, and rust-fractal all treat perturbation as a multi-round process: detect suspect pixels, choose/rebase a new reference, and retry. Our current `gpuPerturbation` tier should remain `extendedGpuPreview` until we have a refine path with glitch correction.
3. **Series/linear approximation is a second-stage optimization, not first slice.** It reduces per-pixel iteration work after the reference-orbit model exists. Implementing it before reference-orbit storage and glitch bookkeeping would make the app harder to validate.
4. **Extreme GPU high-precision arithmetic is research-grade.** FractalShark's GPU reference-orbit path is promising but NVIDIA/CUDA-specific and only pays off at very high precision. It is not a near-term Flutter shader path.
5. **Location/config files are useful validation fixtures.** rust-fractal and KF2-style saved locations can inspire tracked deep-zoom fixtures: center, zoom, max iterations, palette/reference metadata, and expected route.

## Recommended first implementation slice

Build a CPU-side reference-orbit model and tests before changing shaders:

- Define a small internal `ReferenceOrbit` data shape for Mandelbrot-family CPU Precision experiments.
- Generate a high-precision or high-enough baseline orbit for one reference point in an isolate-friendly pipeline.
- Add tests around routing and glitch bookkeeping terminology before adding GPU perturbation data transfer.
- Keep `gpuPerturbation` user copy as preview-grade until glitch correction and CPU refine are measurable.

## Provenance records

### KF2 / Kalles Fraktaler lineage

- Source repo: https://github.com/smurfix/kf2
- Source path: `README.md`; `HACKING.md`; `cl/floatexp_pre.cl`; `cl/double_pre.cl`
- Source commit: `a5ec69a7b94a0a648e4548f5934cf3fd2d3298a4`
- License: AGPL-3.0 via `LICENSE.md`
- Idea summary: Perturbation plus series approximation from a high-precision reference; glitch/rebase loop is part of correctness, not optional polish.
- Reuse mode: adapted idea only
- Target app area: `lib/features/renderer/policy/precision_ladder_policy.dart`; `lib/features/renderer/cpu/cpu_render_isolate.dart`; future CPU reference-orbit tests.
- Validation signal: policy unit tests plus a deterministic deep-zoom fixture that marks glitched pixels as unresolved/refine-required.

### FractalShark

- Source repo: https://github.com/mattsaccount364/FractalShark
- Source path: `README.md`
- Source commit: `5c599e0c8c75bc020c0235fd9a926d328bacf1c5`
- License: GPL-3.0 via `LICENSE`
- Idea summary: Experimental CUDA reference-orbit acceleration, linear approximation variants, float+exponent numeric types, reference orbit compression, and periodic feature finding.
- Reuse mode: adapted idea only
- Target app area: long-term Precision Ladder roadmap; not current Flutter shader implementation.
- Validation signal: defer until app has CPU reference-orbit fixtures; then compare memory/performance benefits of compressed orbit storage.

### Mandelbrot Voyage 2

- Source repo: https://github.com/Yilmaz4/MV2
- Source path: `README.md`
- Source commit: `d13ac77b6b8cfd440957698c4b736beb9965b052`
- License: GPL-3.0 via `LICENSE.txt`
- Idea summary: GPU-side Mandelbrot perturbation and native `dvec2` custom-equation UX, with explicit limitations for non-Mandelbrot and non-integer powers.
- Reuse mode: adapted idea only
- Target app area: `PrecisionLadderRenderPath.gpuPerturbation`; shader capability labeling; custom formula constraints.
- Validation signal: route-copy tests that keep perturbation labeled as preview-grade for unsupported formulas.

### DeepDrill

- Source repo: https://github.com/dirkwhoffmann/DeepDrill
- Source path: `docs/docs/Theory/Perturbation.html`; `docs/docs/Overview/About.html`
- Source commit: `2b143c34b653ffd3d45c0a468db0ee8105edeb80`
- License: GPL-3.0 via `LICENSE`
- Idea summary: Clear explanation of reference orbit, delta orbit, Pauldelbrot glitch criterion, and multi-round recomputation.
- Reuse mode: adapted idea only
- Target app area: Precision Ladder docs, CPU refine flow, and user-facing honesty copy.
- Validation signal: tests assert perturbation/refine state names and do not describe the preview path as exact.

### rust-fractal-core

- Source repo: https://github.com/rust-fractal/rust-fractal-core
- Source path: `README.md`; `benchmarks/4096.toml`; `benchmarks/512.toml`
- Source commit: `6af4724c0c613ae26bddce9db953bc92da302922`
- License: GPL-3.0 via `LICENSE`
- Idea summary: Perturbation, automatic glitch correction, series approximation, probe-based skip selection, Rayon loops, and location/options files.
- Reuse mode: adapted idea only
- Target app area: CPU Precision fixture format; future isolate-side reference-orbit experiment.
- Validation signal: tracked location fixture with expected route, iteration budget, and refine/glitch status.

### rust-fractal-gui

- Source repo: https://github.com/rust-fractal/rust-fractal-gui
- Source path: `README.md`; `src/render_thread.rs`
- Source commit: `c6f2e8c87d0aef042abf2da46eecc5d83b80efa7`
- License: GPL-3.0 via `LICENSE`
- Idea summary: GUI progress model around glitched-pixel work, render thread communication, and deep-zoom navigation shortcuts.
- Reuse mode: adapted idea only
- Target app area: viewer status/progress semantics for CPU Precision refine.
- Validation signal: widget/status tests for `Precision pending`, `Deep GPU`, and `Precision` copy.

## First slice result

Implemented a CPU-only Mandelbrot `Reference Orbit Fixture` in `lib/features/renderer/cpu/reference_orbit.dart` with behavior tests in `test/reference_orbit_test.dart`. This validates replay/refine bookkeeping only; it is not user-visible `CPU Precision` until orbit generation uses the exact-intended deep-zoom path.

Validation receipts:

- `/home/xel/flutter/bin/flutter test test/reference_orbit_test.dart test/deep_zoom_precision_policy_test.dart`
- `/home/xel/flutter/bin/flutter analyze lib/features/renderer/cpu/reference_orbit.dart test/reference_orbit_test.dart`

## Next exactness prototype decision

Start with pure Dart `BigInt`/fixed-point reference-orbit generation rather than GMP/MPFR FFI. See `docs/adr/0002-start-with-pure-dart-fixed-point-reference-orbits.md`.

## First fixed-point slice result

Implemented `MandelbrotFixedPointReferenceOrbit.generate(...)` with `BigInt` fixed-point samples and a shallow equivalence test against the double reference orbit. This proves arithmetic/scaling at ordinary coordinates before adding deep-zoom fixtures.

Validation receipts:

- `/home/xel/flutter/bin/flutter test test/reference_orbit_test.dart test/deep_zoom_precision_policy_test.dart`
- `/home/xel/flutter/bin/flutter analyze lib/features/renderer/cpu/reference_orbit.dart test/reference_orbit_test.dart`

## Decimal coordinate input result

Implemented `MandelbrotFixedPointReferenceOrbit.generateFromDecimalStrings(...)` so fixed-point coordinates can preserve decimal precision that would be rounded away by `double` inputs.

Validation receipts:

- `/home/xel/flutter/bin/flutter test test/reference_orbit_test.dart test/deep_zoom_precision_policy_test.dart`
- `/home/xel/flutter/bin/flutter analyze lib/features/renderer/cpu/reference_orbit.dart test/reference_orbit_test.dart`

## Double-collapse fixture result

Added a regression fixture proving two decimal centers that collapse to the same `double` remain distinct in fixed-point form and in the first reference-orbit sample.

Validation receipts:

- `/home/xel/flutter/bin/flutter test test/reference_orbit_test.dart test/deep_zoom_precision_policy_test.dart`
- `/home/xel/flutter/bin/flutter analyze lib/features/renderer/cpu/reference_orbit.dart test/reference_orbit_test.dart`

## Not selected for first slice

- Direct shader/code reuse from GPL/AGPL projects.
- CUDA or native GPU high-precision reference-orbit arithmetic.
- Native GMP/MPFR FFI before the pure Dart exactness model is validated.
- Series approximation before a reference-orbit + glitch bookkeeping seam exists.
- Broad catalog/flame/visual-polish mining before Precision Ladder behavior is measurable.
