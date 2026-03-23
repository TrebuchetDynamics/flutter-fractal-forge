# AI Development Rules - Flutter Fractal Forge

## Project Overview

This document defines the rules and patterns for AI agents working on Flutter Fractal Forge.

- **Type**: Flutter mobile application
- **Language**: Dart 3.0+
- **State Management**: Provider + ChangeNotifier
- **Rendering**: GLSL fragment shaders via Flutter FragmentProgram API
- **Architecture**: Clean Architecture (core/features separation)

---

## Build & Run

```bash
# Linux
PATH="/home/xel/.local/bin:$PATH" /home/xel/flutter/bin/flutter run -d linux

# Run tests
/home/xel/flutter/bin/flutter test

# Integration tests
/home/xel/flutter/bin/flutter test integration_test/
```

**Note**: Requires `lld` linker workaround via shell script at `~/.local/bin/clang++`

---

## Code Standards

### Formatting
- Use `flutter format` before commits
- Follow `analysis_options.yaml` rules
- No type suppression (`as any`, `@ts-ignore`, `@ts-expect-error`)

### Naming Conventions
- **Classes**: PascalCase (`FractalRenderer`)
- **Methods**: camelCase (`setUniforms`)
- **Constants**: SCREAMING_SNAKE_CASE
- **Files**: snake_case (`fractal_module.dart`)

### Architecture Rules

1. **Core layer** (`lib/core/`): Business logic, models, services, modules
2. **Features layer** (`lib/features/`): UI components, screens
3. **No cross-feature imports** without explicit service layer

### State Management

- Use `ChangeNotifier` with `Provider` for dependency injection
- Primary state holder: `FractalController`
- One controller per viewer tab

---

## Module System

### Creating a New Fractal Module

1. Create module in `lib/core/modules/`
2. Extend `FractalModule` base class
3. Register in `module_registry.dart`

```dart
class MyFractalModule extends FractalModule {
  @override
  String get id => 'my_fractal';
  
  @override
  String get shaderPath => 'shaders/my_fractal_gpu.frag';
  
  @override
  List<FractalParameter> get parameters => [...];
  
  @override
  void setUniforms(FragmentProgram program, FractalParams params) {
    // Set GLSL uniforms here
  }
}
```

### Shader Requirements

- All shaders must be registered in `pubspec.yaml` under `flutter.shaders`
- Use GLSL ES 3.0 syntax (`#version 320 es`)
- Uniforms must match Dart parameter types

---

## Common Gotchas

1. **Type promotion**: Class fields typed as `Object` do NOT get type-promoted. Assign to local variable first.

2. **Image package v4.x API**:
   - Use `compositeImage` (NOT `copyInto`)
   - Use frame list for GIF

3. **Environment variables for debugging**:
   - `SAFE_MODE`: Enable safe mode
   - `BOOT_STEP`: Incremental debugging steps

---

## Testing Requirements

- Unit tests: `flutter test`
- Widget tests: Use `pumpWidget` with mock stores/services
- Integration tests: `flutter test integration_test/`

---

## Accessibility

- Follow WCAG AAA guidelines
- Use `AccessibilityService` for labels
- Support `prefers-reduced-motion`

---

## Git Workflow

1. Create branch from `main` or `develop`
2. Make changes with conventional commits
3. Run tests before PR
4. PR to `main` for release, `develop` for features

---

## Dependencies

Keep minimal. Only add new packages when absolutely necessary.

**Core dependencies**:
- `provider` ^6.1.2
- `vector_math` ^2.1.4
- `image` ^4.0.0
- `shared_preferences` ^2.2.0

<!-- Auto-generated -->