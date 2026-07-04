# PRD - Flutter Fractals (Android, Free)

## 1) Product statement

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

## 3) Target users & use cases
- Casual users: "Show me cool fractals" -> presets + autoplay.
- Hobbyists: tweak parameters precisely, save favorites, export high-res.

## 4) Key user flows
1. Open app -> Explore fractal catalog.
2. Select a fractal -> Viewer.
3. Explore: gestures + sliders + palette + auto-animate.
4. Save preset.
5. Export/share image.

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


### 6.1 Definition

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

## 7) Short video export (MVP)

- Method: capture the composite Flutter view (camera texture + shader layer) via a view recorder / surface frame grabber.
- Constraint: resolution matches the device screen aspect ratio.
- Duration: max 15s. Presets: 5s / 10s / 15s.
- Resolution: 720p default; 1080p optional if the device can sustain it.
- Audio: muted (MVP).

### 7.2 Nice-to-have: overlay-only alpha video
- Only if straightforward; otherwise defer.

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
  - Camera starts reliably on common devices.
  - Overlay transforms feel responsive.

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
6. Video: implement FFmpeg binding for video export (hardest).

## 14) Fractal Catalog Roadmap (100+ Fractals)

Long-term goal: Comprehensive fractal encyclopedia. Each fractal validated individually before release.

### Current Implementation: 6/105
- ✅ Mandelbrot (2D)
- ✅ Julia (2D)
- ✅ Burning Ship (2D)
- ✅ Phoenix (2D)
- ✅ Mandelbulb (3D)
- ⬜ 100 more planned...

### Category Breakdown

**I. Escape-Time (Complex Plane) - 25 fractals**
Mandelbrot, Julia, Burning Ship, Phoenix, Tricorn, Celtic, Buffalo, Perpendicular, Lambda, Magnet I/II, Nova, Druid, Multibrot, Inverse Mandelbrot, Glynn, Simonbrot, Talis, Manowar, Spider, Shark Fin, Zircon Zity, Collatz, Eisenstein, Popcorn

**II. Newton/Root-Finding - 10 fractals**
Newton (z³-1), Newton (sin), Newton (General), Halley's, Schröder's, Secant, Fatou, Nova Julia, Magnet Newton, Householder

**III. Strange Attractors - 20 fractals**
Lorenz, Rössler, Hénon, Ikeda, Tinkerbell, Clifford, Peter de Jong, Svensson, Gumowski-Mira, Pickover, Thomas', Halvorsen, Rabinovich-Fabrikant, Dadras, Chen, Lü Chen, Aizawa, Duffing, Gingerbreadman, Lozi

**IV. IFS & Geometric - 26 fractals**
Sierpinski (Triangle/Carpet/Pentagon/Tetrahedron), Menger Sponge, Jerusalem Cube, Koch (Snowflake/Anti/Quadratic), Cesàro, Dragon Curves, Levy C, Barnsley Fern, Cyclosorus, Canopy, Pythagorean Tree, Cantor, Vicsek, Hexaflake, Pentaflake, Apollonian Gasket, Ford Circles, Steiner Chain

**V. L-Systems & Space-Filling - 9 fractals**
Hilbert (2D/3D), Peano, Moore, Gosper, Sierpinski Arrowhead, McWorter's, Penrose Tiling, Ammann-Beenker

**VI. 3D Raymarching - 10 fractals**
Mandelbulb, Mandelbox, KIFS, Quaternion Julia, Cubic Mandelbrot, Bulbils, Hartverdrahtet, Kleinian, Menger (DE), Hybrids

**VII. Stochastic & Cellular - 5 fractals**
Buddhabrot, Anti-Buddhabrot, Nebulabrot, DLA, Wolfram Rule 30

### Implementation Priority

🎯 **Immediate** (reuse Mandelbulb raymarcher):
1. Mandelbox - box folding, similar distance estimation
2. KIFS - kaleidoscopic mirrors, stunning visuals

**Phase 1** (2D escape-time, minimal changes):
Tricorn, Multibrot, Celtic, Buffalo, Nova

**Phase 2** (Newton-type, new coloring):
Newton z³-1, Halley's

**Phase 3** (Attractors, particle rendering):
Lorenz, Clifford, de Jong

**Phase 4** (IFS, CPU/compute shader):
Sierpinski, Koch, Barnsley Fern

**Phase 5** (Stochastic):
Buddhabrot, Nebulabrot

### Validation Process
Each new fractal must pass:
1. `flutter analyze` - zero errors
2. `flutter test` - all tests pass
3. Emulator visual validation (screenshot)
4. Real device testing
5. Performance check (60fps target)
6. Export verification (PNG/video)

---

## 15) Status (as of 2026-02-07)

### Implemented
- 974 production fractal modules in the live catalog (981 debug/test registry modules including 7 diagnostics), including Mandelbrot, Julia, Burning Ship, Phoenix, Mandelbulb, and many more
- In-app FFmpeg via `ffmpeg_kit_flutter_min_gpl` for video export
- Dedicated export directory (Android Pictures/FlutterFractals)
- Schema-driven controls per fractal
- Minimap navigation overlay
- Debug overlay for shader troubleshooting
- 50+ sub-agent improvements (haptics, stats, video export, accessibility)

### Known Issues
- **CRITICAL: Flutter 3.38+ Impeller shader rendering**
  - Fragment shaders show black screen on both emulator and real devices
  - Impeller opt-out deprecated (Flutter ignores manifest setting)
  - Options: downgrade Flutter to 3.19, CPU fallback, or wait for fix

### Remaining / TODO
- Fix Impeller shader compatibility issue
- Add 99 more fractals per roadmap (Section 14)
- Verify FFmpeg kit on real Android devices
- MediaStore integration for Android 10+ gallery visibility
