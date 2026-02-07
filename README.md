# Flutter Fractals

A beautiful Flutter app for rendering 3D Mandelbulb and other fractals with real-time interaction.

## Features

- 🎨 **Multiple Fractal Types**: Mandelbulb, Mandelbox, Julia sets, and Sierpinski tetrahedron
- 🌈 **Color Schemes**: Fire, Ocean, Psychedelic, and Grayscale themes
- 🖐️ **Interactive Controls**: Drag to rotate, pinch to zoom
- ⚡ **Real-time Rendering**: Smooth 60 FPS fractal exploration
- 🎛️ **Parameter Adjustment**: Fine-tune power, iterations, and bailout values
- 📱 **Responsive Design**: Works on phones, tablets, and desktop

## Screenshots

*(Screenshots would go here when the app is running)*

## Getting Started

### Prerequisites

- Flutter SDK (>= 3.10.7)
- Dart SDK
- A device or emulator to run the app

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd flutter_fractals
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Controls

### Gesture Controls
- **Drag**: Rotate the fractal in 3D space
- **Pinch**: Zoom in/out
- **Tap**: Show/hide control panel

### Sliders
- **Power**: Adjusts the fractal's mathematical power (2.0 - 12.0)
- **Iterations**: Controls rendering detail (10 - 100)
- **Bailout**: Sets escape distance threshold (1.0 - 4.0)
- **Zoom**: Magnification level (0.1x - 10x)

### Options
- **Fractal Type**: Choose between different fractal algorithms
- **Color Scheme**: Select visual theme
- **Reset**: Return to default settings

## Technical Details

### Architecture

The app follows a clean architecture pattern:

```
lib/
├── core/                 # Core business logic
│   ├── models/           # Data models
│   └── services/         # Shader services
├── features/            # Feature modules
│   ├── renderer/        # Fractal rendering
│   ├── controls/        # UI controls
│   ├── gallery/         # Preset gallery
│   └── settings/        # App settings
└── shared/             # Shared utilities
```

### Rendering Technology

- **Fragment Shaders**: GLSL shaders for real-time raymarching
- **CustomPainter**: Flutter's canvas API for visualization
- **Vector Math**: 3D transformations and calculations
- **State Management**: Provider pattern for reactive UI

### Fractal Algorithms

1. **Mandelbulb**: 3D extension of the Mandelbrot set
2. **Mandelbox**: Box-folding and sphere-folding transformations
3. **Julia Sets**: Complex number iterations in 3D space
4. **Sierpinski**: Recursive tetrahedron subdivisions

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Setup

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Run tests: `flutter test`
5. Commit changes: `git commit -m 'Add amazing feature'`
6. Push to branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- The fractal mathematics community
- Inspiration from various shader and fractal art projects

## Performance Notes

- Target: 60 FPS on high-end devices
- Adaptive quality scaling for older devices
- GPU acceleration through fragment shaders
- Memory-efficient texture management

## Troubleshooting

### Common Issues

1. **Shader compilation errors**: Make sure your device supports OpenGL ES 3.0
2. **Low performance**: Try reducing iterations or quality settings
3. **Rendering glitches**: Check device compatibility with shaders

### Device Compatibility

- ✅ Android (API 21+)
- ✅ iOS (iOS 10+)
- ✅ Web (Chrome 70+)
- ⚠️ Desktop (Limited shader support)

---

Made with ❤️ and Flutter