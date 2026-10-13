# System specification

## Scope and status

This document describes the current Flutter application architecture. Product intent is in [`../../PRD.md`](../../PRD.md); historical and planned work remains identified in [`../../TODO.md`](../../TODO.md).

## Components and data flow

- `lib/main.dart` initializes the application and Provider dependencies.
- `ModuleRegistry` assembles `FractalModule` instances from declarative escape-time configs and dedicated builders.
- The catalog opens a selected module in `FractalViewerScreen`. The viewer's `FractalController` owns current module parameters and view state.
- Renderer policy selects a supported GPU path, an extended-precision GPU path, or CPU precision where a native CPU formula is available. GPU shaders are declared as assets in `pubspec.yaml`.
- Viewer features use the same controller state for controls, presets, history, export, wallpaper, and sharing.

## Rendering interface

Each module supplies a stable ID, shader asset, parameter definitions, presets, and a uniform setter. Shader uniform order and types are an interface contract between the module builder and its GLSL shader. Register shader assets under `flutter.shaders` in `pubspec.yaml` and cover module/shader compatibility with tests.

Rendering follows the capability policy in `lib/features/renderer/policy/`. Do not label a synthetic fallback as CPU precision. CPU refinement is available only when a native CPU formula supports the module. The renderer uses asynchronous Flutter shader/GPU operations and tiled CPU rendering; long-running CPU work must remain off the UI thread and support cancellation where the existing renderer contract provides it.

## State and persistence

Provider supplies application dependencies. `ChangeNotifier`-based controllers expose mutable view state to widgets. Shared preferences and the project's storage services persist supported user settings and presets. Module IDs remain language-independent; localized display names are presentation values, not persistence keys.

## Failure behavior

- Shader loading or compilation failures must remain visible through renderer diagnostics or the UI's loading/error state; do not silently report a successful render.
- GPU health and precision policy can route eligible modules to a supported fallback. Unsupported precision must remain explicitly unavailable rather than implying correctness.
- Export, share, wallpaper, and platform integrations depend on the target platform. Their failure must not corrupt the viewer's current fractal state.
- Platform features and browser parity vary. See [`rendering/renderer_backend_matrix.md`](rendering/renderer_backend_matrix.md).

## Security and compatibility

The repository's privacy policy states that fractal processing is local. Do not add analytics, account, cloud-sync, or camera-data collection without approved product scope. Keep signing material and service credentials outside source control. Android, desktop, and web behavior are separately constrained by Flutter plugins and renderer support; consult the backend matrix and platform build configuration before claiming parity.

## Interfaces not present

The app has no repository-owned HTTP API, database migration interface, or server deployment contract. The web preview is a static Flutter build published through the separately documented deployment procedure. No OpenAPI document applies.

## Gaussian moat walking visualization

### MAP implementation and bounded contract

`GAUSS-MOAT-01-MAP` reuses the existing `gaussian_prime_lattice` catalog/viewer identity. Explore retains its shader, camera, parameters and presets; Walk opens an exact finite Dart map with a separate transient camera. Selection and Set start are map controls, not implemented walking, path or component search.

The accepted MAP requirements come from admitted planning base `91396ae4736d7d84192f835ce1c531e52380b708`; implementation and signed-coordinate corrections were independently approved at `6e671957a30ea7b44a80f8cfc4a8d5d31c73dd73`. This bounded reconciliation carries only MAP requirements and qualification boundaries, not the wider prerequisite documentation or its unrelated inventory changes.

- Compute the square `[-B,B] × [-B,B]`, default `B=32`, hard cap `B=128`. Validate integer, finite and in-range input before allocation. Off-axis primality uses the ordinary-prime norm `a²+b²`; on either axis the absolute nonzero coordinate must be prime and congruent to `3 mod 4`. Origin and units are excluded; all signs and conjugates are retained. Outside the computed square is explicitly uncomputed, not composite.
- `GaussianPrimeMap` uses a sieve through `2B²` and dense membership: at the cap, at most 66,049 positions and norm 32,768. Generation yields after at most 1,024 probes or 8ms elapsed; cancellation discards partial results. The viewer retains one active generation and one replaceable pending bound. These are bounded-work contracts, not device latency or memory measurements.
- Picking and painting share `GaussianMapTransform`, using the actual plot pane after pan, zoom and resize. Drag/wheel navigation does not select. Coordinate controls reject values outside ±1,000,000 using signed comparisons, including native integer extremes, without changing root/candidate. Native keyboard controls preserve focus; statuses and EN/ES labels supplement color and shapes.
- Controls fit widths 320/768/1024/1440 and text scales 1/2. Wide layouts reserve a 300px controls panel; narrow/enlarged-text layouts use the existing HUD. Apply-only domain and math details use `AppBottomSheet`; action targets are at least 48 logical pixels. Explore-only effects/compare/Fourier are unavailable with an explanation in Walk.
- Exact points, domain outline, root square and candidate ring are painted inside the export capture boundary. Export is unavailable while generation is incomplete. Host raster coverage is not proof of physical storage, download/share or a platform-exported artifact.

See [MAP host qualification](test-plan.md#map-host-qualification). Walking/component/growth/quaternion features and live Linux/Android/browser, native screen-reader, high-contrast, device performance/storage and Lean qualification remain separate and unproved by this local MAP slice.
