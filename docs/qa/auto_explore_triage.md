# Auto-Explore ("Autopilot") Triage Report
**Date:** 2026-02-13 17:15 CST  
**Issue:** "Autopilot doesn't work" (Juan's report)

## Root Cause

**Auto-explore boundary scoring only supports 3 fractals:**
- `mandelbrot`
- `julia`
- `burning_ship`

**Affected:** 194 other catalog fractals fall back to mandelbrot calculations, producing incorrect boundary scores and poor/no exploration.

## Evidence

**File:** `lib/features/auto_explore/auto_explore_service.dart:419-443`

```dart
int _iterations(
    Vector2 pos, String moduleId, Map<String, Object> params, int maxIter) {
  switch (moduleId) {
    case 'julia':
      final cr = _getDouble(params, 'juliaCReal', -0.8);
      final ci = _getDouble(params, 'juliaCImag', 0.156);
      return _julia(pos.x, pos.y, cr, ci, maxIter);
    case 'burning_ship':
      return _burningShip(pos.x, pos.y, maxIter);
    case 'mandelbrot':
    default:  // ← 194 fractals use wrong calculation here
      return _mandelbrot(pos.x, pos.y, maxIter);
  }
}
```

**Impact:**
- Works correctly: mandelbrot, julia, burning_ship (3 fractals)
- Broken/degraded: all other catalog fractals (194 fractals)
- Symptom: Auto-explore finds no interesting boundaries or uses wrong criteria

## Reproduction Steps

1. Open any non-mandelbrot/julia/burning_ship fractal (e.g., "Phoenix", "Celtic", "Tricorn")
2. Tap auto-explore button (compass icon in FAB stack)
3. Observe: exploration uses mandelbrot boundary calculations instead of fractal's actual formula
4. Result: Poor target selection, no meaningful exploration

## User Experience

**For mandelbrot/julia/burning_ship:**
- ✅ Auto-explore works as designed
- Finds high-variance boundaries
- Zooms toward interesting regions

**For all other fractals:**
- ❌ Auto-explore uses wrong math
- Boundary scores based on mandelbrot, not actual fractal
- Appears broken or ineffective

## Fix Options

### Option 1: Disable for Unsupported Fractals (Quick)
Hide auto-explore button when `moduleId` not in `['mandelbrot', 'julia', 'burning_ship']`.

**Pros:** Honest UX, no false expectations  
**Cons:** Feature unavailable for 98.5% of catalog

**Implementation:**
```dart
// In fractal_viewer_screen.dart
bool _shouldShowAutoExplore() {
  final id = controller.module.id;
  return ['mandelbrot', 'julia', 'burning_ship'].contains(id);
}

// Replace:
if (_autoExploreService != null)
// With:
if (_autoExploreService != null && _shouldShowAutoExplore())
```

### Option 2: Generic CPU Fallback (Medium)
For unsupported fractals, use CPU renderer to sample iterations at grid points.

**Pros:** Works for all 197 fractals  
**Cons:** Slower (CPU-bound), may cause UI jank

**Implementation:**
Add CPU fallback in `_iterations()`:
```dart
default:
  // Use CPU renderer for unknown fractals
  return _cpuFallbackIterations(pos, moduleId, params, maxIter);
```

### Option 3: GPU-Based Boundary Detection (Large)
Use GPU shader feedback to detect boundaries for any fractal.

**Pros:** Fast, works for all fractals, leverages existing GPU pipeline  
**Cons:** Complex implementation, requires shader modifications

**Estimated effort:** 1-2 days

## Recommendation

**Short-term (P0):** Option 1 — Hide button for unsupported fractals  
**Long-term (P2):** Option 2 or 3 — Extend support to all catalog fractals

## Acceptance Criteria

**Option 1 implementation:**
1. Auto-explore button visible ONLY for mandelbrot/julia/burning_ship
2. Other fractals: button hidden, no confusion
3. Update tooltip/docs to clarify supported fractals

**Testing:**
1. Open mandelbrot → button visible, works
2. Open phoenix → button hidden
3. Open julia → button visible, works
4. Open celtic → button hidden

## Next Steps

1. Implement Option 1 (hide button for unsupported fractals)
2. Commit + test on emulator
3. Rebuild APK
4. Send to Juan with clear changelog: "Auto-explore now only shows for fractals it actually supports"

---

**Status:** Root cause identified, fix options documented, awaiting approval to implement Option 1.
