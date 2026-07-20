# Fractal Forge

<p align="center">
  <img src="assets/readme/hero.svg" width="100%" alt="Fractal Forge, a GPU-first studio for exploring mathematical worlds">
</p>

<p align="center">
  <a href="https://github.com/TrebuchetDynamics/flutter-fractal-forge/actions/workflows/ci.yml"><img src="https://github.com/TrebuchetDynamics/flutter-fractal-forge/actions/workflows/ci.yml/badge.svg" alt="CI status"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter" alt="Flutter 3.x"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart" alt="Dart 3.x"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-7C4DFF.svg" alt="Apache 2.0 license"></a>
</p>

<p align="center">
  <strong><a href="https://fractal.trebuchetdynamics.com">Open the web preview</a></strong>
  &nbsp;·&nbsp;
  <strong><a href="https://play.google.com/store/apps/details?id=com.trebuchetdynamics.fractal.forge">Get the Android app</a></strong>
  &nbsp;·&nbsp;
  <a href="#run-it-locally">Build locally</a>
</p>

Fractal Forge is an open-source Flutter explorer for mathematical systems and generative art. Browse **977 production fractals**, tune parameters in real time, move through deep-zoom render paths, and export the views worth keeping.

## See it in motion

<p align="center">
  <a href="https://fractal.trebuchetdynamics.com"><img src="docs/assets/launch/web_preview_loop.gif" width="760" alt="Browser preview moving from the Fractal Forge catalog into an interactive viewer"></a>
</p>

<p align="center">
  <img src="assets/readme/catalog-grid.webp" width="100%" alt="A grid of colorful Fractal Forge catalog renders from several mathematical families">
</p>

> The loop and catalog grid are browser smoke evidence, not a claim of full web/app parity. Export, sharing, CPU precision, and hardware GPU behavior are most complete in the installable app; see the [renderer backend matrix](docs/engineering/rendering/renderer_backend_matrix.md).

## What makes it useful

- **Broad mathematical range** — 977 production fractals across escape-time formulas, root-finding basins, strange attractors, IFS, cellular systems, tilings, space-filling curves, and ray-marched 3D forms.
- **GPU-first interaction** — Flutter fragment shaders keep ordinary exploration responsive, with deeper preview and CPU paths where the module supports them.
- **A real creative toolset** — presets, randomizer, looper, auto-explore, dual Mandelbrot/Julia viewing, wallpaper tools, sharing, and Fractal Music experiments.
- **Color as a first-class control** — 60+ color schemes plus smooth coloring, orbit traps, distance estimation, stripe and curvature averaging, and normal-map relief.
- **Private by design** — no ads, tracking, account requirement, or data collection.
- **Accessible controls** — high contrast, reduced motion, screen-reader labels, and configurable touch targets.

## Explore the catalog

| Family | Examples |
| --- | --- |
| Escape-time | Mandelbrot, Julia, Burning Ship, Tricorn, Celtic, Buffalo, Nova, Phoenix, Lyapunov |
| Root finding | Newton, Halley, Householder, Schroeder, Traub–Ostrowski, Noor Newton |
| Attractors | Clifford, Peter de Jong, Lorenz, Rössler, Aizawa, Dadras, Sprott, Svensson |
| IFS and geometry | Sierpiński, Koch, Barnsley Fern, Hilbert, Peano, Gosper, circle inversion |
| Cellular and number systems | Wolfram rules, Life-like families, Langton systems, Wireworld, Farey and Ulam views |
| 3D and hypercomplex | Mandelbulb, Mandelbox, pseudo-Kleinian, quaternion Julia, KIFS |

The catalog counts stable renderable identities—not palettes, camera angles, presets, or thumbnails as separate fractals.

## From formula to image

<p align="center">
  <img src="assets/readme/rendering-flow.svg" width="100%" alt="Browse, tune, render through the precision ladder, then export a fractal image">
</p>

The renderer keeps exploration, history, export, wallpaper, looper, and audio tools on the same view state instead of forking the formula state for each feature.

### Precision ladder

| Tier | Method | Intended use |
| --- | --- | --- |
| 1 | Realtime GPU | Standard interactive pan, zoom, and parameter changes |
| 2 | Extended GPU preview | Deeper double-float or perturbation-backed preview for supported modules |
| 3 | CPU Precision | Slower exact-intended refinement for modules with a native CPU formula |

The ladder is capability-based. An unsupported module is not labeled “CPU Precision” merely because a synthetic fallback can draw something.

## Try it

### Browser preview

Open **[fractal.trebuchetdynamics.com](https://fractal.trebuchetdynamics.com)** in a modern WebGL 2.0 browser.

1. Pick a card from the catalog.
2. Drag to move; pinch or scroll to zoom.
3. Open controls to change iterations, palette, formula-specific parameters, or a preset.
4. Use the installable app when you need the fullest export, sharing, wallpaper, or precision behavior.

### Android

Install **[Fractal Forge from Google Play](https://play.google.com/store/apps/details?id=com.trebuchetdynamics.fractal.forge)** for the primary mobile experience.

## Run it locally

### Prerequisites

- Flutter SDK 3.x ([installation guide](https://docs.flutter.dev/get-started/install))
- Dart 3.x, included with Flutter
- A GPU or emulator with shader support; OpenGL ES 3.0+ is recommended

```bash
git clone https://github.com/TrebuchetDynamics/flutter-fractal-forge.git
cd flutter-fractal-forge
flutter pub get
flutter run -d chrome
```

Choose another target with:

```bash
flutter devices
flutter run -d linux     # or android, macos, windows, ios
```

Chrome and Android are the most useful first targets when diagnosing device-specific shader behavior.

## Controls

| Gesture | 2D fractals | 3D fractals |
| --- | --- | --- |
| Drag | Pan | Rotate |
| Pinch / scroll | Zoom | Zoom |
| Double tap | Reset view | Reset view |
| Long press | Set the Julia seed in the dual viewer | Not used |

Common controls include iterations, bailout, power, color scheme, Julia seed, orbit traps, rendering technique, and family-specific coefficients.

## Platform support

| Platform | Status | Notes |
| --- | --- | --- |
| Android | Primary | Maintained Google Play build path |
| Web | Preview | JavaScript/WebGL 2.0; not full app parity |
| Linux, macOS, Windows | Development targets | Shader support depends on GPU and driver behavior |
| iOS | Build target | Requires Apple signing and Metal-backed Flutter rendering |

## Build release artifacts

```bash
flutter build apk --release
flutter build appbundle --release
flutter build web --release
flutter build linux --release
```

For a Google Play upload build:

1. Copy `android/key.properties.example` to `android/key.properties`.
2. Point `storeFile` to a private upload keystore, preferably outside the repository.
3. Never commit signing files or `android/key.properties`.
4. Run `scripts/build-play-console.sh`.

Equivalent Flutter build targets exist for macOS, Windows, and iOS. Linux Fractal Music uses `paplay` or `aplay` when available.

## Architecture

```text
main.dart
  └─ app shell + Provider services
      └─ HomeScreen
          ├─ CatalogRepository → ModuleRegistry → FractalModule
          └─ FractalViewerScreen
              ├─ GPU / extended preview / CPU precision renderers
              ├─ controls + presets + history + looper
              └─ export + wallpaper + share + Fractal Music
```

```text
lib/
├── app/              app composition and startup
├── core/             models, controllers, modules, services, theme
├── features/         catalog, viewer, renderer, controls, export, looper
├── l10n/             generated localization output
├── shared/           cross-feature widgets and utilities
└── main.dart         entry point and compatibility facade

shaders/              Flutter GLSL fragment shaders
integration_test/     device and GPU rendering flows
test/                 unit, widget, contract, and golden tests
```

`ModuleRegistry` assembles the catalog from declarative configs, shared catalogs, custom builders, and debug-only diagnostics. Every viewer feature consumes the selected module and the same controller state.

## Testing

```bash
flutter analyze
flutter test
flutter test integration_test/   # requires a device or emulator
```

Useful focused lanes:

```bash
flutter test test/features/renderer/
flutter test test/catalog/
flutter test integration_test/flows/critical_journey_test.dart
```

See [`test/README.md`](test/README.md) for the fast safety lane and test conventions.

## Shader development

Shaders live in [`shaders/`](shaders/) and must be declared under `flutter.shaders` in [`pubspec.yaml`](pubspec.yaml).

A typical addition is deliberately small:

1. Add or update the `.frag` shader.
2. Register the asset in `pubspec.yaml`.
3. Add the module config or builder mapping.
4. Add a focused contract or renderer test.
5. Run a GPU thumbnail/render audit for visual changes.

```glsl
#include <flutter/runtime_effect.glsl>

precision highp float;
uniform vec2 uResolution;
uniform vec2 uCenter;
uniform float uZoom;
out vec4 fragColor;

void main() {
  vec2 uv = (FlutterFragCoord().xy - 0.5 * uResolution) / uResolution.y;
  fragColor = vec4(uv * 0.5 + 0.5, 0.2, 1.0);
}
```

## Project references

- [Renderer backend matrix](docs/engineering/rendering/renderer_backend_matrix.md)
- [Performance notes](docs/engineering/performance/PERFORMANCE.md)
- [Shader optimization notes](docs/engineering/performance/SHADER_OPTIMIZATIONS.md)
- [Formula coverage limitation](docs/engineering/rendering/formula_coverage_limitation.md)
- [Launch ladder](docs/planning/LAUNCH_LADDER.md)
- [Contributing guide](CONTRIBUTING.md)
- [Security policy](SECURITY.md)
- [Changelog](CHANGELOG.md)

## Contributing

Contributions are welcome. Good first areas include thumbnail quality, presets, shader correctness, web-preview QA, accessibility checks, tests, and documentation. Read [`CONTRIBUTING.md`](CONTRIBUTING.md) before opening a pull request.

## License

Apache License 2.0. See [`LICENSE`](LICENSE).

## Acknowledgments

Built with [Flutter](https://flutter.dev). Shader and fractal techniques are informed by the wider mathematical visualization community, including the educational work of [Inigo Quilez](https://iquilezles.org/).
