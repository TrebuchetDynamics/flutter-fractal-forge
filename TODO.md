# Flutter Fractal Forge — Execution TODO

Last updated: 2026-02-15
Owner: Sidon

## Architecture Direction (decided 2026-02-15)

**GPU-primary, CPU safety net.**
- GPU is the default renderer (196 pre-compiled fragment shaders, one per fractal)
- CPU fallback auto-activates via 2s health check when GPU output is invalid
- CPU path is maintenance-only (no further performance investment)
- GPU investment: coloring quality, smooth iteration, deep zoom, new formulas

---

## P0 — MUST SHIP NEXT

### 1) Dynamic iteration adjustment based on zoom — **NEW**
- [x] Increase max iteration slider beyond 500 (now 5000)
- [x] Automatically raise iteration count when zooming in (adaptive step-up in controller)
- [x] Adaptive logic: start low, progressively increase based on zoom growth
- [ ] Convergence detection: compare previous frame, stop when changes < threshold
- [x] Works on both GPU (shader uniform) and CPU fallback paths

### 2) GPU visual quality — smooth coloring + palette system
- [ ] Implement fractional/smooth escape-time coloring in all escape-time shaders (eliminate banding)
- [ ] Implement palette uniform system (pass palette as texture/uniform array to shaders)
- [ ] More gradient options + color cycling/animation support
- [ ] Allow user palette selection from viewer controls
- [ ] Add regression test: render canonical viewport, assert no banding artifacts

### 3) Play Store release polish
- [x] Play Store checklist doc created
- [ ] App icon finalized (adaptive icon + Play Store feature graphic)
- [ ] Store listing copy (title, short desc, full desc, screenshots)
- [ ] Privacy policy URL
- [ ] Content rating questionnaire
- [ ] Signing key + upload to Play Console
- [ ] Internal testing track → closed beta → production

### 4) Catalog expansion toward 200+
- [x] 196 escape-time fractals with GPU shaders
- [ ] Add PRD manifest loader (`assets/catalog/prd_catalog.json`)
- [ ] Add ID lock/integrity tests for full catalog
- [ ] Add filter/sort + list/grid toggle for large catalogs
- [ ] Add 4+ new fractal formulas (target 200+)

### 5) Export behavior hardening
- [x] Opening Export pauses auto-navigation and freezes frame
- [x] Separate Save vs Share actions
- [ ] Resume policy prompt after export
- [ ] Share flow QA: WhatsApp / Instagram / X / device gallery

---

## P1 — HIGH PRIORITY AFTER P0

### 6) Deep zoom: perturbation theory in GPU shaders
- [ ] Research perturbation + series approximation for Mandelbrot shader
- [ ] Implement reference orbit calculation (CPU) + delta iteration (GPU)
- [ ] Enable zoom beyond float32 precision wall (~10^7) on GPU
- [ ] CPU fallback remains for non-perturbation fractals at extreme zoom

### 7) AR real anchoring (wall/floor/table)
- [ ] Integrate true plane anchors (vertical + horizontal)
- [ ] Tap-to-place fractal on detected plane
- [ ] Keep overlay mode as fallback when ARCore/ARKit unavailable

### 8) Auto-Pilot navigation improvements
- [ ] Improve path smoothness and dwell behavior
- [ ] Accept manual pan/zoom corrections while auto mode runs
- [ ] Add quick actions: Accept framing / Reject and try another

### 9) In-app diagnostic logger enhancements
- [x] Core logger with export (text/JSON/share) — commit 5ae1c9e
- [x] Logs: lifecycle, GPU health, shader load, backend switches, user actions, state snapshots
- [ ] Add gesture logging (pan/zoom start/end with coordinates)
- [ ] Add performance metrics logging (frame time, fps)
- [ ] Persist log across app restarts (write to file)

### 10) GPU health check improvements
- [ ] Make detection more robust across devices
- [ ] Add fallback analytics to track GPU failures

---

## P2 — IMPORTANT PRODUCT POLISH

### 11) Preset management
- [ ] Delete preset
- [ ] Rename/edit preset
- [ ] Preset thumbnail generation

### 12) User-defined color palettes
- [ ] Allow saving/loading custom gradients

### 13) Bookmark/favorites for locations
- [ ] Save coordinates, zoom, formula, palette

### 14) Viewer controls ergonomics
- [ ] Make controls sheet snap/collapse more aggressively
- [ ] Move non-critical actions into compact overflow

### 15) Onboarding and accessibility
- [ ] Explain gestures + AR behavior clearly
- [ ] Improve screen-reader labels for catalog and controls

### 16) Stable sharing/export presets
- [ ] One-tap presets for Instagram feed/story, X, WhatsApp
- [ ] Keep exact frame lock from viewer to exported file

---

## DONE RECENTLY

- [x] In-app diagnostic logger with export (commit 5ae1c9e)
- [x] Fix GPU "Loading shaders..." stuck forever — _loading flag bug (commit 2066e43)
- [x] GPU debug report payload enhanced with health metrics (commit 2ec66a2)
- [x] CPU visual gate test (blockiness + luminance diversity)
- [x] CPU quality: zoom-scaled iterations + 2x2 AA refine pass (commit 7767213)
- [x] Renderer backend setting (Auto/CPU/GPU) with persistence (commit 2c24554)
- [x] CPU tile renderer (96px, center-first spiral, cancel-on-gesture)
- [x] 196/196 render audit passing
- [x] 64 palette support + horizontal palette selector
- [x] Home screen simplified; AR entry in viewer only

---

## CPU Path — Maintenance Only

The CPU renderer works and passes all tests. No further performance investment.
- CPU progressive tiles with preview→refine
- Persistent worker isolate
- Iteration buffer + proxy iterators for audit
- Maintained for: emulator testing, broken GPU fallback, deep zoom precision

---

## Future / Low Priority

- [ ] User-defined formulas at runtime (CPU interpreter or dynamic shader compilation)
- [ ] Video recording of zoom animations
- Dynamic runtime shader compilation — deferred, not needed for Play Store launch

---

## OUT OF SCOPE

- Arenaton implementation is out of scope for this repo/agent.
- Sidon works only on Flutter Fractal Forge + fractal tasks.

---

## Working agreement (Juan)

- Use multiple subagents for independent tracks in parallel.
- Send concise progress every ~30 minutes.
