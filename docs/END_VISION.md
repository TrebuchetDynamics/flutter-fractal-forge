# END_VISION.md — Flutter Fractal Forge
*Authored: 2026-02-17 by Sidon (fractal domain lead)*

> Archived vision document. It captures an aspirational scope and older counts, including ideas that are not in the current release. Use `README.md`, `TODO.md`, and `status.md` for the current state.

---

## 1. Product Summary

**Flutter Fractal Forge** is a GPU-accelerated interactive fractal explorer for Android. It lets anyone navigate an infinite mathematical universe — zooming, panning, rotating, and tilting into 209 distinct fractal structures — with smooth real-time rendering driven by custom GLSL fragment shaders on Impeller/Vulkan.

**What nothing else does:**
- 209 fractals in a single app across 6 categories (escape-time, IFS, L-system, cellular automaton, strange attractor, custom) — the largest curated catalog in any mobile fractal app
- GPU-primary rendering with automatic CPU safety net — users never see a loading spinner or crash from GPU failure; the app silently falls back and logs the switch
- Perturbation theory deep zoom on escape-time fractals extending GPU zoom range to ~10³⁰ before float precision breaks down
- Smooth escape-time coloring + sampler2D palette texture on all 10 core escape-time shaders — color bands eliminated at all zoom levels
- In-app diagnostic logger exportable as text/JSON — fractal coordinates, backend decisions, shader compile times, GPU health — for power users and bug reports

---

## 2. Target User

| Attribute | Profile |
|---|---|
| Age | 16–40 primary; 40+ secondary (STEM professionals) |
| Context | Phone in hand with 5–10 minutes; also extended sessions on couch |
| Entry motivation | "I've heard of the Mandelbrot set" or saw a fractal on social media |
| Retention driver (day 30+) | Discovery of new fractals in catalog; saved presets; wallpaper use; sharing renders |
| Device | Mid-range Android (Samsung A-series, Pixel 6a); minSdk 21; typically 3× DPR |
| Accessibility | Must work with TalkBack; touch targets ≥ 48 × 48 dp; no color-only information |

**Retention requires:**
- First session: successfully navigating into and out of a fractal in under 60 seconds
- Week 1: discovering 3+ fractals they didn't know existed
- Week 4: having set a wallpaper or shared an export at least once

---

## 3. Core Feature Set — What "Done" Means

### Catalog
**Done:** 209 modules render correct thumbnail images (320 × 320 px CPU-rendered), load in ≤ 1 s on mid-range device, are searchable by name and alias, are grouped by category with section headers, support both grid (3–6 columns) and list views, and remember the user's view preference across sessions.  
*Not done: thumbnails load but show wrong fractal (proxy/fallback image).*

### Renderer
**Done:** GPU path is default for all escape-time modules; CPU path auto-activates within 2 s if GPU health probe fails with ≥ 6 consecutive failing frames (DeepZoomHysteresis). First GPU frame paints in ≤ 150 ms on API 29+ real device. No black screen is ever shown to the user for > 2 s without a visible loading indicator. Backend switch is logged and optionally surfaced in the debug pane.  
*Not done: first frame may be black while shader compiles.*

### Viewer
**Done:** App bar shows fractal name, back button, and three action icons (controls, presets, export). All five gesture types (pan, pinch-zoom, double-tap, two-finger tilt, two-finger rotate) respond within one frame of input on a mid-range device. History back button restores the previous module and view state. Coordinate display shows current pan (x, y) and zoom level. Viewer state persists through app backgrounding.  
*Not done: no coordinate display widget visible to user by default.*

### Gestures
**Done:** Pan (1-finger drag) moves the fractal world in the direction of drag with no perceptible lag. Pinch-zoom (2-finger) anchors to the midpoint between fingers with momentum on release. Double-tap zooms 2× anchored to the tap coordinate. Two-finger tilt (vertical delta) adjusts X-axis rotation clamped to ±67.5°. Two-finger rotate (angular delta) locks out when zoom/pan is primary gesture (`_kIntentionalRotationThreshold = 0.12 rad`). All gestures have rubber-banding at pan limits (±3.0 world units). Mouse wheel zoom works on desktop.  
*Not done: rotation and tilt simultaneously feel unnatural on real devices — needs feel tuning.*

### Formulas / FRM
**Done:** Custom FRM formula language is parsed and renders correctly in the viewer. FRM editor allows typing, saving, and switching formulas. At least the core formula set (Mandelbrot, Julia, Burning Ship, Celtic, Buffalo, Tricorn, Multibrot) is editable by users.  
*Not done: no FRM editor surface exposed in production UI — formula switching only through catalog.*

### Presets
**Done:** User can save named presets (module + pan + zoom + iterations + julia-C). Presets appear in the presets sheet sorted by date created. Tapping a preset restores all parameters exactly. Factory presets ship for at least Mandelbrot (×3) and Julia (×3). Deleting a preset requires confirmation.  
*Not done: no preset export/import; no preset sharing.*

### History
**Done:** Every fractal the user opens is logged in a session history list (module ID + timestamp + thumbnail). User can navigate backward through history from the viewer via a back button that restores the previous view state. History persists across cold starts (stored in SharedPreferences).  
*Not done: history UI surface not yet accessible from the catalog screen; only accessible from viewer.*


### Minimap
**Done:** Small inset viewport showing where the current view sits within the full fractal extent. Tapping the minimap teleports to that location. Minimap updates in real time as the user pans/zooms.  
*Not done: minimap has no test coverage and is visually unpolished (no border, no backdrop).*

### Wallpaper
**Done:** User can export the current view as a wallpaper-optimized PNG (home screen and/or lock screen sizes). The export applies a configurable vignette/gradient overlay. On Android 8.1+ the WallpaperManager API is called; on earlier versions the user is directed to the gallery.  
*Not done: live wallpaper (animated) is out of scope for 1.0.*

### Onboarding
**Done:** First-launch walkthrough covers: (1) how to navigate (pan/zoom), (2) how to browse the catalog, (3) one CTA to explore a featured fractal. Onboarding is skippable. Onboarding version is persisted; updated versions re-trigger for existing users.  

### Export
**Done:** User can export the current fractal view as PNG, JPG, or WebP at screen / HD / Full HD / 4K / custom resolution. Export file is written to the device gallery (MediaStore on API 29+). Share sheet can be triggered directly from export. Export metadata (EXIF: fractal type, parameters, creation date) is embedded in PNG.  
*Not done: actual file write to MediaStore not tested on emulator (MediaStore requires real device for full integration test).*

### Settings
**Done:** Renderer backend preference (Auto / CPU only / GPU only debug). Accessibility options (high contrast, reduced motion). Language selection (EN, ES — ES has 7 untranslated strings). App version shown. Debug log export.  
*Not done: no reset-all-settings option; no font size preference.*

---

## 4. Critical User Journeys

### CUJ-1: First Launch
1. App opens → catalog visible, ≥ 4 module cards rendered within 3 s
2. No onboarding skip: walkthrough plays, 3 steps, skippable
3. User taps Mandelbrot card → viewer opens, GPU fractal rendering within 2 s
4. User pinches to zoom → fractal zooms smoothly
5. Back → catalog. **Done: no blank state, no crash.**

### CUJ-2: Browse Catalog
1. Open app → catalog with 209 modules in grid view
2. Type "Burn" in search → filtered to Burning Ship variants in ≤ 300 ms
3. Switch to list view → same modules, section headers visible
4. Clear search → full catalog restored
5. **Done: search responds ≤ 300 ms; view toggle persists; no blank state.**

### CUJ-3: Gestures (pan / zoom / rotate / tilt)
1. In viewer: 1-finger drag → fractal pans; rubber-bands at limit
2. 2-finger pinch → zoom in/out anchored to midpoint; momentum on release
3. Double-tap → 2× zoom anchored to tap point
4. 2-finger vertical delta → tilt (X-rotation); clamped to ±67.5°
5. 2-finger rotate (circular motion, > 0.12 rad threshold) → rotate view
6. **Done: all 5 gesture types respond; no freeze; rubber-banding respected.**

### CUJ-4: Change Formula
1. In viewer → tap ≡ controls → Formula selector visible
2. Tap "Celtic" → fractal switches; GPU shader loads within 300 ms on cache hit
3. **Done: module switch is instant after first compile; no black frame > 150 ms.**

### CUJ-5: Save History / Preset
1. User navigates to a beautiful Mandelbrot location (pan/zoom)
2. Taps bookmark → Presets sheet → "Save Preset" → types name → saved
3. Opens another fractal, returns to presets → taps saved preset → view restored exactly
4. **Done: preset round-trips pan + zoom + module + julia-C exactly (±1e-6).**

### CUJ-6: Export / Share
1. In viewer → tap download icon → Export sheet opens
2. Selects PNG / Full HD → taps Export
3. File appears in device gallery; share sheet opens
4. **Done: file created, EXIF embedded, share sheet appears, no crash.**

### CUJ-7: Set Wallpaper
1. Export sheet → Wallpaper tab → Home Screen
2. Vignette style applied → Export
3. WallpaperManager called (API 27+) or gallery deeplink (older)
4. **Done: wallpaper set without leaving the app on API 27+.**

2. Camera permission dialog → Grant
3. Fractal renders over camera at 50% opacity
4. User pinches to zoom fractal overlay
5. Back → returns to viewer
6. **Done: no crash; camera releases cleanly on exit.**

---

## 5. Performance / Quality Bar

| Metric | Target | Rationale |
|---|---|---|
| First GPU frame (real device, API 29+) | ≤ 150 ms | User perceives < 200 ms as instant |
| First GPU frame (emulator, SwiftShader) | ≤ 500 ms | SwiftShader ~3× slower |
| Shader cache hit frame time | ≤ 5 ms | Module switches feel instant |
| Sustained FPS (2D fractal, mid-range) | ≥ 30 fps | Smooth enough for gesture navigation |
| Cold start to catalog visible | ≤ 3 s | P90 on Pixel 6a |
| Crash rate (Google Play Vitals) | < 0.5% sessions | Store listing requirement |
| ANR rate | < 0.1% sessions | Store listing requirement |
| Accessibility | WCAG AA | TalkBack labels on all interactive elements; 48 × 48 dp touch targets |
| Localization | EN complete; ES ≥ 95% | 7 ES strings currently missing |
| APK/AAB install size | ≤ 60 MB AAB | Current: 55.7 MB ✓ |

---

## 6. Explicit Out of Scope for 1.0

- **Live / animated wallpaper** — requires WallpaperService, separate APK entry point
- **3D real-time navigation** — Mandelbulb and Mandelbox are CPU-only 2D projections for 1.0
- **Social / sharing account** — no user accounts, no cloud sync, no leaderboard
- **Fractal audio** — no sonification
- **FRM formula editor UI** — formula switching via catalog only; FRM editor is a dev tool
- **iPad / iOS** — Android-only for 1.0
- **Offline map / GPS fractals** — no location integration
- **Multiplayer / collaborative zoom** — no networking
- **Video export** — static image export only; video is a future milestone
- **Preset sharing via URL / QR** — out of scope; deep link scheme exists but not productized
