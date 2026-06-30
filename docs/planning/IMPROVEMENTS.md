# Fractal Generation & Navigation — Improvement Backlog

Last updated: 2026-02-17  
Owner: Sidon

Priority tiers: **P0** (blocking quality), **P1** (major uplift), **P2** (polish), **P3** (research/future)

---

## FRACTAL GENERATION

### P0 — Blocking quality issues

#### G1 · Smooth escape-time coloring in GPU shaders
**Problem:** Current shaders use integer iteration count → visible color banding at boundaries.  
**Fix:** Implement fractional escape time via `smooth_iter = iter - log2(log2(|z|))`.  
Apply to all 196 escape-time shaders via a shared GLSL include.  
**Target:** Zero visible banding at any zoom level.  
**Files:** `assets/shaders/` (all `*_gpu.frag`), `lib/features/renderer/fractal_canvas.dart`

#### G2 · Palette passed as texture uniform (not hardcoded in shader)
**Problem:** Each shader hardcodes its own gradient. Changing colors requires recompiling 196 shaders.  
**Fix:** Pass a 256×1 RGBA texture as a sampler uniform (`uPalette`). Shader maps `smooth_iter → uv.x → texture sample`.  
**Target:** One palette change applies instantly to all fractals; user palettes work in GPU mode.  
**Files:** `assets/shaders/`, `lib/features/renderer/fractal_canvas.dart`

#### G3 · Iteration count auto-scaled by zoom on GPU
**Problem:** Shader uniform `uIterations` is set from `controller.params['iterations']` directly. At deep zoom (1e6+) boundaries need 2000+ iterations but the param slider tops at 5000 and the auto-scale only runs on the CPU path.  
**Fix:** In `FractalCanvas`, compute `effectiveIter = base + log2(zoom) * 48`, clamp to 8000, write to shader uniform — independent of the UI slider.  
**Target:** Boundaries stay crisp at all zoom levels without user touching the slider.  
**Files:** `lib/features/renderer/fractal_canvas.dart`

---

### P1 — Major quality uplift

#### G4 · Perturbation theory for deep GPU zoom
**Problem:** Float32 GPU shaders lose precision at zoom ≈ 1e7 (even with our raised threshold). The CPU fallback kicks in but is slow.  
**Fix:** Reference orbit algorithm — compute a high-precision orbit on CPU (double/quad precision), pass as texture uniform to GPU. GPU iterates small delta orbits around the reference using float32. Extends GPU range to ~1e14.  
**Techniques:** Series approximation (SA) to skip iterations, BLA (bilinear approximation) for speed.  
**Files:** New `lib/features/renderer/perturbation_controller.dart`, all Mandelbrot-family shaders  
**Note:** Mandelbrot first. Julia, Burning Ship, etc. each need their own reference orbit.

#### G5 · Orbit trap coloring method
**Problem:** Only escape-time coloring is implemented. Orbit traps produce dramatically different aesthetics (cross, circle, point attractors).  
**Fix:** Add `coloringMethod` parameter (enum: escapetime, orbitTrap, angle). In shader, track minimum distance from orbit to trap shape during iteration. Use that for coloring.  
**Files:** `assets/shaders/` (Mandelbrot family), `lib/core/models/fractal_parameter.dart`

#### G6 · Interior coloring (Mandelbrot set interior is pure black today)
**Problem:** All pixels that don't escape are rendered black. Interior structure (period detection, dwell bands) is invisible.  
**Fix:** Track period-2 detection (Brent's algorithm in shader). Map period/trap distance to a separate color ramp for the interior.  
**Files:** Mandelbrot, Julia shaders

#### G7 · Stripe Average Coloring (SAC)
**Problem:** Gradient banding even after smooth iteration — the color gradient has discrete visible steps under high zoom.  
**Fix:** Stripe Average Coloring accumulates `sin(iter)` partial sums during escape and blends with smooth iter for a smoother gradient transition.  
**Files:** All escape-time shaders

#### G8 · Multi-layer histogram equalization for color balance
**Problem:** At extreme zoom the color distribution becomes skewed — most pixels land in a small iteration range, wasting the palette.  
**Fix:** After each render, compute a histogram of iteration values (GPU readback or CPU sample). Remap the palette index curve to distribute color evenly. Update per frame or on zoom-settle.  
**Files:** `lib/features/renderer/fractal_canvas.dart`, new `lib/features/renderer/histogram_equalizer.dart`

#### G9 · Mandelbulb and 3D fractal GPU shaders
**Problem:** All 3D fractals (Mandelbulb, etc.) currently fall through to CPU (`moduleUnsupported` reason in `BackendPolicy`).  
**Fix:** Implement ray-marching signed-distance-function shaders for Mandelbulb and Mandelbox. Use a distance estimator to avoid divergence.  
**Files:** New `assets/shaders/mandelbulb_gpu.frag`, `lib/core/modules/mandelbulb_module.dart`  
**Cost:** High — ray marching SDF shaders are complex. 3D lighting (Phong/Blinn) needed.

#### G10 · Julia set parameter animation (morphing)
**Problem:** Julia sets are generated for a fixed `c` parameter. Animating `c` creates beautiful morphing animations but only works if the shader updates every frame.  
**Fix:** Add `uJuliaCX / uJuliaCY` as time-driven uniforms in Julia shaders (use `uTime` from the existing animation controller). Expose a `morphSpeed` parameter.  
**Files:** `assets/shaders/julia_gpu.frag`, `lib/core/modules/julia_module.dart`

---

### P2 — Polish and variety

#### G11 · Newton fractal family
Newton's method on `z^n - 1 = 0` produces colorful root-basin fractals. 4 standard ones (n=3,4,5,6) + Nova variant.  
Add GPU shaders for: `newton3`, `newton4`, `nova_mandelbrot`.

#### G12 · Lyapunov fractal
Completely different generation algorithm — uses logistic map stability. Visually distinct from escape-time fractals. One shader, parameterized sequence string (e.g. "AABAB").

#### G13 · IFS (Iterated Function System) fractals
Sierpinski triangle, Barnsley fern, Dragon curve — rendered via random iteration (chaos game). GPU-friendly: each thread runs independent random walks.

#### G14 · Buddhabrot rendering mode
Anti-Mandelbrot: instead of coloring by escape time, count how many orbits pass through each pixel. Produces a nebula-like image. CPU-only (requires many orbit traces). Run as a background task.

#### G15 · Color cycling animation
Shift the palette offset over time (`uPaletteOffset = mod(uTime * speed, 1.0)`) in the shader. Already nearly free once G2 (palette texture) is done.

---

## NAVIGATION & GESTURES

### P0 — Broken or incomplete

#### N1 · Double-tap zoom-in centers on tap point ✅ (fixed 2026-02-17)
Was firing at screen center instead of tap coordinate. Fixed in commit `5b9bb20`.

#### N2 · Two-finger tap zoom-out didn't fire ✅ (fixed 2026-02-17)
Race condition in `_onPointerUp` — single-finger handler ran before two-finger check. Fixed in commit `5b9bb20`.

#### N3 · GPU→CPU transition was abrupt ✅ (fixed 2026-02-17)
Added GPU snapshot crossfade + slow-mode progressive renderer in commit `6315d0e`.

---

### P1 — Major navigation improvements

#### N4 · Bookmark locations (save/restore coordinates)
**Problem:** Users can find beautiful spots but can't save them. Closing app loses the location.  
**Fix:** Long-press → "Save Location" in context menu. Saves `{pan, zoom, rotation, moduleId, params}` as a named preset. Show in a "My Locations" grid.  
**Files:** `lib/core/services/preset_store.dart`, `lib/features/viewer/fractal_viewer_screen.dart`

#### N5 · Animated zoom-to-point (GO button / deep-link)
**Problem:** Jumping to a saved coordinate is instantaneous (jarring).  
**Fix:** Implement a smooth animated flight path: interpolate zoom logarithmically, pan linearly, over a configurable duration (1–3s). Use `AnimationController` with `CurvedAnimation(curve: Curves.easeInOutCubic)`.  
**Files:** `lib/features/renderer/widgets/renderer/fractal_renderer.dart` (extend `_animateZoomTo`)

#### N6 · Coordinate HUD / coordinate input
**Problem:** No way to know or enter exact coordinates.  
**Fix:** Optional HUD overlay showing `Re: -0.7436438…  Im: 0.1318259…  Zoom: 3.2e5`. Tapping opens an input sheet for direct coordinate entry.  
**Files:** New `lib/features/viewer/coordinate_hud.dart`

#### N7 · Rotation lock toggle
**Problem:** Two-finger rotation is easy to trigger accidentally when zooming.  
**Fix:** Add a "Lock Rotation" toggle (icon button in viewer toolbar). When locked, `_rotationGestureActive` never becomes true and rotation stays at 0.  
**Files:** `lib/features/renderer/widgets/renderer/fractal_renderer.dart`, `lib/features/viewer/fractal_viewer_screen.dart`

#### N8 · Smooth deceleration on zoom fling (fix over-shoot)
**Problem:** Zoom fling (`_applyZoomMomentum`) uses a fixed 0.92 friction coefficient. At high zoom velocities this causes overshooting past min/max bounds.  
**Fix:** Apply rubber-band to zoom momentum the same way pan does — detect when zoom hits boundary and halve velocity rather than clamping hard.  
**Files:** `lib/features/renderer/widgets/renderer/fractal_renderer.dart`, `_applyZoomMomentum()`

#### N9 · History navigation (back/forward)
**Problem:** No way to undo a navigation. Users lose interesting views by accident.  
**Fix:** Maintain a circular buffer of the last 50 `{pan, zoom, rotation}` states. Two-finger swipe-left/right (or buttons) navigate the stack.  
**Files:** `lib/features/viewer/fractal_viewer_screen.dart` (history buffer already partially implemented)

#### N10 · Auto-Pilot improvements
**Problem:** Auto-explore follows a random walk that ignores visual interest — often ends up in black interior regions or featureless areas.  
**Fix:** Before committing a navigation step, sample the GPU render at ~10% scale and check `nonBlackRatio`. If < 0.15 (boring), skip to next candidate.  
**Secondary:** Smooth camera path (catmull-rom spline between waypoints instead of linear jumps).  
**Files:** `lib/features/auto_explore/auto_explore_service.dart`

---

### P2 — Polish

#### N11 · Haptic feedback calibration
Current: `mediumImpact` on double-tap, `lightImpact` on two-finger tap, `heavyImpact` on long-press. Add:  
- Subtle `selectionClick` when zoom hits min/max boundary (rubber-band snap)  
- `lightImpact` when rotation snaps back to 0° (if rotation lock is off and angle < 5°)

#### N12 · Keyboard navigation (desktop / foldable)
Arrow keys → pan, +/- → zoom, R → reset, S → save location.  
**Files:** Add `Focus` + `KeyboardListener` in `fractal_viewer_screen.dart`

#### N13 · Minimap overlay
Small thumbnail of the full fractal with a rectangle showing current viewport. Tap on minimap to navigate there.  
Render minimap using `CpuFractalRenderer` at 64×64.

#### N14 · Zoom depth indicator
A subtle vertical bar on the right edge showing current zoom level on a log scale (1× at top, 1e10 at bottom). Glows blue when in CPU slow-mode territory.

#### N15 · Pinch-to-rotate snap-to-axis
When rotation gets within 3° of 0°, 90°, 180°, 270° — snap with haptic. Similar to how Maps snaps to North.  
**Files:** `lib/features/renderer/widgets/renderer/fractal_renderer.dart`, `_onScaleUpdate()`

---

## PRECISION & DEEP ZOOM

### P1

#### D1 · Perturbation theory — see G4 above (cross-listed)

#### D2 · Float64 emulation in GLSL (double-double arithmetic)
**Problem:** GLSL doesn't support `double`. But two `float` values can emulate double precision via Dekker splitting (add and multiply with error compensation).  
**Fix:** Implement `vec2` as a double-double type in GLSL. Use for Mandelbrot shader coordinate calculation only. Extends GPU precision from ~1e7 to ~1e14 without perturbation theory.  
**Cost:** ~2× shader execution time. Trade-off vs perturbation theory.

#### D3 · CPU deep-zoom: arbitrary precision via `decimal` package
**Problem:** CPU path uses Dart `double` (64-bit, ~15 digits). At zoom > 1e14 this runs out.  
**Fix:** Integrate the `decimal` or `big_float` package for coordinate arithmetic. Use only for the center point calculation; pixel deltas can stay in double.  
**Files:** `lib/features/renderer/cpu_iterators.dart`, `lib/features/renderer/cpu_formulas.dart`

#### D4 · Deep zoom coordinate encoding in URL / preset
**Problem:** `double` JSON serialization loses precision for coordinates at zoom > 1e10.  
**Fix:** Serialize pan coordinates as strings (e.g. `"-0.74364388703715905"`) in presets and deep links.

---

## PERFORMANCE

### P1

#### P1 · Shader warm-up on app start
**Problem:** First time a fractal loads its shader, there's a visible compile stall (200–800ms).  
**Fix:** Pre-warm the 10 most popular shaders at app start (background isolate after first frame). Track popularity via usage counter in SharedPreferences.  
**Files:** `lib/features/renderer/widgets/renderer/fractal_renderer.dart` (`_programCache`), new warm-up service

#### P2 · Reduce render resolution during fast gesture
**Problem:** Full-res GPU render during fast pinch causes frame drops.  
**Fix:** During active gesture (`_onScaleUpdate` / `_onScaleEnd`), drop render to 50% scale (write a smaller viewport size uniform). Restore to full-res 200ms after gesture ends.

#### P3 · Tile-based GPU rendering for export
**Problem:** High-res export (4K+) exhausts GPU memory as a single draw call.  
**Fix:** For export render, split into 4×4 tiles, render each tile separately, stitch in CPU memory.  
**Files:** `lib/core/services/export_service.dart`

---

## Status summary

| Area | Items | P0 | P1 | P2 | P3 |
|------|-------|----|----|----|----|
| Fractal generation | 15 | 3 | 6 | 5 | 1 |
| Navigation | 15 | 3✅ | 7 | 5 | 0 |
| Precision/deep zoom | 4 | 0 | 4 | 0 | 0 |
| Performance | 3 | 0 | 3 | 0 | 0 |

3 of 3 P0 navigation items already shipped (2026-02-17).  
Next priority: **G1** (smooth coloring), **G2** (palette texture), **N4** (bookmark locations), **N9** (history navigation).
