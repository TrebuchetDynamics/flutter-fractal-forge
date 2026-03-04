# Contributing to Flutter Fractal Forge

Thank you for your interest in contributing! This document provides guidelines and information for contributors.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Coding Standards](#coding-standards)
- [Submitting Changes](#submitting-changes)
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
   git remote add upstream https://github.com/ORIGINAL_OWNER/flutter-fractal-forge.git
   ```
4. **Install dependencies:**
   ```bash
   flutter pub get
   ```

## Development Setup

### Prerequisites

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- IDE with Flutter support (VS Code or Android Studio recommended)
- Device/emulator for testing

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
- `docs/description` — Documentation updates
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

## Adding New Fractals

To add a new fractal type:

### 1. Create the Shader

Add a new fragment shader in `shaders/`:

```glsl
// shaders/my_fractal.frag
#version 320 es
precision highp float;

uniform float uTime;
uniform vec2 uResolution;
// Add your uniforms...

out vec4 fragColor;

void main() {
    // Your fractal algorithm
}
```

### 2. Create the Module

Add a new module file in `lib/core/modules/`:

```dart
// lib/core/modules/my_fractal_module.dart
import 'package:flutter_fractals/core/modules/fractal_module.dart';
// ... other imports

FractalModule buildMyFractalModule() {
  final parameters = [
    FractalParameter(
      id: 'iterations',
      label: (l10n) => l10n.paramIterations,
      type: FractalParamType.integer,
      min: 10,
      max: 200,
      step: 1,
      defaultValue: 50,
    ),
    // ... more parameters
  ];

  final defaultPreset = FractalPreset(
    id: 'my-fractal-default',
    moduleId: 'my_fractal',
    name: 'Default',
    params: {'iterations': 50},
    view: FractalViewState.initial(),
    createdAt: DateTime.now(),
    isBuiltIn: true,
  );

  return FractalModule(
    id: 'my_fractal',
    displayName: (l10n) => l10n.moduleMyFractal,
    dimension: FractalDimension.twoD,
    shaderAsset: 'shaders/my_fractal.frag',
    parameters: parameters,
    defaultPreset: defaultPreset,
    builtInPresets: [defaultPreset],
    setUniforms: (shader, state, size, time) {
      // Set shader uniforms
    },
  );
}
```

### 3. Register the Module

Update `lib/core/modules/module_registry.dart`:

```dart
import 'my_fractal_module.dart';

class ModuleRegistry {
  final List<FractalModule> modules;

  ModuleRegistry() : modules = [
    // ... existing modules
    buildMyFractalModule(),
  ];
}
```

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

### 6. Add Tests

Create tests for your module:

```dart
// test/my_fractal_module_test.dart
void main() {
  test('my fractal module has valid default preset', () {
    final module = buildMyFractalModule();
    expect(module.defaultPreset.moduleId, equals('my_fractal'));
  });
}
```

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
