# BLOCKER REPORT — Formula Coverage Limitation
**Date:** 2026-02-13 17:35 CST  
**Tasks:** Thumbnail Match & Sizing + Autopilot Fix  
**Status:** BLOCKED on formula implementation coverage

---

## Root Cause

**Both CPU thumbnail generator and autopilot boundary detector implement only 8 fractal formulas out of 197 catalog entries.**

### Formula Coverage Matrix

| Component | Formulas Implemented | Coverage | Fallback Behavior |
|-----------|---------------------|----------|-------------------|
| CPU Thumbnail Generator | 8 | 4.1% | Mandelbrot iteration with palette variation |
| Autopilot Boundary Detector | 8 (after fix) | 4.1% | Mandelbrot iteration (incorrect boundaries) |
| GPU Shaders | 197 | 100% | N/A (blocked on emulator) |

**Implemented formulas (8):**
1. mandelbrot
2. julia
3. burning_ship
4. celtic
5. buffalo
6. tricorn
7. multibrot3
8. phoenix

**Not implemented (189):** nova, fatou, gamma_fractal, lambda, magnet_type_1/2/3, cactus, astroid, deltoid, eisenstein, benesi, bicomplex, bouali, arneodo, aizawa, arnold_cat, barnsley_fern, dragon_curve, sierpinski_carpet, apollonian_gasket, ammann_beenker, etc.

---

## Evidence: Thumbnail Mismatch

### Sample Audit (20 Random Catalog Entries)

```bash
cd /home/xel/git/flutter-fractal-forge
head -200 lib/core/modules/builders/escape_time_catalog.dart | grep "id: '" | sed "s/.*id: '\(.*\)',/\1/" | head -20
```

| Fractal ID | CPU Implementation | Match Status |
|------------|-------------------|--------------|
| mandelbrot | Fallback (is Mandelbrot) | ✓ Correct |
| burning_ship | Explicit case | ✓ Correct |
| tricorn | Explicit case | ✓ Correct |
| celtic | Explicit case | ✓ Correct |
| buffalo | Explicit case | ✓ Correct |
| multibrot3 | Explicit case | ✓ Correct |
| nova | Mandelbrot fallback | ✗ MISMATCH |
| nova_julia | Mandelbrot fallback | ✗ MISMATCH |
| fatou | Mandelbrot fallback | ✗ MISMATCH |
| gamma_fractal | Mandelbrot fallback | ✗ MISMATCH |
| perpendicular_mandelbrot | Mandelbrot fallback | ✗ MISMATCH |
| lambda | Mandelbrot fallback | ✗ MISMATCH |
| magnet_type_1 | Mandelbrot fallback | ✗ MISMATCH |
| magnet_type_2 | Mandelbrot fallback | ✗ MISMATCH |
| magnet_type_3 | Mandelbrot fallback | ✗ MISMATCH |
| power_sum | Mandelbrot fallback | ✗ MISMATCH |
| cactus | Mandelbrot fallback | ✗ MISMATCH |
| astroid | Mandelbrot fallback | ✗ MISMATCH |
| deltoid | Mandelbrot fallback | ✗ MISMATCH |
| eisenstein | Mandelbrot fallback | ✗ MISMATCH |

**Match rate: 6/20 (30%)**  
**Mismatch count: 14/20 (70%)**

### Current Thumbnail Quality (Not Black, But Wrong Formula)

```
mandelbrot: 128x128, 243 unique colors ✓
burning_ship: 128x128, 443 unique colors ✓
nova: 128x128, 220 unique colors (but renders as Mandelbrot) ✗
cactus: 128x128, 228 unique colors (but renders as Mandelbrot) ✗
magnet_type_1: 128x128, 280 unique colors (but renders as Mandelbrot) ✗
```

Thumbnails are **visually acceptable** (not black, good colors) but **formula-mismatched** for 189/197 entries.

---

## Evidence: Autopilot Formula Coverage

### Before Fix (Commit 2f79245)
- Supported: mandelbrot, julia, burning_ship (3 formulas)
- Autopilot hidden for other 194 fractals via button visibility check

### After Fix (Commit 0b1b6c0)
- Supported: mandelbrot, julia, burning_ship, celtic, buffalo, tricorn, multibrot3, phoenix (8 formulas)
- Autopilot visible for all fractals but uses Mandelbrot fallback for 189/197

**Improvement:** 3 → 8 formulas (167% increase)  
**Remaining gap:** 189/197 fractals still use incorrect boundary calculations

---

## Attempted GPU Workaround

**Goal:** Use GPU shaders (100% formula coverage) to generate thumbnails  
**Issue:** Emulator GPU (SwiftShader) produces 99.8% black pixels despite clean shader compilation  
**Evidence:** `docs/thumbnail_integrity_report.md`, commit 2775c07  

**GPU thumbnail sample:**
```
mandelbrot: 21 unique colors, 65381/65536 black pixels = 99.8%
burning_ship: 21 unique colors, 65381/65536 black pixels = 99.8%
```

**Status:** Blocked on emulator hardware limitation. Requires real Android device.

---

## Options to Unblock

### Option A: Implement All 197 Formulas (Complete Fix)

**Approach:** Extend CPU renderer and autopilot with all catalog formulas

**Effort estimation:**
- Each formula: 10-30 lines of iteration logic
- 189 remaining formulas × avg 20 lines = ~3,780 lines
- Time estimate: 1-2 days (translate shader GLSL to Dart, test each)

**Files to modify:**
1. `test/generate_catalog_thumbnails_test.dart` — add cases to `_renderFractal` switch
2. `lib/features/auto_explore/auto_explore_service.dart` — add cases to `_iterations` switch

**Example formula to implement (nova):**
```dart
case 'nova':
  // z → (z - 1) * z^(n-1) + c
  // Need to extract 'power' param, implement complex power, etc.
```

**Risk:** Some formulas are complex (magnet, lambda, phoenix variants with parameters).

**Acceptance:**
- Thumbnail match rate: 197/197 (100%)
- Autopilot works correctly for all 197 fractals

---

### Option B: GPU Thumbnails on Real Device (Hardware-Dependent)

**Approach:** Run GPU thumbnail generator on real Android device with hardware GPU

**Requirements:**
- Physical Android device connected via ADB
- Run `integration_test/generate_gpu_thumbnails_test.dart` on device
- Pull thumbnails to assets/catalog_thumbs/

**Blockers:**
- No real device currently available
- Juan has device but unclear if connected/accessible to agent

**Acceptance:**
- GPU thumbnails: 197/197 correct formulas
- Autopilot: Still requires Option A implementation

---

### Option C: Ship Current State + Document Limitation (Deferred Fix)

**Approach:** Ship with 8 correct formulas, document the limitation, plan future work

**Current state:**
- Thumbnails: 8 correct, 189 Mandelbrot fallback with palette variations
- Autopilot: 8 correct boundary detection, 189 approximate (Mandelbrot-based)
- Visual quality: All thumbnails have distinct colors and visible structure

**Documentation:**
- Add `docs/formula_coverage_limitation.md` explaining 8/197 implementation
- Update catalog UI to badge correctly-implemented fractals
- Roadmap: Extend to 20 most-used formulas (nova, lambda, magnet, etc.)

**Acceptance:**
- Transparent about limitation
- Plan for incremental improvement
- Ship immediately with partial fix

---

## Recommendation

**Immediate (by EOD):** Option C — Ship current state with transparency

**Short-term (next week):** Option A partial — Extend to 20 most-used formulas

**Long-term (when device available):** Option B — GPU thumbnails for perfect match

---

## Current Deliverables (With Limitations)

**Commit:** `0b1b6c0`

**Autopilot Fix:**
- ✅ Extended from 3 → 8 formulas (celtic, buffalo, tricorn, multibrot3, phoenix added)
- ✅ Works correctly for 8 fractals
- ⚠️ Uses Mandelbrot approximation for remaining 189 fractals

**Thumbnails:**
- ✅ 199 thumbnails generated (197 catalog + 2 custom modules)
- ✅ All have distinct colors (200-443 unique colors each)
- ✅ Correct formula for 8 fractals
- ⚠️ Mandelbrot fallback for remaining 189 fractals

**Test Status:**
- Unit/Widget: 305 pass, 1 skip, 0 fail
- Analyzer: 0 errors, 4 warnings (pre-existing, unrelated), 483 info

---

## Exact Blocker

**Cannot achieve "Manual audit: at least 19/20 matching" requirement with current formula coverage (6/20 = 30% match rate).**

**Blocker is:** CPU formula implementation coverage (8/197 = 4.1%)

**Unblock requires:** Option A (implement all formulas) OR Option B (real device GPU) OR Link approval of Option C (ship with limitation documented).

**Awaiting decision.**

---

**Files Modified:**
- `lib/features/auto_explore/auto_explore_service.dart` — Added 5 formulas
- `lib/features/viewer/fractal_viewer_screen.dart` — Reverted button hiding
- `DELIVERY_2026-02-13.md` — Updated status

**Evidence Paths:**
- CPU implementation: `test/generate_catalog_thumbnails_test.dart:207-248` (switch statement)
- Autopilot implementation: `lib/features/auto_explore/auto_explore_service.dart:419-567` (switch + formulas)
- Catalog entries: `lib/core/modules/builders/escape_time_catalog.dart` (197 entries)
