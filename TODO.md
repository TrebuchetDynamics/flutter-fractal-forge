# Flutter Fractal Forge — Execution TODO

Last updated: 2026-02-11
Owner: Sidon

This is the **active execution plan** (not idea dumping). Items are prioritized and tracked by status.

---

## P0 — MUST SHIP NEXT

### 1) AR real anchoring (wall/floor/table) — **IN PROGRESS**
- [ ] Integrate true plane anchors (vertical + horizontal) instead of overlay-only placement
- [ ] Tap-to-place fractal on detected plane
- [ ] Auto choose best plane by largest stable area in view (wall/floor/table)
- [ ] Keep overlay mode as fallback when ARCore/ARKit unavailable
- [ ] Device validation checklist on S24 (wall lock, drift, relocalization)

### 2) Export behavior hardening — **IN PROGRESS**
- [x] Opening Export pauses auto-navigation and freezes frame
- [x] Separate Save vs Share actions
- [ ] Resume policy prompt after export (resume auto-pilot or stay manual)
- [ ] Share flow QA: WhatsApp / Instagram / X / device gallery

### 3) Deep zoom quality + precision fallback — **IN PROGRESS**
- [x] GPU→CPU fallback policy added for key fractals
- [x] CPU supersampling + smoother coloring added
- [ ] Tune per-fractal fallback thresholds on device
- [ ] Add on-screen “High precision mode” indicator
- [ ] Validate no visible handoff jumps during pinch zoom

### 4) Catalog redesign + 200 PRD rollout (with previews) — **IN PROGRESS**
- [x] Stable catalog IDs introduced (`core.<module_id>`)
- [x] Thumbnail previews wired per item (deterministic preview)
- [ ] Add PRD manifest loader (`assets/catalog/prd_catalog.json`)
- [ ] Add ID lock/integrity tests for 200 list
- [ ] Add filter/sort + list/grid toggle for large catalogs
- [ ] Map full 200 PRD entries to runtime modules/status

---

## P1 — HIGH PRIORITY AFTER P0

### 5) Auto-Pilot navigation + user corrections
- [ ] Improve path smoothness and dwell behavior
- [ ] Accept manual pan/zoom corrections while auto mode runs
- [ ] Add quick actions: Accept framing / Reject and try another
- [ ] Persist correction bias per fractal type

### 6) Grain/noise reduction (GPU path)
- [ ] Improve smooth coloring near escape boundary
- [ ] Reduce palette banding/noise at high iterations
- [ ] Add regression test scene for noise score comparisons

### 7) Stable sharing/export presets
- [ ] One-tap presets for Instagram feed/story, X, WhatsApp
- [ ] Keep exact frame lock from viewer to exported file
- [ ] Verify EXIF/metadata persistence policy

---

## P2 — IMPORTANT PRODUCT POLISH

### 8) Preset management
- [ ] Delete preset
- [ ] Rename/edit preset
- [ ] Preset thumbnail generation

### 9) Viewer controls ergonomics
- [ ] Make controls sheet snap/collapse more aggressively
- [ ] Move non-critical actions into compact overflow

### 10) Onboarding and accessibility
- [ ] Explain gestures + AR behavior clearly
- [ ] Improve screen-reader labels for catalog and controls

---

## DONE RECENTLY

- [x] Home screen Explore/AR tabs removed; AR entry stays in viewer
- [x] Gesture sync improved (1 finger pan, 2 finger zoom feel)
- [x] AR panel made less intrusive (collapsed bar + reorganized controls)
- [x] 64 palette support + horizontal palette selector

---

## OUT OF SCOPE (explicit)

- Arenaton implementation is out of scope for this repo/agent.
- Sidon works only on Flutter Fractal Forge + fractal tasks.

---

## Working agreement (Juan)

- Use multiple subagents for independent tracks in parallel.
- Send concise progress every ~30 minutes:
  - Done
  - In progress
  - Blocked
  - Next APK/tests
