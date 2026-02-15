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

### 1) GPU visual quality — smooth coloring + palette system
- [ ] Add smooth/continuous escape-time coloring to all escape-time shaders (eliminate banding)
- [ ] Implement palette uniform system (pass palette as texture/uniform array to shaders)
- [ ] Allow user palette selection from viewer controls
- [ ] Add regression test: render canonical viewport, assert no banding artifacts

### 2) Play Store release polish
- [x] Play Store checklist doc created
- [ ] App icon finalized (adaptive icon + Play Store feature graphic)
- [ ] Store listing copy (title, short desc, full desc, screenshots)
- [ ] Privacy policy URL
- [ ] Content rating questionnaire
- [ ] Signing key + upload to Play Console
- [ ] Internal testing track → closed beta → production

### 3) Catalog expansion toward 200+
- [x] 196 escape-time fractals with GPU shaders
- [ ] Add PRD manifest loader (`assets/catalog/prd_catalog.json`)
- [ ] Add ID lock/integrity tests for full catalog
- [ ] Add filter/sort + list/grid toggle for large catalogs
- [ ] Add 4+ new fractal formulas (target 200+)

### 4) Export behavior hardening
- [x] Opening Export pauses auto-navigation and freezes frame
- [x] Separate Save vs Share actions
- [ ] Resume policy prompt after export
- [ ] Share flow QA: WhatsApp / Instagram / X / device gallery

---

## P1 — HIGH PRIORITY AFTER P0

### 5) Deep zoom: perturbation theory in GPU shaders
- [ ] Research perturbation + series approximation for Mandelbrot shader
- [ ] Implement reference orbit calculation (CPU) + delta iteration (GPU)
- [ ] Enable zoom beyond float32 precision wall (~10^7) on GPU
- [ ] CPU fallback remains for non-perturbation fractals at extreme zoom

### 6) AR real anchoring (wall/floor/table)
- [ ] Integrate true plane anchors (vertical + horizontal)
- [ ] Tap-to-place fractal on detected plane
- [ ] Keep overlay mode as fallback when ARCore/ARKit unavailable

### 7) Auto-Pilot navigation improvements
- [ ] Improve path smoothness and dwell behavior
- [ ] Accept manual pan/zoom corrections while auto mode runs
- [ ] Add quick actions: Accept framing / Reject and try another

### 8) In-app diagnostic logger enhancements
- [x] Core logger with export (text/JSON/share) — commit 5ae1c9e
- [x] Logs: lifecycle, GPU health, shader load, backend switches, user actions, state snapshots
- [ ] Add gesture logging (pan/zoom start/end with coordinates)
- [ ] Add performance metrics logging (frame time, fps)
- [ ] Persist log across app restarts (write to file)

---

## P2 — IMPORTANT PRODUCT POLISH

### 9) Preset management
- [ ] Delete preset
- [ ] Rename/edit preset
- [ ] Preset thumbnail generation

### 10) Viewer controls ergonomics
- [ ] Make controls sheet snap/collapse more aggressively
- [ ] Move non-critical actions into compact overflow

### 11) Onboarding and accessibility
- [ ] Explain gestures + AR behavior clearly
- [ ] Improve screen-reader labels for catalog and controls

### 12) Stable sharing/export presets
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

## OUT OF SCOPE

- Arenaton implementation is out of scope for this repo/agent.
- Sidon works only on Flutter Fractal Forge + fractal tasks.
- Dynamic runtime shader compilation (user-defined formulas) — future feature, not now.

---

## Working agreement (Juan)

- Use multiple subagents for independent tracks in parallel.
- Send concise progress every ~30 minutes.
