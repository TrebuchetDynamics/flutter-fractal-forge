# Flutter Fractal Forge 🌀

<p align="center">
  <img src="assets/feature-graphic.png" alt="Flutter Fractal Forge" width="600"/>
</p>

A beautiful, high-performance Flutter application for exploring and rendering mathematical fractals in real-time. Experience stunning 2D and 3D fractals with interactive controls, AR overlay capabilities, and export options.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## ✨ Features

### 🎨 Multiple Fractal Types
- **Mandelbrot Set** — The classic 2D fractal with infinite zoom capability
- **Julia Set** — Complex parameter-based variations
- **Burning Ship** — Dramatic angular fractal with unique aesthetics
- **Phoenix Fractal** — Recursive transformation patterns
- **Mandelbulb** — Stunning 3D extension of the Mandelbrot set
- **Offline Capable:** Fully functional without internet access
- **Privacy Focused:** No analytics or tracking

### 🖐️ Interactive Controls
- **Drag** to rotate 3D fractals or pan 2D fractals
- **Pinch** to zoom in/out
- **Customizable parameters** — Fine-tune power, iterations, bailout, and more
- **Color schemes** — Fire, Ocean, Psychedelic, and Grayscale themes

### 📱 AR Camera Overlay
- Overlay fractals on your camera feed
- Adjustable quality presets (Low/Medium/High)
- Transparent background support
- Perfect for creative photography

### 💾 Presets & Export
- **Built-in presets** for each fractal type
- **Save custom presets** with thumbnails
- **Export to PNG** with transparency support
- **Share directly** to other apps

### 🌐 Localization
- English and Spanish language support
- Extensible localization framework

## 📸 Screenshots

| Explore Tab | Mandelbrot View | AR Overlay |
|:-----------:|:---------------:|:----------:|
| Browse fractal types | Interactive viewer with controls | Camera overlay mode |

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** >= 3.0.0
- **Dart SDK** >= 3.0.0
- A device/emulator with OpenGL ES 3.0+ support (for shaders)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/XelHaku/flutter-fractal-forge.git
   cd flutter-fractal-forge
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

#### Linux/macOS/Windows
```bash
flutter build linux --release
flutter build macos --release
flutter build windows --release
```

> **Note:** Desktop platforms may have limited shader support depending on GPU drivers.

## 🏗️ Architecture

The app follows a clean, modular architecture:

```
lib/
├── core/                           # Core business logic
│   ├── models/                     # Data models
│   │   ├── fractal_params.dart     # Legacy parameter model
│   │   ├── fractal_parameter.dart  # Parameter schema definition
│   │   ├── fractal_preset.dart     # Preset storage model
│   │   ├── fractal_view_state.dart # Camera/view state
│   │   ├── ar_quality_preset.dart  # AR quality settings
│   │   └── export_options.dart     # Export configuration
│   ├── modules/                    # Fractal module definitions
│   │   ├── fractal_module.dart     # Base module class
│   │   ├── module_registry.dart    # Module registration
│   │   ├── mandelbrot_module.dart  # Mandelbrot implementation
│   │   ├── mandelbulb_module.dart  # 3D Mandelbulb
│   │   ├── julia_module.dart       # Julia set
│   │   ├── burning_ship_module.dart
│   │   └── phoenix_module.dart
│   ├── services/                   # App services
│   └── theme/                      # Theming system
├── features/                       # Feature modules
│   ├── ar/                         # AR camera overlay
│   ├── catalog/                    # Fractal catalog/browser
│   ├── controls/                   # Parameter controls UI
│   ├── debug/                      # Debug overlay (dev only)
│   ├── home/                       # Home screen with tabs
│   ├── presets/                    # Preset management
│   ├── renderer/                   # Shader rendering engine
│   │   ├── fractal_renderer.dart   # Main renderer widget
│   │   ├── fractal_canvas.dart     # CustomPainter for shaders
│   │   └── providers/              # State management
│   └── viewer/                     # Full-screen viewer
├── l10n/                           # Localization files
├── shared/                         # Shared utilities
└── main.dart                       # App entry point
```

### Key Components

#### FractalModule
Defines a fractal type with its shader, parameters, and presets. Each module is self-contained and declarative.

#### FractalController
A `ChangeNotifier` that manages the current fractal state — selected module, parameters, view transform, and transparency settings.

#### FractalRenderer
A stateful widget that loads the appropriate GLSL shader, handles gesture input, and renders fractals at 60 FPS using `CustomPainter`.

#### ModuleRegistry
Central registry for all available fractal modules. Easily extensible to add new fractal types.

## 🎮 Controls

### Gesture Controls

| Gesture | 2D Fractals | 3D Fractals |
| :--- | :--- | :--- |
| **Drag** | Pan view | Rotate view |
| **Pinch** | Zoom | Zoom |
| **Double Tap** | Reset view | Reset view |

### Parameters
- **Iterations** — Detail level (higher = more detail, slower)
- **Bailout** — Escape threshold for calculations
- **Power** — Mathematical power (3D fractals)
- **Color Scheme** — Visual theme selection

## 🧪 Testing

Run the test suite:

```bash
# Unit and widget tests
flutter test

# Integration tests (requires device/emulator)
flutter test integration_test

# With coverage
flutter test --coverage
```

## 🔧 Shader Development

Shaders are located in `/shaders/` and use GLSL fragment shader syntax:

```glsl
// Example: shaders/mandelbrot.frag
#version 320 es
precision highp float;

uniform float uTime;
uniform vec2 uResolution;
// ... more uniforms

out vec4 fragColor;

void main() {
    // Fractal calculation here
}
```

See [SHADER_OPTIMIZATIONS.md](SHADER_OPTIMIZATIONS.md) for performance tips.

## 📋 Requirements

| Platform | Minimum Version | Notes |
| :------- | :-------------- | :---- |
| Android  | API 21 (5.0)    | OpenGL ES 3.0 required |
| iOS      | 10.0            | Metal-backed shaders |
| Web      | Chrome 70+      | WebGL 2.0 support |
| Desktop  | Varies          | GPU driver dependent |

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) for details on:

- Code style and conventions
- How to submit pull requests
- Issue reporting guidelines
- Development workflow

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev) — For the amazing cross-platform framework
- [Inigo Quilez](https://iquilezles.org/) — Shader techniques and raymarching inspiration
- The fractal mathematics community for algorithmic insights
- Shader art communities for visual inspiration

## 📊 Performance

- **Target:** 60 FPS on mid-range devices
- **Adaptive quality:** Reduces iterations on older devices
- **GPU acceleration:** All rendering via fragment shaders
- **Memory efficient:** No large texture allocations
- **Renderer docs:** See `docs/cpu_vs_gpu_rendering.md`, `docs/renderer_backend_matrix.md`, and `docs/formula_coverage_limitation.md`

---

<p align="center">
  Made with ❤️ and Flutter
</p>
