# PRD - Flutter Fractals (Android, Free)

## 1) Product statement

Fractal Forge is a Flutter application for exploring mathematical systems, tuning views, and exporting images. The owner selected the current README/backlog as the active scope baseline on 2026-10-11. The accepted release contract below adds the shared Android/web/Linux journey. Older conflicting requirements remain historical or deferred until explicitly reaccepted.

## Active release contract

Status: Accepted

Owner decision: Juan Tamez accepted this contract in the 2026-10-11 repository interview. The current `README.md` and `TODO.md` govern active scope. Conflicting older PRD requirements remain historical or deferred until explicitly accepted again. This section records the newly accepted release outcome. It does not claim that qualification is complete.

### Outcome and users

People exploring Fractal Forge must be able to find a compelling system, customize its view, understand its mathematics or stated limits, and export an image. Visual appeal, trustworthy descriptions, and reliable precise controls are all required. None replaces the others.

### Acceptance example

On Android, web, and Linux desktop, a user can:

1. Browse and search the catalog, then open representative 2D and 3D systems.
2. Change parameters and navigate predictably.
3. Inspect accurate current-formula text or an explicit unverified/inspired qualification.
4. Export a nonblank PNG matching the edited view and selected export settings.

The journey must complete without a crash or silent placeholder substitution. Existing IDs, favorites, and saved presets must remain intact. An approximate catalog preview is not proof of an exported mathematical render.

### Scope and exclusions

- Android, web, and Linux must each meet the complete journey bar. Platform-specific save mechanisms can differ.
- Unverified and inspired entries can remain available with clear qualifications. Do not imply that they are certified formulas or exact geometric constructions.
- This contract does not require certification of every shader, macOS/Windows qualification, new historical MVP features, or a product rename.
- Existing accepted backlog work, privacy policy, compatibility guarantees, and active ownership remain in force. The interview does not authorize implementation, publication, or deployment of the new qualification tasks.

### Legacy requirement classification

| Requirement or historical claim | Current classification |
|---|---|
| Browse, customize, mathematical descriptions and PNG export | Active release outcome. Verify through `REL-JOURNEY-01-WEB`, `REL-JOURNEY-02-LINUX`, and `REL-JOURNEY-03-ANDROID` in `TODO.md`. |
| Stable IDs, favorites and saved presets | Active compatibility constraint in those same tasks. |
| Parameter locking, a premultiplied-alpha UI toggle, and at least five built-in presets for each required fractal | Historical requirements unless independently present in the current backlog. This decision adds no new implementation obligation. Existing controls and presets remain supported. |
| Startup shader compilation below 200 ms and ten-minute animation memory stability | Historical numerical gates. Reliable controls and crash-free completion remain active, but this interview accepts no new latency or endurance threshold. |
| Remote usage analytics/Firebase Crashlytics | Historical proposal, not approved. The current README privacy promise remains active. |
| Camera overlays, short-video/MP4 export and deferred AR work | Historical or deferred. Not added to this release journey. Existing implemented tools are not removed. |
| Physical Android PNG destination/gallery verification | Active verification for the Android journey. Existing MediaStore behavior must be observed rather than inferred from widget tests. |
| Wallpaper verification and expanded viewer-history integration | Preserve their existing backlog classification. They are not newly required by this image-export journey. |
| Human Spanish review | Historical qualification remains unclaimed. Existing EN/ES support is preserved. This interview does not add a human-review release gate. |
| Every catalog fractal individually certified before release | Superseded for this release by the owner's explicit permission to retain clearly qualified unverified/inspired entries. New-formula quality gates in the current backlog remain unchanged. |

### Execution frontier

- Web first within this plan: the backend matrix records browser export as unqualified. Prove the complete journey rather than another build-only smoke.
- Linux next: reuse native integration and export checks, then verify actual saved artifacts and current-formula behavior.
- Android next: verify the same journey and actual device storage/gallery output. An emulator-only result must not be presented as physical-device qualification.
- These platform slices are independent and have no fabricated cross-platform dependencies. Existing global queue priorities and active workers are unchanged.
- Completion requires recorded per-platform results. A source check, passing widget test, or successful build alone does not close this release goal.

### Evidence and remaining gaps

`docs/engineering/test-plan.md#accepted-cross-platform-release-journey` owns the acceptance checks. `docs/engineering/rendering/renderer_backend_matrix.md` records dated backend evidence, not current full parity. The new journey is unverified on all three targets as a complete release contract.

Graph evidence: a fresh local code-only Graphify scan of `lib/features/export/` queried `ExportOptionsSheet`, `ExportOptions`, `ExportResolutionSummary`, and `ExportSheetSubmission`. It found the option/submission/summary relationships at `export_options_sheet.dart:13,28,46` and `export_resolution_summary.dart:8,19`. Coverage is partial: services, journey tests, and document semantics are outside that graph. The extractor reported duplicate labels and two self-loops. Source checks, not graph inference, establish the qualification gaps.

Skill application: `interview-me` resolved the scope, combined outcome, platform set and review threshold one question at a time. `spec-driven-development` turns the owner-approved PNG example and failure boundaries into an observable acceptance contract without adding a competing spec. `documentation-and-adrs` records these product decisions here without a new architectural ADR. `planning-and-task-breakdown` creates bounded platform outcome tasks with artifact checks. `frontend-ui-engineering` preserves responsive interaction, honest captions and saved-state compatibility. `repo-docs` reconciles the canonical ledger and runs its consumer gate. The optional `hard-blockers` skill was unavailable, so blocker reconciliation uses the installed repo-docs contract and existing entry format.

## 2) Goals / Non-goals (historical MVP)
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

- Method: deferred. If revisited, use a platform-native video encoder rather than bundling FFmpeg.
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
- Native MP4 export is deferred; if revisited, platform encoder integration will require device-specific tuning.

## 12) Analytics & Privacy
- Privacy: no collection of camera data or personal images. All processing is on-device.
- Analytics: track "Most Used Fractal" and crash reports (Firebase Crashlytics) to prioritize optimization.

Current implementation differs: `CrashReporter` stores local diagnostics, and `pubspec.yaml` declares no remote analytics or crash-reporting SDK. The owner resolved `BLK-20261005-004` in favor of the current README/backlog. The remote-analytics proposal is historical and remains unapproved.

## 13) Implementation priority (MVP roadmap)
1. Core engine: set up `GlslFragmentProgram` boilerplates and the `FractalModule` architecture.
2. Fractals: port Mandelbrot and Julia first to test the engine.
3. UI: build the dynamic slider system based on the schema.
4. Export: implement image export (easy).
6. Video: evaluate platform-native MP4 encoding after the GIF workflow proves insufficient.

## 14) Fractal Catalog Roadmap (100+ Fractals)

Long-term goal: Comprehensive fractal encyclopedia. Each fractal validated individually before release.

### Historical implementation checklist (not current catalog coverage)
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

## 15) Status (as of 2026-08-25)

### Implemented
- 1014 production fractal modules plus 1 scientific visualization in the live catalog (1022 debug/test registry modules including 7 diagnostics), including Mandelbrot, Julia, Burning Ship, Phoenix, Mandelbulb, and many more (counts are locked by `test/catalog/catalog_id_integrity_test.dart`)
- Camera Looper GIF export; native MP4 encoding is deferred
- Android image export uses MediaStore (Pictures/FractalForge); physical-device gallery verification remains unverified
- Schema-driven controls per fractal
- No minimap feature is present in the current tree
- Debug overlay for shader troubleshooting
- Live Fourier analysis, finite-grid uncertainty laboratory, and Fourier Music
- 50+ sub-agent improvements (haptics, stats, video export, accessibility)

### Known Issues
- ~~**CRITICAL: Flutter 3.38+ Impeller shader rendering**~~ — **RESOLVED** (2026-04-05). The black-screen was caused by SkSL-incompatible `%` and `clamp(int, int, int)` operators in shaders; replaced with integer-division modulo and `float(clamp(...))` patterns. All 3D and escape-time shaders compile and render on GPU.

### Remaining / TODO
- See `TODO.md` for current gaps and `docs/planning/PRD.md` for the historical readiness snapshot; this status section is dated 2026-08-25
- Evaluate platform-native Android MP4 encoding only if GIF export proves insufficient
- Physical Android device verification of MediaStore export and gallery visibility

### Open question: active product scope

**Resolved 2026-10-11:** the owner chose the current backlog/README as the active baseline. Conflicting older requirements remain historical or deferred. See [Active release contract](#active-release-contract), resolved `BLK-20261005-004` in `BLOCKERS.md`, and `DOC-PRD-001` in `TODO.md`.
