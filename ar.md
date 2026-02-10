# AR Mode (Overlay) — Notes, Known Issues, Roadmap

Last updated: 2026-02-10

This document tracks the current AR overlay implementation, what is working, what is not, and the next improvements.

## What AR is (today)

AR in Flutter Fractal Forge is currently an **AR-like camera overlay**:

- Uses the device camera (via `camera` plugin) as the background.
- Renders the selected fractal as a movable/scalable/rotatable **2D “painting”** on top.
- This is **not** full ARCore plane detection/anchoring yet.

Entry point:
- Viewer App Bar → AR button → `lib/features/ar/ar_overlay_screen.dart`

## Current behavior

### Overlay manipulation
- Drag to move (1-finger)
- Pinch to scale (2-finger)
- Rotation supported (twist gesture), especially used for 3D modules

### Rendering pipeline
- AR overlay uses the same `FractalRenderer` widget (GPU shader output) as the viewer.
- AR applies an AR quality preset on entry.

### Background
- **Default is now opaque “painting”** (not transparent).
  - Reason: transparent background makes the set interior see-through, causing camera noise to show through and look like gray/static.

## Known issues (as reported by Juan)

1) **AR needs serious polish**
   - Render quality and anchoring feel not “real AR”.

2) **Gray/noisy look (previously)**
   - Root cause: transparent background + camera feed showing through interior regions.
   - Mitigation shipped: default `_transparentBackground = false` in AR.

3) **Overlay not anchored to surfaces**
   - Current implementation has no plane detection; overlay is “floaty”.

4) **AR panel is still intrusive**
   - Needs a more compact, collapsible control surface.

## Emulator limitations

Android emulators typically cannot provide real ARCore features (plane detection, anchors, lighting estimation).

What we *can* test on emulator:
- AR screen opens/closes without crashing.
- Permissions denied flow.
- Overlay UI widgets present.

What we *must* validate on real device (e.g., S24 Ultra):
- Plane detection stability
- Anchoring accuracy (wall/table)
- Camera characteristics (noise, exposure)
- Performance under real camera feed

## Roadmap (next steps)

### Phase A — Make overlay feel like a “real framed painting”
- Make AR controls panel smaller:
  - Collapsed by default
  - Quick actions only (opacity / lock / export)
  - Advanced options behind “more”
- Improve overlay interaction:
  - Optional snap-to-center
  - Optional snap-to-edges
  - More predictable scale/rotation handles

### Phase B — Surface placement (ARCore)
Goal: allow placing a fractal as a **wall painting** or **tabletop tile**.

- Add ARCore/Sceneform/Flutter AR package integration (TBD)
- Plane detection:
  - wall planes (vertical)
  - floor/table planes (horizontal)
- Anchors:
  - tap to place
  - persistent transform
- Lighting:
  - match brightness
  - subtle shadow / vignette

### Phase C — Export improvements
- Export “baked” camera+overlay composite image
- Export overlay-only PNG with alpha
- Optional watermark toggle

## Debug checklist for AR reports
When a report comes in, capture:
- module id + name
- palette index
- transparent background on/off
- device model + Android version
- whether the issue happens always or intermittently

---

## Relevant files
- `lib/features/ar/ar_overlay_screen.dart`
- `lib/features/renderer/fractal_renderer.dart`
- `lib/features/viewer/fractal_viewer_screen.dart` (AR entry button)
- `lib/core/services/ar_quality_store.dart`
- `lib/core/models/ar_quality_preset.dart`
