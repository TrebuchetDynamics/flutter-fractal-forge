# AR Architecture Full Report — Flutter Fractal Forge

Date: 2026-02-18
Owner request: document current AR architecture so independent research can proceed.

## 1) Current Reality (Short Version)

The app does **not** use true AR world anchoring yet.

Current AR mode is a **camera-overlay compositor**:
- camera feed as background (`camera` plugin)
- fractal renderer drawn on top
- tap creates a **2D screen-space anchor offset**

It does **not** currently use:
- ARCore / ARKit session tracking
- plane detection from AR engine
- hit-test world transforms
- persistent world anchors
- depth occlusion mesh

---

## 2) Entry Flow

### 2.1 From viewer
- AR entry is opened in viewer:
  - `lib/features/viewer/fractal_viewer_screen.dart:390` (`_openArOverlay`)
  - wired from FAB controls at `:859`
- It passes the current `FractalController` into AR screen.

### 2.2 AR screen class
- `lib/features/ar/ar_overlay_screen.dart:116` (`class ArOverlayScreen`)

This means AR uses the current fractal module and params from the viewer context.

---

## 3) AR Rendering Pipeline (As-Built)

1. `CameraPreview` full-screen background.
2. Overlay stack in `RepaintBoundary` for fractal + frame + text.
3. Bottom AR controls panel for lock/anchor/quality/export.

### 3.1 Camera subsystem
- camera init and fallbacks:
  - `_initCamera` at `ar_overlay_screen.dart:208`
  - `_switchCamera` at `:328`
- Uses `camera` plugin only.

### 3.2 Anchor subsystem (current)
- state flag: `_anchorPlaced` at `:144`
- tap handler: `onTapUp` around `:530`
  - computes `localPosition - viewportCenter`
  - sets `_anchorPlaced = true`
  - sets `_overlayLocked = true`

This is **2D UI transform anchoring**, not 3D world anchor.

### 3.3 Fractal render source
- overlay content uses `FractalRenderer` (same rendering family as viewer)
- quality presets call:
  - `context.read<ArQualityStore>().getPreset()` (`:180`)
  - `controller.applyArQualityPreset(...)` (`:190`, `:737`)

---

## 4) Export Subsystem

### 4.1 Overlay snapshot
- `_exportOverlay` at `ar_overlay_screen.dart:777`
- captures overlay RepaintBoundary as PNG

### 4.2 Baked screenshot
- `_exportBaked` at `:817`
- `ArExportService` composites camera photo + overlay bytes
  - `lib/core/services/ar_export_service.dart`

### 4.3 Video
- `_exportVideo` at `:867`
- `ArVideoExporter` creates GIF fallback from image stream + overlay
  - `lib/core/services/ar_video_exporter.dart`

This is media composition, not AR-native recording.

---

## 5) Dependency / Platform Audit

## 5.1 Flutter dependencies
From `pubspec.yaml`:
- `permission_handler` (`line 20`)
- `camera` (`line 21`)
- `image` (`line 22`)

No AR session plugin currently in use (`ar_flutter_plugin`, `sceneview_flutter`, etc. absent).

### 5.2 Android app manifest
`android/app/src/main/AndroidManifest.xml` currently has:
- no `uses-feature android.hardware.camera.ar`
- no `meta-data com.google.ar.core required`

### 5.3 Android SDK config
`android/app/build.gradle.kts`:
- `minSdk = maxOf(flutter.minSdkVersion, 21)`

ARCore production path should be 24+.

### 5.4 iOS plist
`ios/Runner/Info.plist` currently lacks robust ARKit-specific setup (camera usage text exists only for photo-library add use case, not explicit AR camera rationale).

---

## 6) Why User-Observed Failure Is Expected

Given current architecture, these outcomes are expected:

1. Tap-to-anchor can appear inconsistent with user expectations because it is not plane hit-testing.
2. Fractal does not become physically world-locked via SLAM anchors.
3. Motion parallax and stability are UI-based approximation, not AR engine tracking.
4. “Anchor” wording implies true AR capability that backend currently does not provide.

---

## 7) Gap Matrix (Current vs True AR)

| Capability | Current | Needed for True AR |
|---|---|---|
| Camera feed | ✅ | ✅ |
| Fractal overlay | ✅ | ✅ |
| 2D tap placement | ✅ | optional |
| AR plane detection | ❌ | ✅ |
| AR hit test | ❌ | ✅ |
| World anchor object | ❌ | ✅ |
| World-locked drift resistance | ❌ | ✅ |
| Occlusion/depth alignment | ❌ | ✅ |
| AR-native anchor persistence | ❌ | optional/desired |

---

## 8) Migration Requirements (Engineering)

To move from overlay mode to true AR:

1. Add AR runtime dependency (cross-platform or split plugins).
2. Create AR session lifecycle manager (initialize/dispose/tracking state).
3. Enable horizontal + vertical plane detection.
4. Replace 2D tap handler with AR hit-test handler.
5. Create AR anchor from world transform.
6. Attach render node to anchor (fractal texture path required).
7. Rework exports to capture AR scene + composited overlays intentionally.
8. Add device capability checks and fallback to overlay mode when unsupported.

---

## 9) High-Risk Technical Unknowns (for Research)

1. Best plugin for **dynamic texture updates** from fractal renderer to anchored node.
2. Performance/thermal limits for live fractal texture refresh in AR scene.
3. Occlusion support maturity per plugin (ARCore depth / ARKit scene depth).
4. Cross-platform parity: anchor API shape differs significantly between ecosystems.
5. Stable integration strategy with current `FractalController` lifecycle.

---

## 10) Recommendation to Research Next

- Compare:
  - `ar_flutter_plugin(+ variants)`
  - Android `sceneview_flutter` + iOS `arkit_plugin`
- Verify exact support for:
  - textured plane node creation
  - runtime texture update from bytes
  - plane hit-test callbacks
  - persistent anchor APIs
- Decide on architecture:
  - **single cross-platform abstraction** vs **platform-specialized AR backends**

---

## 11) Bottom Line

Current implementation is a **camera-overlay AR simulation layer**. 
It is functional for compositing and exports, but it is not a true AR anchor system.

Your reported behavior is aligned with this architecture, not with a regression in ARCore/ARKit anchoring (because those engines are not yet integrated as the anchor authority).
