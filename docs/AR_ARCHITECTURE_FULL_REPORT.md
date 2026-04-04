
Date: 2026-02-18

> Archived architecture report. The camera/AR path described below is not part of the current release scope.

## 1) Current Reality (Short Version)


- camera feed as background (`camera` plugin)
- fractal renderer drawn on top
- tap creates a **2D screen-space anchor offset**

It does **not** currently use:
- hit-test world transforms
- persistent world anchors
- depth occlusion mesh

---

## 2) Entry Flow

### 2.1 From viewer
  - `lib/features/viewer/fractal_viewer_screen.dart:390` (`_openArOverlay`)
  - wired from FAB controls at `:859`



---


1. `CameraPreview` full-screen background.
2. Overlay stack in `RepaintBoundary` for fractal + frame + text.

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


---

## 5) Dependency / Platform Audit

## 5.1 Flutter dependencies
From `pubspec.yaml`:
- `permission_handler` (`line 20`)
- `camera` (`line 21`)
- `image` (`line 22`)


### 5.2 Android app manifest
`android/app/src/main/AndroidManifest.xml` currently has:

### 5.3 Android SDK config
`android/app/build.gradle.kts`:
- `minSdk = maxOf(flutter.minSdkVersion, 21)`


### 5.4 iOS plist

---

## 6) Why User-Observed Failure Is Expected

Given current architecture, these outcomes are expected:

1. Tap-to-anchor can appear inconsistent with user expectations because it is not plane hit-testing.
2. Fractal does not become physically world-locked via SLAM anchors.

---


|---|---|---|
| Camera feed | ✅ | ✅ |
| Fractal overlay | ✅ | ✅ |
| 2D tap placement | ✅ | optional |
| World anchor object | ❌ | ✅ |
| World-locked drift resistance | ❌ | ✅ |
| Occlusion/depth alignment | ❌ | ✅ |

---

## 8) Migration Requirements (Engineering)


3. Enable horizontal + vertical plane detection.
6. Attach render node to anchor (fractal texture path required).

---

## 9) High-Risk Technical Unknowns (for Research)

1. Best plugin for **dynamic texture updates** from fractal renderer to anchored node.
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

---

## 11) Bottom Line

