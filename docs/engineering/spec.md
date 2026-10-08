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
