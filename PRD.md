# PRD - Flutter Fractals (Android, Free)

## 1) Product statement
A free Android app for exploring many fractals with high-performance GLSL fragment shader rendering, sliders, and auto-animations, plus exports (including transparent PNG and short baked AR videos) for sharing/creation.

## 2) Goals / Non-goals
### Goals
- Large catalog of fractal "modes" with consistent UI patterns.
- Smooth navigation (pan/zoom/rotate) + responsive parameter changes.
- Presets + "randomize" to get good-looking results quickly.
- Auto-animate parameters (looping, easing, tempo).
- Export/share images and short videos.
- EN + ES localization at launch.
- High-performance rendering using GLSL fragment shaders (Skia/Impeller via `flutter_shaders` or `ImageShader`).
- Parameter locking to allow granular randomization (e.g., randomize geometry but keep colors).
- Share flow that creates a standardized filename (e.g., `FractalName_Date.png`).

### Non-goals (for MVP)
- iOS release.
- Accounts/cloud sync.
- Community marketplace.
- World-anchored AR (ARCore plane detection/occlusion) - later.

## 3) Target users & use cases
- Casual users: "Show me cool fractals" -> presets + autoplay.
- Hobbyists: tweak parameters precisely, save favorites, export high-res.
- Creators: generate visuals for videos/thumbnails, AR overlays.

## 4) Key user flows
1. Open app -> Explore fractal catalog.
2. Select a fractal -> Viewer.
3. Explore: gestures + sliders + palette + auto-animate.
4. Save preset.
5. Export/share image.
6. Switch to AR mode -> camera background + fractal overlay.
7. Export/share baked AR video (<= 15s).

## 5) MVP scope (must ship)

### 5.1 Fractal catalog
Minimum required fractals:
- Mandelbrot (2D)
- Julia (2D)
- Newton fractal (2D)
- Burning Ship (2D)
- Mandelbulb (3D)

Additionally in MVP:
- Include other fractals already present in `flutter_fractals/`, but standardize them behind a common module interface (see section 9).

### 5.2 Viewer
- 2D: pan + pinch-zoom.
- 3D (Mandelbulb): rotate/orbit (implementation-dependent) + zoom.
- Controls (bottom sheet):
  - Per-fractal parameter sliders (schema-driven)
  - Quality control (iterations / steps / samples)
  - Palette selector
  - Reset view
  - Randomize
  - Parameter locking (lock icons next to Geometry vs Styling/Palette groups)
  - Undo/Redo (history stack for last 10 parameter changes)
  - Snapshot button (quick save to gallery without full export menu)
- Progressive rendering:
  - Dynamic resolution scaling: render at 0.5x pixel ratio during gestures, snap to 1.0x or 2.0x (high quality) when static
- Auto-animate:
  - Play/pause
  - Speed
  - Select animated parameters
  - Loop: wrap + ping-pong
  - Easing: linear + smooth (at least)

### 5.3 Presets
- Built-in presets: >= 5 per required fractal.
- User presets stored locally (name + params + camera + palette + thumbnail).

### 5.4 Export (images)
- PNG export at selectable resolution (e.g., 1080p/1440p; 4K optional).
- Transparent export:
  - Background = Opaque / Transparent.
  - Transparent PNG preserves alpha.
  - Shaders must support an alpha output channel (not just `vec3` color).
  - UI toggle: "Premultiplied Alpha" (on/off).
- Share sheet integration with standardized filename (e.g., `FractalName_Date.png`).

## 6) AR (MVP = "easy AR" / AR-0)

### 6.1 Definition
AR-0 = camera background + fractal overlay (not world-tracked AR).

### 6.2 Features
- Camera preview background.
- Fractal overlay above camera.
- Overlay transform gestures:
  - Drag to move
  - Pinch to scale
  - Two-finger rotate (2D rotation)
- Overlay controls:
  - Opacity slider
  - Lock overlay toggle
  - Background mode: opaque/transparent (for overlay-only exports)
- (Optional) Checkerboard preview when transparent enabled.

### 6.3 Permissions
- Camera permission with clear rationale.
- AR mode disabled gracefully if denied.

## 7) Short video export (MVP)

### 7.1 AR video (screen recording approach)
- Method: capture the composite Flutter view (camera texture + shader layer) via a view recorder / surface frame grabber.
- Constraint: resolution matches the device screen aspect ratio.
- Duration: max 15s. Presets: 5s / 10s / 15s.
- Resolution: 720p default; 1080p optional if the device can sustain it.
- Audio: muted (MVP).

### 7.2 Nice-to-have: overlay-only alpha video
- Only if straightforward; otherwise defer.

### 7.3 High-quality loop export (non-AR)
- Method: frame-by-frame off-screen rendering + FFmpeg stitching (`ffmpeg_kit` or similar).
- Benefit: perfect 60fps loops even if the device lags during live preview.
- Format: MP4 (H.264), seamless loop.

## 8) Localization (EN/ES)
- All UI strings via Flutter localization (ARB) for `en` and `es`.
- Module `id` is stable and language-independent.

## 9) Architecture requirements (refined for shaders)
Rendering must use GLSL fragment shaders (Skia/Impeller) via `FragmentProgram` / `GlslFragmentProgram`. Avoid `CustomPainter`/Canvas paths for fractal rendering.

Suggested `FractalModule` interface:
- `String id`, `String name`
- `FractalDimension dimension` (2D/3D)
- `String fragmentShaderPath`
- `List<UniformParam> params` (Float, Color, Vec2, Vec3)
- `Preset defaultPreset`, `List<Preset> builtInPresets`
- `Preset thumbnailPreset` (consistent catalog thumbs)
- `Widget controlBuilder(...)` (optional: custom widget for complex inputs like Mandelbulb rotation)

`UniformParam`:
- `name`, `uniformLocation`
- `min`, `max`, `default`
- `isInteger` (for iterations)

## 10) Quality bar / acceptance criteria
- Shader compilation time < 200ms on startup.
- No crashes during rapid slider scrubbing + zooming.
- Auto-animate runs 10+ minutes without memory growth.
- Exported images match framing and palette.
- Transparent exports composite cleanly (no black halos; correct premultiplied-alpha handling).
- Visuals: no banding artifacts in gradients (dither in shader or use 32-bit color where supported).
- UX: Android Back gesture closes the Palette/Settings sheet before exiting the Viewer.
- AR mode:
  - Camera starts reliably on common devices.
  - Overlay transforms feel responsive.
  - Baked AR video exports successfully and matches on-screen view.
  - Thermals: AR mode auto-dims screen or throttles frame rate if thermal state reaches Critical.

## 11) Risks / constraints
- GPU-heavy fractals + camera can overheat devices -> implement quality presets + throttling.
- Android device camera quirks -> need robust start/stop + fallback.
- Video export (view capture + off-screen rendering + FFmpeg) is the highest technical risk and will require device-specific tuning.

## 12) Analytics & Privacy
- Privacy: no collection of camera data or personal images. All processing is on-device.
- Analytics: track "Most Used Fractal" and crash reports (Firebase Crashlytics) to prioritize optimization.

## 13) Implementation priority (MVP roadmap)
1. Core engine: set up `GlslFragmentProgram` boilerplates and the `FractalModule` architecture.
2. Fractals: port Mandelbrot and Julia first to test the engine.
3. UI: build the dynamic slider system based on the schema.
4. Export: implement image export (easy).
5. AR: implement camera preview + overlay (harder).
6. Video: implement FFmpeg binding for video export (hardest).

## 14) Status (as of 2026-02-04)
Implemented
- In-app FFmpeg via `ffmpeg_kit_flutter_min_gpl` for AR baked video export; no external `ffmpeg` binary needed.
- AR baked video composition now scales to 720p on the short side by default.
- Export progress UI added for PNG + AR exports; buttons disabled during export.
- Exports now save to a dedicated export directory (Android Pictures/FlutterFractals when available, documents fallback).
- Added Julia + Burning Ship 2D fractal modules with shader support and schema-driven controls.
- GIF fallback retained for AR video export failures.

Remaining / TODO
- Verify FFmpeg kit build sizes and ABI coverage on real Android devices.
- Consider MediaStore integration for truly public gallery visibility on Android 10+.
- Add more presets and tuned default framing for the new Julia/Burning Ship modules.
- Optional: encode audio into AR exports and improve progress reporting during FFmpeg encode.
