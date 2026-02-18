# Spatial Anchoring and Architectural Integration of Procedural Graphics in Flutter-Based Augmented Reality Ecosystems

The integration of augmented reality within the Flutter framework represents a sophisticated intersection of high-level reactive UI programming and low-level spatial computing. As digital environments increasingly overlap with physical spaces, the requirement to anchor complex, procedurally generated visuals—such as fractal images—to specific real-world surfaces like walls, floors, ceilings, and tables has become a primary objective for developers and spatial researchers. This report examines the current state of open-source Flutter AR projects, the underlying mechanisms of surface detection, and the architectural strategies necessary for persistent spatial anchoring.

---

## Theoretical Framework of Flutter AR Integration

The technical realization of augmented reality in a cross-platform context requires a robust bridge between the Dart-based Flutter engine and the native AR capabilities of mobile operating systems. For Android, this is facilitated by Google's ARCore, while iOS utilizes Apple's ARKit. These native SDKs handle the heavy lifting of environmental understanding, which includes motion tracking, light estimation, and plane detection.

The mathematical foundation of this environmental understanding is built upon **Visual-Inertial Odometry (VIO)** and **Simultaneous Localization and Mapping (SLAM)**. VIO combines high-frequency data from the device's Inertial Measurement Unit (IMU)—specifically the accelerometer and gyroscope—with visual feature point extraction from the camera feed. The system identifies unique visual "features" such as high-contrast edges or corners and tracks their relative displacement across successive video frames. This allows the application to calculate the device's position in six degrees of freedom (6DoF) within a local coordinate system.

For a fractal image to be anchored to a physical surface, the application must perform a coordinate transformation from 2D screen space to 3D world space. This is achieved through a process called **hit testing**. When a user interacts with the screen, a virtual ray is cast from the camera's perspective through the touched point and into the reconstructed 3D scene. If this ray intersects with a detected plane (such as a table or wall), the system generates an `ARAnchor`.

The transformation of a point $P_{screen}(x, y)$ to a point $P_{world}(X, Y, Z)$ involves the inverse of the projection matrix $M_{proj}$ and the view-model matrix $M_{view}$:

$$P_{world} = M_{view}^{-1} \cdot M_{proj}^{-1} \cdot P_{ndc}$$

where $P_{ndc}$ represents the coordinates in Normalized Device Coordinate space.

---

## Comparative Analysis of Open-Source AR Plugins

The Flutter AR ecosystem is characterized by several key plugins that abstract the complexities of ARCore and ARKit. The original `ar_flutter_plugin` served as the foundational community standard, but its development has since fragmented into specialized forks and successors to maintain compatibility with modern SDKs and introduce advanced features like cloud anchoring, image tracking, and the Geospatial API.

### Plugin Evolution and Capability Matrix

The choice of plugin is contingent upon the specific surface anchoring requirements. Projects necessitating vertical plane detection (walls) or downward-facing plane detection (ceilings) require plugins that expose the full configuration suites of the native SDKs.

| Plugin Name | Primary Platform | Plane Detection Support | Unique Features | Maintenance Status (2025) |
|---|---|---|---|---|
| `ar_flutter_plugin` | Android / iOS | Horizontal & Vertical | Original base, local/online GLB support | Discontinued/Legacy |
| `ar_flutter_plugin_2` | Android / iOS | Horizontal & Vertical | Updated for modern SceneView (Android), Gradle compatibility fork | Active Community |
| `ar_flutter_plugin_plus` | Android / iOS | Horiz / Vert / Image | Image marker tracking, Cloud Anchors, Collaborative AR | Highly Active |
| `arkit_plugin` | iOS | Horiz / Vert / Face / Body | Deep SceneKit integration, LiDAR mesh reconstruction, occlusion | Specialized / Stable |
| `arcore_flutter_plugin` | Android | Horiz / Vert / Ceiling | Direct ARCore access; based on deprecated Sceneform | Legacy — use `sceneview_flutter` instead |
| `sceneview_flutter` | Android | Horiz / Vert / Ceiling | Modern Sceneform replacement; uses Google Filament renderer and ARCore | Actively Developed |
| `ar_quido` | Android / iOS | Image Recognition | Identifies JPG/PNG reference image markers to trigger AR events | Targeted Utility |

#### Notable Plugin: `sceneview_flutter`

The [`sceneview_flutter`](https://github.com/SceneView/sceneview-flutter) plugin represents the most significant architectural shift in Android AR development. Because Google archived the original Sceneform SDK (upon which `arcore_flutter_plugin` depends), `sceneview_flutter` was developed as a complete rewrite using the **SceneView** Kotlin library backed by **Google Filament**—a production-quality physically-based rendering (PBR) engine. For new projects targeting Android, this plugin is the recommended replacement for `arcore_flutter_plugin`.

The `ar_flutter_plugin_plus` represents the most capable cross-platform option for the fractal gallery use case, as it integrates image tracking with traditional plane anchoring. This allows a fractal image to be anchored not just to a detected geometric plane but to a specific visual marker on a wall or table, providing higher stability and persistent recognition.

---

## Surface-Specific Anchoring Strategies

Anchoring digital content to floors, tables, walls, and ceilings requires distinct technical approaches due to how ARCore and ARKit classify and track different surface orientations.

### Floors and Tables: Horizontal Plane Detection

Horizontal plane detection is the most mature aspect of mobile AR. The system typically identifies surfaces that are perpendicular to the gravity vector. Tables and floors provide high-contrast feature points that allow the SLAM algorithm to resolve the plane's extent and boundaries quickly. In Flutter, the `ARSessionManager` is usually initialized with `PlaneDetectionConfig.horizontal` to facilitate this.

Open-source projects like `learn_ar_flutter` and `ARCore-Wizard` demonstrate the standard workflow: the app detects a horizontal surface, visualizes it with a mesh or grid, and allows the user to tap to place an anchor. For fractal images, this anchor serves as the origin point for a flat 3D node that displays the fractal texture.

### Walls: Vertical Plane Detection and Occlusion

Vertical plane detection is technically more demanding. Many interior walls are featureless and monochromatic, making it difficult for standard cameras to extract the feature points necessary for plane fitting. To resolve this, specialized plugins like `arkit_plugin` allow for explicit vertical plane detection:

```dart
body: ARKitSceneView(
  planeDetection: ARPlaneDetection.horizontalAndVertical,
  onARKitViewCreated: onARKitViewCreated,
)
```

This configuration instructs the iOS engine to look for surfaces parallel to the gravity vector. The `ARWallPicture` project provides a direct example of this, specifically designed to display images from a photo library on detected wall surfaces. This is highly relevant for the goal of anchoring fractals to walls, as it provides the logic for image-to-plane mapping and automatic image switching based on the viewing angle.

For realism, walls also require **occlusion handling**. The `arkit_plugin` occlusion sample uses a transparent material with `ARKitColorMask.none`, which writes to the depth buffer without rendering color. This ensures that any virtual fractal "behind" a real-world object (like a pillar or furniture) is correctly hidden, maintaining the spatial illusion.

### Ceilings: Horizontal Downward Classification

Ceiling detection is a specialized case of horizontal plane detection where the surface normal is oriented downward. ARCore's native SDK includes a `HORIZONTAL_DOWNWARD_FACING` classification, though many Flutter plugins abstract this into a general horizontal category or omit it.

The `sceneview_flutter` plugin (and its predecessor `arcore_flutter_plugin`) expose the `ArCorePlane` class, which can return specific orientations including downward-facing surfaces. If a plugin does not natively classify ceilings, developers commonly use a spatial offset from the floor or a ray-casting technique that searches for the highest horizontal plane in the current coordinate system.

On iOS devices with **LiDAR**, ARKit's Scene Reconstruction generates a dense 3D mesh of the environment with surface **classification labels** including `.floor`, `.wall`, `.ceiling`, and `.table`. This mesh-based classification is significantly more reliable for ceiling detection than feature-point plane fitting alone, and is accessible through `arkit_plugin`.

### Surface Classification Summary

| Classification | Normal Vector (Y-axis) | Recommended Detection Method |
|---|---|---|
| Floor / Table | ≈ +1.0 (Upward) | Standard horizontal plane detection |
| Ceiling | ≈ −1.0 (Downward) | `HORIZONTAL_DOWNWARD_FACING` or LiDAR mesh classification |
| Wall | ≈ 0.0 (Perpendicular to Gravity) | Vertical plane detection + feature-point hit testing |

---

## Open-Source Projects for Fractal Visualization

While many AR projects focus on static 3D models (GLB/GLTF), the requirement for fractal images introduces the need for procedural texture generation or dynamic image handling.

### The eCommerce and UI Foundation

The `eCommerce-UI-with-Flutter-Augmented-Reality-ARKit` project by `maxonflutter` provides a professional-grade architecture for managing a gallery of items. Its structure separates the UI (browsing fractals) from the AR view (anchoring them). The `lib/screens/product_with_augmented_reality_screen.dart` file manages the lifecycle of the ARKit session and the placement of 3D nodes, which can be adapted to display 2D fractal textures instead of furniture models.

### AR Room Decor and Spatial Management

The `ar_room_decor` project, built with Flutter and Firebase, illustrates how to manage a persistent gallery of decorative items. Its "Object Capture" functionality allows users to capture physical objects and add them to a virtual gallery—a concept that can be pivoted to allow users to "capture" a section of a wall as a canvas for a fractal overlay.

### Situm AR and Multi-Binary Integration

For high-end or industrial applications, `situm_flutter_ar` demonstrates the integration of complex AR binaries (like Unity exports) into a Flutter application. This is relevant for fractals rendered via complex shaders in Unity and embedded into a Flutter-managed UI. Unity's shader language (HLSL) is often more optimized for the recursive calculations required for fractals like the Mandelbrot set than pure Dart compute paths.

---

## Procedural Rendering of Fractals in AR

Fractals are defined by recursive mathematical formulas. Rendering these in an AR context requires a transition from CPU-bound Dart code to GPU-bound fragment shaders.

### Shader Integration in Flutter

Flutter 3.x introduced stable support for fragment shaders via the `FragmentProgram` API. A Mandelbrot fractal, for instance, can be defined in a `.frag` GLSL file:

$$z_{n+1} = z_n^2 + c$$

Shaders must be declared in the `shaders:` section of `pubspec.yaml`; the Flutter toolchain then compiles them to the appropriate backend format at build time:

```yaml
flutter:
  shaders:
    - shaders/mandelbrot.frag
```

At runtime, a shader is loaded and instantiated as follows:

```dart
final program = await FragmentProgram.fromAsset('shaders/mandelbrot.frag');
final shader = program.fragmentShader();
```

The community package [`flutter_shaders`](https://pub.dev/packages/flutter_shaders) provides higher-level utilities (e.g., `AnimatedSampler`, `ShaderBuilder`) that simplify binding uniforms and integrating shaders into the widget tree.

To bridge a shader-rendered fractal with AR, the output is rendered to an `ImageShader` or captured via `PictureRecorder.toImage()`, then the resulting byte array is passed to the `ArCoreMaterial` or `ARKitMaterial` texture property.

### Performance Considerations for Fractals in AR

Recursive Mandelbrot/Julia-set calculations are computationally expensive. In an active AR session, the device is already under heavy load from VIO, SLAM, and plane detection. If fractal rendering drops the frame rate below 30 FPS, spatial tracking will drift, causing the fractal to "float" away from its anchor.

Strategies to maintain performance:

- **Cache `FragmentProgram` instances.** Re-instantiating from assets each frame is expensive. Load once and reuse `Shader` objects across frames.
- **Asynchronous rendering.** Use a separate Dart `Isolate` (or `compute()`) to drive iteration-count calculations when the fractal is generated on the CPU.
- **Level of Detail (LOD).** Reduce the iteration depth of the fractal when the user is far from the anchored image; increase it as they approach.
- **Impeller rendering engine.** Flutter's Impeller backend (enabled by default on iOS, opt-in on Android) provides deterministic GPU pipeline compilation, eliminating the shader-compilation jank that previously caused frame drops on first render.
- **LiDAR offloading (iOS).** On LiDAR-equipped devices, depth sensing reduces the reliance on visual feature-point SLAM, freeing GPU cycles for fractal rendering.

---

## Technical Implementation Workflow

To anchor fractals to all four surface types (floors, tables, walls, ceilings), a developer should follow an integrated workflow combining several open-source techniques.

### Step 1: Environmental Configuration

Set up platform-specific permissions and configurations. For Android, update `AndroidManifest.xml` and the app-level `build.gradle` to declare the AR feature requirement:

```xml
<!-- AndroidManifest.xml -->
<uses-feature android:name="android.hardware.camera.ar" android:required="true"/>
<meta-data android:name="com.google.ar.core" android:value="required"/>
```

For `sceneview_flutter`, add the dependency instead of the deprecated Sceneform library:

```gradle
// build.gradle (app-level)
dependencies {
    implementation 'io.github.sceneview:arsceneview:2.x.x'
}
```

For iOS, the `Info.plist` must include `NSCameraUsageDescription`, and the `Podfile` must be configured to handle ARKit targets.

### Step 2: Surface Detection and Filtering

Listen for plane detection events. In `ar_flutter_plugin_2`, this is handled via the `onPlaneDetected` listener. To distinguish between floor/table and wall/ceiling planes, examine the plane's orientation vector.

For LiDAR-equipped iOS devices, request ARKit mesh classification directly:

```dart
ARKitSceneView(
  configuration: ARWorldTrackingConfiguration()
    ..sceneReconstruction = ARSceneReconstruction.meshWithClassification,
  onARKitViewCreated: onARKitViewCreated,
)
```

This provides per-vertex mesh labels (`.floor`, `.wall`, `.ceiling`, `.table`, etc.) without relying solely on geometric plane fitting.

### Step 3: Hit Testing and Anchor Placement

Upon a user tap, the hit test determines the precise coordinates on the surface. For walls, a `featurePoint` hit test is often more successful if a plane has not yet been fully resolved. The `arkit_plugin` allows hit testing against detected planes using the `existingPlaneUsingExtent` type, which ensures the fractal remains within the bounds of the detected surface.

### Step 4: Fractal Texture Application

Once an anchor is created, an `ARNode` is attached. If using a pre-rendered fractal, the image is loaded via the assets folder or a remote URL. If dynamic, the shader-rendered output is applied. The `ARWallPicture` project demonstrates dynamic image-texture replacement on vertical planes, providing a template for this step.

---

## Persistent and Collaborative Fractal Galleries

The concept of a fractal gallery implies that the artwork should stay in place even after the app is closed and be visible to multiple users. Two complementary approaches address this: **Cloud Anchors** (room-scale) and the **ARCore Geospatial API** (building- and city-scale).

### Google Cloud Anchors (Room-Scale Persistence)

Cloud Anchors allow the spatial feature map of a specific location to be uploaded to Google's servers. The `ar_flutter_plugin_plus` provides examples for this workflow. Any user within approximately 100 m can then "resolve" that anchor, causing the fractal to appear in the same real-world position on their device.

With OAuth 2.0 authentication, uploaded anchors persist for up to **365 days**. The workflow for a persistent fractal installation:

1. **Host.** The "Artist" app anchors a fractal to a wall and calls `hostCloudAnchor()`.
2. **Store.** The resulting Cloud Anchor ID and fractal metadata (e.g., `"Mandelbrot, blue-gold palette"`) are stored in Firebase Firestore.
3. **Resolve.** The "Visitor" app retrieves the ID and calls `resolveCloudAnchor()` to recreate the experience.

### ARCore Geospatial API (City-Scale Persistence)

For outdoor installations or large venues, the **ARCore Geospatial API** (supported on Android and iOS) uses Google's **Visual Positioning System (VPS)**—a global 3D point cloud derived from Street View imagery—to localize devices with accuracy far exceeding GPS alone. This enables fractal artwork to be pinned to specific geographic coordinates without any manual mapping or prior scanning of the space.

The API provides three anchor types:

| Anchor Type | Description | Best For |
|---|---|---|
| **WGS84** | Fixed at a latitude, longitude, and altitude | Outdoor murals on flat surfaces |
| **Terrain** | Positioned relative to the ground surface elevation | Fractals on sloped terrain or plazas |
| **Rooftop** | Anchored relative to a building's rooftop geometry | Architectural installations on building facades |

For fractal gallery applications, Terrain and Rooftop anchors offer the most compelling deployment scenario: a fractal can be "mounted" on the exterior wall of a building at a specific GPS coordinate, visible to any visitor who opens the app nearby.

### Image Marker Anchoring for Indoor Stability

For environments with low texture (blank walls, white galleries), image marker tracking is the most reliable anchoring method. By placing a small, high-contrast physical marker on the wall, the app can use it as a stable reference point. The `ar_flutter_plugin_plus` and `ar_quido` plugins identify these markers and provide a stable transformation matrix for the fractal node.

Reference images are declared in `pubspec.yaml` assets and loaded into the AR session's reference image set. Detection latency is typically under one second, and the anchor remains stable even when the marker is partially occluded.

Image anchors are significantly more reliable for "fixed" visualizations than free-form plane detection—the recommended approach for users wanting to "hang" fractal art on walls without the positional drift associated with standard VIO on featureless surfaces.

---

## Current Limitations and Future Outlook

### Hardware Dependencies and Discrepancies

ARCore and ARKit are not universally supported. Apps must include a device-compatibility check before entering the AR view. Vertical plane detection is notably less stable on older devices lacking depth sensors or LiDAR. The Geospatial API requires Street View coverage of the target location and is unavailable in regions where Google has not collected VPS data.

### Plugin Ecosystem Volatility

The deprecation of Sceneform and the discontinuation of the original `ar_flutter_plugin` highlight the fragility of the AR plugin ecosystem. Developers are strongly advised to target `ar_flutter_plugin_plus` for cross-platform projects or `sceneview_flutter` for Android-specific work. Both are actively maintained and compatible with Flutter 3.10+.

### Emerging: Android XR and Jetpack XR

The 2025 landscape introduces **Android XR** and the **Jetpack XR SDK**, Google's next-generation platform targeting headsets and glasses in addition to phones. Early ARCore APIs for Jetpack XR already expose Geospatial pose tracking. While Flutter support for Android XR is nascent, the underlying ARCore APIs are expected to be unified, meaning fractal gallery applications built on the Geospatial API today should be forward-compatible with wearable form factors as Flutter's XR support matures.

### Emerging: Semantic Scene Understanding

Future ARCore and ARKit releases are trending toward **scene semantics**—AI-assisted surface classification that goes beyond geometric plane fitting. Rather than relying purely on VIO to guess that a surface is a wall, the system will classify it semantically. This will make ceiling detection and featureless-wall anchoring significantly more reliable without requiring LiDAR hardware.

---

## Conclusion

The objective of anchoring fractal images to various real-world surfaces in a Flutter application is achievable through a strategic combination of open-source plugins.

- **Floors and tables:** Standard horizontal plane detection via `ar_flutter_plugin_plus` or `sceneview_flutter` is sufficient.
- **Walls:** Vertical plane configurations from `arkit_plugin` and the `ARWallPicture` reference project handle image mapping and occlusion.
- **Ceilings:** Downward-facing horizontal plane classification or ARKit LiDAR mesh labels provide the most reliable detection.
- **Persistent galleries:** Cloud Anchors cover room-scale indoor installations (up to 365-day persistence); the ARCore Geospatial API with Terrain/Rooftop anchors handles outdoor and building-scale deployments without pre-mapping.
- **Stable indoor anchoring:** Image marker tracking via `ar_flutter_plugin_plus` or `ar_quido` is the recommended approach for featureless walls.

By leveraging Flutter's `FragmentProgram` shader API with the Impeller rendering engine, and combining cloud-based persistent anchors with the Geospatial API, developers can create immersive, stable, and shareable fractal galleries that bridge the gap between abstract mathematics and physical space.

---

## References and Further Reading

- [Flutter Fragment Shaders — Official Documentation](https://docs.flutter.dev/ui/design/graphics/fragment-shaders)
- [FragmentProgram class — Dart API](https://api.flutter.dev/flutter/dart-ui/FragmentProgram-class.html)
- [`flutter_shaders` package — pub.dev](https://pub.dev/packages/flutter_shaders)
- [ARCore Cloud Anchors — Google Developers](https://developers.google.com/ar/develop/cloud-anchors)
- [ARCore Geospatial API — Google Developers](https://developers.google.com/ar/develop/geospatial)
- [Streetscape Geometry & Rooftop Anchors Codelab](https://developers.google.com/codelabs/arcore-streetscape-geometry-rooftop-anchors)
- [SceneView Flutter — GitHub](https://github.com/SceneView/sceneview-flutter)
- [arkit_plugin — pub.dev](https://pub.dev/packages/arkit_plugin)
- [ar_quido — pub.dev](https://pub.dev/packages/ar_quido)
- [Build AR Apps with Flutter — Banuba 2025 Guide](https://www.banuba.com/blog/flutter-ar-guide)
- [Bringing Data to Life: Exploring AR in Flutter — ClearPeaks](https://www.clearpeaks.com/bringing-data-to-life-exploring-ar-in-flutter/)
