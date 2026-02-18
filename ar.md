# Flutter Fractal Forge — AR Architecture Report (Current State)

_Last updated: 2026-02-18_

## Executive Summary

You are correct: **the current AR implementation is not true AR plane tracking**.

It is a **camera-overlay architecture**:
- camera feed in background
- fractal renderer composited on top
- tap sets a 2D screen offset (“anchor”)

This means it can look AR-like, but it does **not** use ARCore/ARKit world tracking, plane detection, hit testing, or true world-locked anchors.

---

## 1) Entry Points and Wiring

### 1.1 Viewer → AR navigation
- File: `lib/features/viewer/fractal_viewer_screen.dart`
- Method: `_openArOverlay(BuildContext context)`
- Behavior:
  - Pushes `ArOverlayScreen`
  - Passes the **same** `FractalController` via `ChangeNotifierProvider.value`

### 1.2 Why this matters
- AR screen uses the currently selected fractal and parameters from viewer state.
- This is good for continuity, but it also means AR relies on the same fractal rendering stack as non-AR mode.

---

## 2) Core AR Screen Architecture

### 2.1 Main class
- File: `lib/features/ar/ar_overlay_screen.dart`
- Widget: `ArOverlayScreen`

### 2.2 Rendering stack (top-level)
1. `CameraPreview(_cameraController)` as full-screen background
2. `RepaintBoundary` overlay stack for fractal and UI
3. Bottom AR controls panel (`_ArControlsPanel`)
4. Export overlays and status hints

### 2.3 Camera subsystem
- Package: `camera`
- Current behavior:
  - requests camera permission (`permission_handler`)
  - enumerates cameras
  - attempts fallback init through camera lenses and resolution presets
  - optional camera switch button if multiple cameras available

### 2.4 "Anchor" model currently implemented
- Variables:
  - `_anchorPlaced` (bool)
  - `_overlayOffset` (2D offset)
  - `_overlayScale`, `_overlayRotation`, `_overlayLocked`
- Gesture:
  - `onTapUp` captures screen point and converts to offset from viewport center
  - sets `_anchorPlaced = true`
  - sets `_overlayLocked = true`

### 2.5 What this anchor is technically
A **screen-space transform anchor**, not a world-space anchor.

There is no:
- plane detection
- world transform from AR engine
- persistent anchor object from ARCore/ARKit

---

## 3) Fractal Overlay Pipeline

### 3.1 Fractal source
- `FractalRenderer` (same engine as viewer)
- rendered inside AR overlay frame with optional style filters and frame decorations

### 3.2 Quality controls
- `ArQualityPreset` (`low/medium/high`) in `core/models/ar_quality_preset.dart`
- Persisted via `ArQualityStore` (`shared_preferences`)
- Applied through `FractalController.applyArQualityPreset(...)`

### 3.3 Transparency behavior
- AR mode forces opaque fractal by default (`transparentBackground = false`)
- previous transparency is restored on AR screen dispose

---

## 4) Export Architecture

### 4.1 Overlay-only export
- Captures `RepaintBoundary` PNG of overlay stack

### 4.2 Baked screenshot export
- Takes camera photo + composites fractal overlay
- Implemented in `core/services/ar_export_service.dart`
- Uses `image` package for pixel compositing

### 4.3 Video export
- `core/services/ar_video_exporter.dart`
- Pure-Dart fallback: records image stream + overlay and encodes GIF
- Not native MP4 AR capture pipeline

---

## 5) Platform Integration Reality Check

## 5.1 Dependencies (pubspec)
Current AR-related deps:
- `camera`
- `permission_handler`
- `image`

No AR SDK/plugin dependency is present (e.g., no ARCore/ARKit bridge plugin).

### 5.2 Android manifest
- No ARCore feature declaration (`android.hardware.camera.ar`)
- No ARCore required metadata (`com.google.ar.core`)

### 5.3 iOS plist
- Missing explicit ARKit/session setup
- Camera usage strings for this AR flow are incomplete for robust iOS deployment

---

## 6) Why it “does not work” for true AR expectations

From architecture alone, the following are expected limitations:

1. **No world lock**
   - Content is not anchored to a detected physical surface in 3D space.

2. **No plane hit test**
   - Tap location is interpreted in 2D screen coordinates, not 3D world coordinates.

3. **No SLAM tracking coupling**
   - Device movement does not update object pose from a world anchor.

4. **No depth occlusion / real surface normal alignment**
   - Overlay does not conform to physical geometry.

5. **UX mismatch**
   - UI language says “anchor to surface,” but implementation is screen-space compositing.

---

## 7) Known Strengths of Current Implementation

Despite not being true AR, current implementation does provide:
- consistent fractal continuity from viewer to AR screen
- camera fallback initialization attempts
- quality presets and accessibility-aware controls
- practical export (overlay + baked image + gif fallback)
- deterministic behavior (no AR session instability from native SDK yet)

---

## 8) Gap Analysis: Current vs True AR

| Capability | Current | True AR target |
|---|---|---|
| Camera feed | ✅ | ✅ |
| Fractal overlay | ✅ | ✅ |
| 2D tap placement | ✅ | ➖ |
| 3D plane detection | ❌ | ✅ |
| AR hit testing | ❌ | ✅ |
| World anchors | ❌ | ✅ |
| Drift-resistant tracking | ❌ | ✅ |
| Surface normal alignment | ❌ | ✅ |
| Occlusion/depth-aware render | ❌ | ✅ |

---

## 9) If you want to research next steps

Research focus should be: **Flutter + real ARCore/ARKit plane anchors for dynamic textures**.

### 9.1 Key migration options
1. **Cross-platform plugin route**
   - `ar_flutter_plugin_plus` (or maintained equivalent)
   - Fastest path to AR anchors, plane detection, hit tests

2. **Platform-specific best-of-breed route**
   - Android: `sceneview_flutter`
   - iOS: `arkit_plugin`
   - More control, higher integration complexity

### 9.2 Critical technical questions to investigate
- Best way to project live fractal output as texture in AR node
- Texture update frequency vs thermal/perf constraints
- Anchor persistence (cloud/local)
- Occlusion support and depth API usage
- How to keep current fractal controller state synchronized with AR node material updates

### 9.3 Search terms
- “Flutter ARCore plane anchor texture update”
- “Flutter ARKit hit test horizontalAndVertical planes”
- “sceneview_flutter plane detection anchor node texture”
- “ar_flutter_plugin dynamic texture material update”
- “ARCore Cloud Anchor Flutter integration”

---

## 10) Proposed Next Implementation Milestone (for future build)

**Milestone: AR Foundation Migration**
- Replace camera-overlay anchor with AR session + plane hit test + world anchor
- Keep existing fractal controller and export UX where possible
- Add capability flag in app: `AR mode = Overlay | True AR`
- Start with Android ARCore path, then iOS ARKit parity

---

## Final Statement

Current architecture is a **camera-overlay AR simulation layer**, not a true spatial AR system.

That is the central reason your real-world anchoring expectation is not met yet.

---

# Appendix: ARCore & Flutter AR Plugin Research (2026)

The following sections provide detailed research on the Flutter AR plugin ecosystem, ARCore SDK capabilities, and migration strategies for implementing true spatial AR.

---

## Flutter AR Plugin Capability Matrix (2026)

| Plugin Name | Primary Platform | Plane Detection Support | Unique Features | Maintenance Status (2026) |
|---|---|---|---|---|
| `ar_flutter_plugin` | Android / iOS | Horizontal & Vertical | Original base, local/online GLB support | **Discontinued** — archived, use forks |
| `ar_flutter_plugin_engine` | Android / iOS | Horizontal & Vertical | Successor to ar_flutter_plugin, collaborative AR, gesture transforms | **Low activity** (v1.0.1, Jul 2024) |
| `ar_flutter_plugin_plus` | Android / iOS | Horiz / Vert / Image | Image tracking, Cloud Anchors, Geospatial API, screenshot capture | **Actively maintained** (v1.1.3, Jan 2026) — **Recommended** |
| `arkit_plugin` | iOS | Horiz / Vert / Face / Body | Deep SceneKit integration, LiDAR mesh reconstruction, occlusion | Specialized / Stable |
| `arcore_flutter_plugin` | Android | Horiz / Vert / Ceiling | Direct ARCore access; based on deprecated Sceneform | **Dormant** (v0.1.0, Feb 2023) — author migrating to sceneview_flutter |
| `sceneview_flutter` | Android | Horiz / Vert / Ceiling | Modern Sceneform replacement; Google Filament renderer + ARCore | **Dormant/Experimental** (v0.0.1, Feb 2023) |
| `ar_quido` | Android / iOS | Image Recognition | Identifies JPG/PNG reference image markers to trigger AR events | Targeted Utility |

### Notable Plugin: `sceneview_flutter`

The [`sceneview_flutter`](https://github.com/SceneView/sceneview-flutter) plugin was envisioned as the most significant architectural shift in Android AR development. Because Google archived the original Sceneform SDK (upon which `arcore_flutter_plugin` depends), `sceneview_flutter` was designed as a complete rewrite using the **SceneView** Kotlin library backed by **Google Filament**—a production-quality physically-based rendering (PBR) engine. The architectural premise remains sound: Filament provides modern PBR rendering that surpasses the deprecated Sceneform pipeline.

However, the Flutter wrapper has **not reached production readiness**. Published at v0.0.1 in February 2023 with approximately 129 lifetime downloads (as of early 2026), the plugin is effectively dormant. For production Android AR work in Flutter, **`ar_flutter_plugin_plus`** is now the better and actively maintained choice.

### Recommended Plugin: `ar_flutter_plugin_plus`

The `ar_flutter_plugin_plus` represents the most capable cross-platform option for the fractal gallery use case, as it integrates image tracking with traditional plane anchoring, Cloud Anchors, and the Geospatial API. This allows a fractal image to be anchored not just to a detected geometric plane but to a specific visual marker on a wall or table, providing higher stability and persistent recognition.

---

## ARCore SDK Status and Recent Updates

The native ARCore SDK has reached **v1.51.0** as of late 2024, with incremental but important updates:

| Version | Key Changes |
|---|---|
| v1.51.0 | Updated sample apps, adjusted `minSdkVersion` to 23, enhanced Vulkan implementation |
| v1.50.0 | Updated `targetSdkVersion` to Android API level 36 |
| v1.48.0 | ARCore Extensions for Unity AR Foundation 6 — full release support |
| v1.37.0+ | Scene Semantics, Geospatial Depth, and Streetscape Geometry APIs stabilized |

### Scene Semantics API

The Scene Semantics API uses machine learning to assign a class label to every pixel in an outdoor scene in real-time. It classifies pixels into **11 classes** of outdoor components (sky, building, tree, road, sidewalk, terrain, water, person, car, etc.), enabling context-aware AR experiences. This API is now available on both Android and iOS.

For fractal gallery applications, Scene Semantics enables intelligent placement — e.g., automatically suggesting building facades for fractal murals or avoiding sky/water regions.

### Geospatial Depth API

The Geospatial Depth API combines:
- Device motion-derived depth
- Active hardware depth sensors (ToF, LiDAR)
- Streetscape Geometry data from Google's 3D point cloud

This fusion **improves depth estimation accuracy up to 65 meters away**, far exceeding single-device capabilities. For fractal galleries, this means more precise occlusion handling at building scale — a fractal anchored to a distant building facade will correctly occlude behind intervening objects.

### Streetscape Geometry API

The Streetscape Geometry API provides 3D mesh data of buildings and terrain derived from Google's Street View data. Combined with Geospatial anchors, this enables fractals to be "painted" onto building surfaces with accurate geometry conformance, even before the user's device has completed local scene reconstruction.

---

## True AR Migration: Implementation Workflow

### Step 1: Environmental Configuration

Set up platform-specific permissions and configurations. For Android, update `AndroidManifest.xml` and the app-level `build.gradle` to declare the AR feature requirement:

```xml
<!-- AndroidManifest.xml -->
<uses-feature android:name="android.hardware.camera.ar" android:required="true"/>
<meta-data android:name="com.google.ar.core" android:value="required"/>
```

For iOS, the `Info.plist` must include `NSCameraUsageDescription`, and the `Podfile` must be configured to handle ARKit targets.

### Step 2: Surface Detection and Filtering

Listen for plane detection events. In `ar_flutter_plugin_plus`, this is handled via the `onPlaneDetected` listener. To distinguish between floor/table and wall/ceiling planes, examine the plane's orientation vector.

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

Once an anchor is created, an `ARNode` is attached. If using a pre-rendered fractal, the image is loaded via the assets folder or a remote URL. If dynamic, the shader-rendered output is applied.

---

## Persistent and Collaborative Fractal Galleries

### Google Cloud Anchors (Room-Scale Persistence)

Cloud Anchors allow the spatial feature map of a specific location to be uploaded to Google's servers. The `ar_flutter_plugin_plus` provides examples for this workflow. Any user within approximately 100 m can then "resolve" that anchor.

With OAuth 2.0 authentication, uploaded anchors persist for up to **365 days**. The workflow:

1. **Host.** The "Artist" app anchors a fractal to a wall and calls `hostCloudAnchor()`.
2. **Store.** The resulting Cloud Anchor ID and fractal metadata are stored in Firebase Firestore.
3. **Resolve.** The "Visitor" app retrieves the ID and calls `resolveCloudAnchor()` to recreate the experience.

### ARCore Geospatial API (City-Scale Persistence)

The **ARCore Geospatial API** uses Google's **Visual Positioning System (VPS)** to localize devices with accuracy far exceeding GPS alone.

| Anchor Type | Description | Best For |
|---|---|---|
| **WGS84** | Fixed at a latitude, longitude, and altitude | Outdoor murals on flat surfaces |
| **Terrain** | Positioned relative to the ground surface elevation | Fractals on sloped terrain or plazas |
| **Rooftop** | Anchored relative to a building's rooftop geometry | Architectural installations on building facades |

### Image Marker Anchoring for Indoor Stability

For featureless walls, image marker tracking via `ar_flutter_plugin_plus` or `ar_quido` is the most reliable anchoring method — significantly more stable than free-form plane detection on blank surfaces.

---

## Limitations and Future Outlook

### Plugin Ecosystem Volatility

The deprecation of Sceneform, the discontinuation of the original `ar_flutter_plugin`, and the stalled development of `sceneview_flutter` (still at v0.0.1 after three years) highlight the fragility of the AR plugin ecosystem. **`ar_flutter_plugin_plus`** (v1.1.3, actively maintained by xinix.tech) has emerged as the clear recommended choice.

### Android XR and Jetpack XR

The **Android XR** platform and **Jetpack XR SDK** have matured significantly. As of Developer Preview 3 (December 2025), the SDK supports:

- **XR headsets** (Samsung Galaxy XR)
- **Wired XR glasses** (XREAL Project Aura)
- **AI glasses** (consumer devices from Gentle Monster, Warby Parker expected early 2026)

However, **Flutter support for Android XR is not yet available** — the SDK currently targets Android Studio, Jetpack Compose, and Unity.

### Semantic Scene Understanding

ARCore's **Scene Semantics API** (stabilized in v1.37.0+) provides AI-assisted surface classification into 11 outdoor classes. Combined with the **Geospatial Depth API** (accurate to 65 meters), this makes context-aware anchoring significantly more reliable without requiring LiDAR hardware.

---

## Migration Summary

- **Floors and tables:** Standard horizontal plane detection via `ar_flutter_plugin_plus` is sufficient and actively supported.
- **Walls:** Vertical plane detection via `ar_flutter_plugin_plus` (cross-platform) or `arkit_plugin` (iOS with LiDAR).
- **Ceilings:** Downward-facing horizontal plane classification or ARKit LiDAR mesh labels. On Android, `HORIZONTAL_DOWNWARD_FACING` via custom platform channels.
- **Persistent galleries:** Cloud Anchors (room-scale, 365-day persistence); Geospatial API with Terrain/Rooftop anchors (building-scale).
- **Context-aware placement:** Scene Semantics API (11 outdoor classes) + Geospatial Depth API (65m accuracy).
- **Stable indoor anchoring:** Image marker tracking via `ar_flutter_plugin_plus` or `ar_quido`.
- **Future-proofing:** Build on standard ARCore APIs today for forward-compatibility with Android XR.

---

## References

- [ARCore What's New — Google Developers](https://developers.google.com/ar/whatsnew-arcore)
- [ARCore Geospatial API — Google Developers](https://developers.google.com/ar/develop/geospatial)
- [ARCore Cloud Anchors — Google Developers](https://developers.google.com/ar/develop/cloud-anchors)
- [Scene Semantics and Geospatial Depth Codelab](https://developers.google.com/codelabs/arcore-scene-semantics-geospatial-depth)
- [Streetscape Geometry & Rooftop Anchors Codelab](https://developers.google.com/codelabs/arcore-streetscape-geometry-rooftop-anchors)
- [ar_flutter_plugin_plus — pub.dev](https://pub.dev/packages/ar_flutter_plugin_plus)
- [ar_flutter_plugin_engine — pub.dev](https://pub.dev/packages/ar_flutter_plugin_engine)
- [SceneView Flutter — GitHub](https://github.com/SceneView/sceneview-flutter)
- [arkit_plugin — pub.dev](https://pub.dev/packages/arkit_plugin)
- [ar_quido — pub.dev](https://pub.dev/packages/ar_quido)
- [ARCore for Jetpack XR — Android Developers](https://developer.android.com/develop/xr/jetpack-xr-sdk/arcore)
- [Android XR SDK Developer Preview 3 — Android Developers Blog](https://android-developers.googleblog.com/2025/12/build-for-ai-glasses-with-android-xr.html)
- [Flutter Fragment Shaders — Official Documentation](https://docs.flutter.dev/ui/design/graphics/fragment-shaders)
- [Building AR Experiences with ARCore & ARKit in Flutter — Vibe Studio](https://vibe-studio.ai/insights/building-ar-experiences-with-arcore-arkit-in-flutter)
- [Flutter AR Guide — Banuba](https://www.banuba.com/blog/flutter-ar-guide)
