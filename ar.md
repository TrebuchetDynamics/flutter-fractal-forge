# Flutter AR Fractal Placement Guide

## Overview
Implement Augmented Reality to place 2D fractal images on real-world surfaces using **ar_flutter_plugin**. This guide covers plane detection, hit testing, and asset placement for both Android (ARCore) and iOS (ARKit).

## Prerequisites

### Device Requirements
- **Android**: ARCore supported device (Android 7.0+)
- **iOS**: ARKit supported device (iOS 11.0+, A9 chip or newer)
- **Enable AR in project**:
  ```yaml
  # pubspec.yaml
  dependencies:
    ar_flutter_plugin: ^latest_version
    vector_math: ^2.1.0
  ```

### Platform Configuration

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera.ar" android:required="true" />

<application>
    <meta-data
        android:name="com.google.ar.core"
        android:value="required" />
</application>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>AR requires camera access</string>
<key>UIRequiredDeviceCapabilities</key>
<array>
    <string>arkit</string>
</array>
```

## Implementation

### 1. Project Structure
```
lib/
├── ar/
│   ├── ar_scene_manager.dart
│   ├── fractal_node_builder.dart
│   └── plane_detector.dart
├── widgets/
│   └── ar_view_widget.dart
└── main.dart
```

### 2. Core AR Manager
```dart
// lib/ar/ar_scene_manager.dart
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:vector_math/vector_math_64.dart';

class ARSceneManager {
  late ARSessionManager _sessionManager;
  late ARObjectManager _objectManager;
  late ARAnchorManager _anchorManager;
  bool _isInitialized = false;

  Future<void> initialize(ARViewCreatedCallback onViewCreated) async {
    try {
      await _checkARAvailability();
      _isInitialized = true;
    } catch (e) {
      throw Exception('AR initialization failed: $e');
    }
  }

  Future<void> _checkARAvailability() async {
    // Platform-specific availability checks
  }

  void onARViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) {
    _sessionManager = sessionManager;
    _objectManager = objectManager;
    _anchorManager = anchorManager;

    _configureSession();
    _setupPlaneDetection();
    _setupGestureHandlers();
  }

  void _configureSession() {
    _sessionManager.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: false,
      handleTaps: true,
      handlePans: true,
      handleRotation: true,
    );
  }

  void _setupPlaneDetection() {
    _sessionManager.onPlaneOrPointTap = _onPlaneTapped;
  }

  void _setupGestureHandlers() {
    _objectManager.onPanStart = _onNodePanStart;
    _objectManager.onPanChange = _onNodePanChange;
    _objectManager.onRotationStart = _onNodeRotationStart;
  }

  Future<void> _onPlaneTapped(List<ARHitTestResult> hitTestResults) async {
    final planeHit = hitTestResults.firstWhereOrNull(
      (hit) => hit.type == ARHitTestResultType.plane,
    );

    if (planeHit != null) {
      await _placeFractalAtHit(planeHit);
    }
  }

  Future<void> _placeFractalAtHit(ARHitTestResult hit) async {
    try {
      // Create anchor at hit location
      final anchor = ARPlaneAnchor(
        transformation: hit.worldTransform,
      );

      final anchorAdded = await _anchorManager.addAnchor(anchor);
      
      if (anchorAdded) {
        await _createFractalNode(anchor);
      }
    } catch (e) {
      print('Failed to place fractal: $e');
    }
  }

  Future<void> _createFractalNode(ARPlaneAnchor anchor) async {
    // Implementation in next section
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      await _sessionManager.dispose();
      _isInitialized = false;
    }
  }
}
```

### 3. Fractal Node Builder
```dart
// lib/ar/fractal_node_builder.dart
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart';

class FractalNodeBuilder {
  static ARNode createFractalNode({
    required String imagePath,
    required double width,
    required double height,
    Vector3? position,
    Vector4? rotation,
  }) {
    // For 2D images, create a plane with texture
    return ARNode(
      name: 'fractal_${DateTime.now().millisecondsSinceEpoch}',
      type: NodeType.fileSystemAppFolderGLB,
      uri: _createGLBModel(imagePath, width, height),
      scale: Vector3(0.3, 0.3, 0.3), // Start with reasonable scale
      position: position ?? Vector3(0, 0, 0),
      rotation: rotation ?? Vector4(0, 0, 0, 0),
    );
  }

  static String _createGLBModel(String imagePath, double width, double height) {
    // In production, pre-process fractal images to GLB format
    // For development, use a placeholder model with dynamic texture loading
    return 'models/fractal_plane.glb';
  }

  static Future<void> updateFractalTexture(
    ARNode node, 
    String newImagePath,
  ) async {
    // Update material texture with new fractal image
    // This requires custom shader/material implementation
  }
}
```

### 4. Complete AR Widget
```dart
// lib/widgets/ar_view_widget.dart
import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import '../ar/ar_scene_manager.dart';

class ARFractalView extends StatefulWidget {
  final String fractalImagePath;
  
  const ARFractalView({super.key, required this.fractalImagePath});

  @override
  State<ARFractalView> createState() => _ARFractalViewState();
}

class _ARFractalViewState extends State<ARFractalView> {
  late ARSceneManager _arManager;
  bool _isARReady = false;
  String _statusMessage = 'Initializing AR...';

  @override
  void initState() {
    super.initState();
    _arManager = ARSceneManager();
    _initializeAR();
  }

  Future<void> _initializeAR() async {
    try {
      await _arManager.initialize(_onARViewCreated);
      setState(() {
        _isARReady = true;
        _statusMessage = 'Tap on surfaces to place fractal';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'AR unavailable: $e';
      });
    }
  }

  void _onARViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) {
    _arManager.onARViewCreated(
      sessionManager,
      objectManager,
      anchorManager,
      locationManager,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ARView(
          onARViewCreated: _onARViewCreated,
          planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: _buildControls(),
        ),
        Positioned(
          top: 50,
          left: 0,
          right: 0,
          child: _buildStatusOverlay(),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlButton(
            icon: Icons.refresh,
            label: 'Reset',
            onTap: _resetScene,
          ),
          _ControlButton(
            icon: Icons.delete,
            label: 'Clear',
            onTap: _clearFractals,
          ),
          _ControlButton(
            icon: Icons.photo,
            label: 'Change',
            onTap: _changeFractal,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOverlay() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isARReady ? Icons.check_circle : Icons.info,
            color: _isARReady ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 10),
          Text(
            _statusMessage,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _resetScene() {
    // Implement scene reset
  }

  void _clearFractals() {
    // Implement clear all fractals
  }

  void _changeFractal() {
    // Implement fractal image change
  }

  @override
  void dispose() {
    _arManager.dispose();
    super.dispose();
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
```

### 5. Main Application
```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'widgets/ar_view_widget.dart';

void main() {
  runApp(const FractalARApp());
}

class FractalARApp extends StatelessWidget {
  const FractalARApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fractal AR Gallery',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: const FractalGalleryScreen(),
    );
  }
}

class FractalGalleryScreen extends StatefulWidget {
  const FractalGalleryScreen({super.key});

  @override
  State<FractalGalleryScreen> createState() => _FractalGalleryScreenState();
}

class _FractalGalleryScreenState extends State<FractalGalleryScreen> {
  String _selectedFractal = 'assets/fractals/mandelbrot.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fractal AR Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: _showInstructions,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ARFractalView(fractalImagePath: _selectedFractal),
          ),
          _buildFractalSelector(),
        ],
      ),
    );
  }

  Widget _buildFractalSelector() {
    return Container(
      height: 100,
      color: Colors.black87,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FractalThumbnail(
            imagePath: 'assets/fractals/mandelbrot.png',
            isSelected: _selectedFractal == 'assets/fractals/mandelbrot.png',
            onTap: () => _selectFractal('assets/fractals/mandelbrot.png'),
          ),
          _FractalThumbnail(
            imagePath: 'assets/fractals/julia.png',
            isSelected: _selectedFractal == 'assets/fractals/julia.png',
            onTap: () => _selectFractal('assets/fractals/julia.png'),
          ),
          // Add more fractal thumbnails
        ],
      ),
    );
  }

  void _selectFractal(String path) {
    setState(() {
      _selectedFractal = path;
    });
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AR Instructions'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Slowly move your device around'),
            Text('2. Wait for planes to appear (white dots)'),
            Text('3. Tap on detected surfaces to place fractal'),
            Text('4. Use pinch to scale, drag to move'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _FractalThumbnail extends StatelessWidget {
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _FractalThumbnail({
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
```

## Asset Preparation

### For 2D Fractal Images:
1. **Convert to GLB format** using tools like Blender or online converters
2. **Optimize textures**: 1024x1024 PNG with transparency
3. **Place in assets**:
   ```
   assets/
   ├── models/
   │   └── fractal_plane.glb
   └── fractals/
       ├── mandelbrot.png
       └── julia.png
   ```

### pubspec.yaml Configuration:
```yaml
flutter:
  assets:
    - assets/models/
    - assets/fractals/
```

## Troubleshooting

### Common Issues:
1. **No planes detected**:
   - Ensure adequate lighting
   - Move device slowly to scan surfaces
   - Check if surface has enough texture

2. **AR not available**:
   ```dart
   Future<bool> checkARSupport() async {
     if (Platform.isAndroid) {
       return await ArCoreController.checkArCoreAvailability();
     } else if (Platform.isIOS) {
       return await ArKitController.checkArKitAvailability();
     }
     return false;
   }
   ```

3. **Performance optimization**:
   - Limit simultaneous fractal nodes to 5-10
   - Use compressed textures
   - Dispose unused nodes immediately

## Testing Checklist
- [ ] Camera permission granted
- [ ] ARCore/ARKit supported device
- [ ] Surfaces have sufficient texture
- [ ] Adequate lighting conditions
- [ ] Fractal images properly formatted
- [ ] Platform configurations applied

## Next Steps
1. Implement fractal generation directly in AR
2. Add multiplayer shared AR experiences
3. Integrate with fractal parameter controls
4. Add animation to fractal transformations

This implementation provides a robust foundation for placing fractal images in AR. The modular structure allows for easy extension with additional fractal types and interaction modes.