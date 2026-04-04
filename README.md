# Flutter Fractal Forge

Flutter Fractal Forge is a Flutter fractal explorer built around a GPU-first renderer, a large searchable catalog, and a schema-driven viewer for 2D and 3D fractals.

## Current Scope

- 370 non-debug fractal modules in `ModuleRegistry`
- 350 escape-time catalog entries, 9 ray-marched 3D catalog entries, and 6 custom hand-built modules
- 199 checked-in catalog thumbnails in `assets/catalog_thumbs/`
- Grid/list catalog browsing with search, dimension filters, category chips, sort order, and persisted view preference
- Viewer controls for pan/zoom/rotation, presets, export, history, backend selection, and auto-explore
- PNG export and share flows
- English and Spanish localization
- Local-only privacy posture: no ads, no analytics, no camera/AR flow in the current release

## Architecture

```text
main.dart
  -> deferred startup splash
  -> FlutterFractalsApp
    -> onboarding or HomeScreen
      -> FractalCatalogScreen
      -> FractalViewerScreen
```

Key implementation points:

- `ModuleRegistry` builds the shipped catalog from declarative escape-time configs, custom modules, and the ray-marched 3D catalog.
- `FractalController` is the main state holder for module selection, params, view state, presets, and interaction history.
- `FractalCatalogScreen` builds presentation data from stable `catalogId`s and persists the user’s preferred grid/list mode.
- `FractalViewerScreen` composes the renderer, controls sheet, preset/export/history surfaces, backend policy, and debug/report helpers.

## Getting Started

```bash
flutter pub get
flutter run
```

Linux in this workspace is typically run with:

```bash
PATH="/home/xel/.local/bin:$PATH" /home/xel/flutter/bin/flutter run -d linux
```

## Test Commands

```bash
/home/xel/flutter/bin/flutter test
/home/xel/flutter/bin/flutter test integration_test/
```

Useful focused checks:

```bash
/home/xel/flutter/bin/flutter test test/catalog_id_integrity_test.dart
/home/xel/flutter/bin/flutter analyze
```

## Repo Guide

- `lib/`: application code
- `shaders/`: shader assets and diagnostics
- `fractals-library/`: reference catalog material
- `test/`: unit and widget tests
- `integration_test/`: integration flows and screenshot-oriented tests
- `store_listing/` and `store-listing/`: Play Store copy and upload assets

## Documentation Status

Current operational docs are:

- `README.md`
- `status.md`
- `TODO.md`
- `STORE_LISTING.md`
- `docs/privacy_policy.md`

Several older planning and research documents are intentionally kept for context. Files marked as archived should not be treated as the current product or release scope.
