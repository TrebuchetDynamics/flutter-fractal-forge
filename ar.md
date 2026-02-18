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

### 2.4 “Anchor” model currently implemented
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
