# Contributing to Flutter Fractal Forge

Thank you for your interest in contributing! This document provides guidelines and information for contributors.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Coding Standards](#coding-standards)
- [Submitting Changes](#submitting-changes)
- [Building Release Artifacts](#building-release-artifacts)
- [Adding New Fractals](#adding-new-fractals)
- [Reporting Bugs](#reporting-bugs)
- [Feature Requests](#feature-requests)

## Code of Conduct

Be respectful and inclusive. We welcome contributors of all experience levels and backgrounds.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/flutter-fractal-forge.git
   cd flutter-fractal-forge
   ```
3. **Add upstream remote:**
   ```bash
   git remote add upstream https://github.com/TrebuchetDynamics/flutter-fractal-forge.git
   ```
4. **Install dependencies:**
   ```bash
   flutter pub get
   ```

## Development Setup

### Prerequisites

- Flutter SDK matching the [repository toolchain pin](fdroid/flutter.version)
- Bundled Dart from that Flutter SDK; do not independently upgrade Dart
- IDE with Flutter support (VS Code or Android Studio recommended)
- Device/emulator for testing

For provisioned offline work, follow the [common offline setup](AGENTS.md#common-offline-integration-gate). Use its existing SDK/cache and process-local environment; install nothing and do not change a shared SDK.

### Running in Development

```bash
# Run with hot reload
flutter run

# Run specific platform
flutter run -d chrome
flutter run -d linux
flutter run -d android

# Run tests
flutter test

# Analyze code
flutter analyze
```

For the complete offline integration check, use the [common gate](docs/engineering/test-plan.md#common-offline-gate), not just the focused commands above. Execute its lockfile-enforced metadata preflight in each checkout/export; do not copy another checkout's `.dart_tool` binding. Device/browser qualification and publishing remain separate.

### IDE Configuration

**VS Code** (recommended):
- Install Flutter and Dart extensions
- Enable "Format on Save"
- Use the included `analysis_options.yaml`

**Android Studio**:
- Install Flutter and Dart plugins
- Enable auto-formatting on save

## Project Structure

```
lib/
├── core/                    # Core domain logic
│   ├── models/              # Data models (immutable, with Equatable)
│   ├── modules/             # Fractal module definitions
│   ├── services/            # Business services (export, storage)
│   └── theme/               # App theming
├── features/                # Feature modules (screens, widgets)
│   ├── catalog/             # Fractal browser
│   ├── controls/            # Parameter controls
│   ├── home/                # Home screen
│   ├── presets/             # Preset management
│   ├── renderer/            # Shader rendering
│   └── viewer/              # Full-screen viewer
├── l10n/                    # Localization (ARB files)
├── shared/                  # Shared utilities
└── main.dart                # Entry point

shaders/                     # GLSL fragment shaders
test/                        # Unit and widget tests
integration_test/            # Integration tests
```

## Coding Standards

### Dart Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter analyze` to check for issues
- Format code with `dart format .` before committing

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Classes | PascalCase | `FractalController` |
| Files | snake_case | `fractal_controller.dart` |
| Variables | camelCase | `currentZoom` |
| Constants | camelCase | `defaultIterations` |
| Private | leading underscore | `_internalState` |

### Documentation

Add **dartdoc comments** to all public APIs:

```dart
/// A controller that manages fractal rendering state.
///
/// This controller handles parameter updates, preset application,
/// and view transformations for the active fractal module.
///
/// Example usage:
/// ```dart
/// final controller = FractalController(registry);
/// controller.updateParam('iterations', 100);
/// controller.applyPreset(myPreset);
/// ```
class FractalController extends ChangeNotifier {
  /// Updates a single fractal parameter.
  ///
  /// The [id] must match a parameter defined in the current module.
  /// The [value] is automatically clamped to the parameter's valid range.
  void updateParam(String id, Object value) { ... }
}
```

### Immutability

Prefer immutable data models:

```dart
@immutable
class FractalPreset {
  final String id;
  final String name;
  // ...
  
  FractalPreset copyWith({String? id, String? name}) { ... }
}
```

### State Management

- Use `Provider` for dependency injection
- Use `ChangeNotifier` for mutable state that needs notifications
- Keep state scoped to feature when possible

## Submitting Changes

### Branch Naming

- `feature/description` — New features
- `fix/description` — Bug fixes
- `docs-*` — Documentation updates (for example, `docs-engineering` or `docs-planning`)
- `refactor/description` — Code refactoring

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add new Phoenix fractal module
fix: correct zoom clamping for 2D fractals
docs: update README with instructions
refactor: extract shader loading to service
test: add widget tests for preset sheet
```

### Pull Request Process

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/my-feature
   ```

2. **Make your changes** with clear, focused commits

3. **Ensure all tests pass:**
   ```bash
   flutter test
   flutter analyze
   ```

4. **Update documentation** if needed

5. **Push your branch:**
   ```bash
   git push origin feature/my-feature
   ```

6. **Open a Pull Request** with:
   - Clear description of changes
   - Screenshots/GIFs for UI changes
   - Link to related issues

7. **Address review feedback**

### PR Checklist

- [ ] Code follows style guidelines
- [ ] Tests added/updated as needed
- [ ] Documentation updated
- [ ] No analyzer warnings
- [ ] Localization strings added (if applicable)
- [ ] Tested on at least one platform

## Building Release Artifacts

Use Flutter's release targets for local artifacts:

```bash
flutter build apk --release
flutter build appbundle --release
flutter build web --release
flutter build linux --release
```

Equivalent targets exist for macOS, Windows, and iOS. Fourier Music was removed; no external audio player is required. [Fourier View and Fractal Uncertainty Lab](docs/research/fractal-uncertainty-and-fourier-mode.md) are numerical tools, separate from the silent [Camera looper](README.md#controls).

For a Google Play upload build:

1. Copy `android/key.properties.example` to `android/key.properties`.
2. Point `storeFile` to a private upload keystore, preferably outside the repository.
3. Never commit signing files, upload keystores, or `android/key.properties`.
4. Run `scripts/build-play-console.sh`.

## Adding New Fractals

A typical shader-backed addition should stay focused:

1. Add or update the `.frag` shader.
2. Register the asset under `flutter.shaders` in `pubspec.yaml`.
3. Add the module config or builder mapping.
4. Add a focused contract or renderer test.
5. Run a GPU thumbnail/render audit for visual changes.

The detailed steps below show where those pieces live.

### 1. Choose the Shader Contract

Add the `.frag` asset under `shaders/`. For a standard 2D escape-time module, follow the float-uniform order documented in [builders/escape_time/builder.dart](lib/core/modules/builders/escape_time/builder.dart): time, resolution, center, zoom, iterations, bailout, color scheme, transparent background, then extra numeric parameters. Match any palette sampler contract as well. A shader with only resolution/center/zoom uniforms is **not** compatible with this builder.

For a different layout, use a custom builder with its own `setUniforms` callback. Do not copy an unrelated shader's uniform offsets. Both paths still require asset registration in step 5.

### 2. Register a Standard Escape-Time Config (Path A)

Use this path when the standard uniform contract fits. Add one `EscapeTimeConfig` to the existing `escapeTimeCatalog` list in [lib/core/modules/builders/escape_time_catalog.dart](lib/core/modules/builders/escape_time_catalog.dart), or to its appropriate existing family/research part list already spread into that list. For an existing example, see [_coreEscapeTimeFamilyCatalog](lib/core/modules/builders/escape_time_catalog/families/core_escape_time_family.dart).

```dart
// In the existing escapeTimeCatalog list (illustrative new entry):
EscapeTimeConfig(
  id: 'my_fractal',
  name: 'My Fractal',
  displayName: (l10n) => l10n.moduleMyFractal,
  shaderAsset: 'shaders/my_fractal.frag',
  defaultIterations: 120,
  defaultBailout: 4.0,
),
```

The config type and `buildEscapeTimeModule` live in `builders/escape_time/builder.dart`. The structured `builders/escape_time/catalog.dart` import is only a compatibility facade; edit the canonical catalog/parts above. `buildEscapeTimeCatalogModules()` builds the configs and `ModuleRegistry._buildAll()` includes them automatically. No separate module file or registry insertion is needed for this path.

### 3. Register a Custom Builder (Path B, Alternative to A)

For custom parameters/uniforms or a non-escape-time system, create `lib/core/modules/fractals/my_fractal_module.dart` with a `FractalModule buildMyFractalModule()` function. Follow [phoenix_module.dart](lib/core/modules/fractals/phoenix_module.dart) for imports, parameters, `catalogPreset` defaults, localized name, shader asset and the actual `setUniforms` implementation. Replace the example's formula-specific parameters and uniform writes with your shader's contract; an empty callback is not a working renderer.

In [lib/core/modules/module_registry.dart](lib/core/modules/module_registry.dart), add the import alongside the other custom builders:

```dart
import 'fractals/my_fractal_module.dart';
```

Then insert the builder call in the **existing local `customModules` list inside `_buildAll()`**:

```dart
// One new element inside final customModules = <FractalModule>[ ... ];
buildMyFractalModule(),
```

The registry comments call this `_customModules`, but the current code names the local list `customModules`. Do not replace the `ModuleRegistry` constructor, lazy `modules` field, `_buildAll()` or its merge logic with a new hand-built list: that would drop the assembled catalog, ordering and diagnostics. Choose a unique stable ID and register it through only one path; duplicate IDs can be deduplicated or overridden rather than appearing as a second entry.

### 4. Add Localization

Update ARB files in `lib/l10n/`:

```json
{
  "moduleMyFractal": "My Fractal"
}
```

### 5. Register Shader Asset

Update `pubspec.yaml`:

```yaml
flutter:
  shaders:
    - shaders/my_fractal.frag
```

### 6. Verify Discovery and Rendering

Add a focused module contract test that resolves `ModuleRegistry().byId('my_fractal')` and checks its preset's `moduleId`, parameters and shader asset. This checks discovery for **either** registration path, not just the standalone builder. Retain the registry/ID checks in [catalog_id_integrity_test.dart](test/catalog/catalog_id_integrity_test.dart) and update expected counts deliberately when adding an identity.

Run focused tests and the [common offline gate](AGENTS.md#common-offline-integration-gate), then the GPU thumbnail/render audit for a visual change. A passing metadata test is not a rendered-shader or device result.

**If discovery fails:** `byId` throws `StateError: No element` for a missing ID. Check the spelling, the config's inclusion in `escapeTimeCatalog` or the custom builder's inclusion in `customModules`; do not replace the registry to make the lookup pass. If lookup succeeds but the render is wrong, compare the shader declarations with the standard builder's uniform layout or your custom `setUniforms`, and confirm `flutter.shaders` includes the asset before rerunning the render check.

## Reporting Bugs

When reporting bugs, please include:

1. **Flutter version** (`flutter --version`)
2. **Device/platform** being used
3. **Steps to reproduce** the issue
4. **Expected behavior** vs actual behavior
5. **Screenshots/logs** if applicable
6. **Minimal code sample** if possible

Use the bug report issue template when available.

## Feature Requests

For feature requests:

1. Check existing issues to avoid duplicates
2. Describe the use case clearly
3. Explain why this would benefit users
4. Include mockups/examples if relevant

---

## Questions?

- Open a GitHub issue for questions
- Tag maintainers for urgent matters

Thank you for contributing! 🙏
