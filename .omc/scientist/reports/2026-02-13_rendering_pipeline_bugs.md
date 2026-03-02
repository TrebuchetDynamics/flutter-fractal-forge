# Rendering Pipeline Bug Analysis

**Analysis Date:** 2026-02-13T18:25:34.293636

**Project:** Flutter Fractal Forge

## Summary

- **Total Bugs Found:** 11
- **Critical:** 2
- **High Priority:** 3
- **Medium Priority:** 3
- **Low Priority:** 3

## Critical Bugs

### CRITICAL-1: FragmentProgram shader objects never disposed - memory leak

**Location:** `lib/features/renderer/fractal_renderer.dart:133`

**Impact:** GPU memory leak. After switching between 8 fractals multiple times, GPU memory exhaustion possible.

**Fix:** Add _program?.dispose() in dispose() method before super.dispose()

---

### CRITICAL-2: No size validation in FractalCanvas.paint() - NaN/crash risk

**Location:** `lib/features/renderer/fractal_canvas.dart:19-30`

**Impact:** Widget layout edge case crashes. Shader division by zero. Black screen or GPU driver crash.

**Fix:** Add early return if size.width <= 0 || size.height <= 0 at start of paint()

---

## High Priority Bugs

### HIGH-1: New FragmentShader instance created every frame - performance degradation

**Location:** `lib/features/renderer/fractal_canvas.dart:20`

**Impact:** 60 FPS → ~30 FPS on mid-range devices. Increased CPU/GPU overhead. Stuttering during animations.

**Fix:** Cache shader instance in CustomPainter state, create once, reuse per frame

---

### HIGH-2: Zoom momentum unbounded - can reach NaN/Infinity

**Location:** `lib/features/renderer/fractal_renderer.dart:189-203`

**Impact:** Extreme zoom values cause precision loss, black screen, or shader artifacts. NaN propagates to shader uniforms.

**Fix:** Clamp decayedVelocity magnitude before applying. Add sanity check in _applyZoomMomentum().

---

### HIGH-3: Shader load race condition - multiple concurrent loads possible

**Location:** `lib/features/renderer/fractal_renderer.dart:240-305`

**Impact:** Visual bug: wrong fractal rendered. Rare but reproducible with rapid module switching.

**Fix:** Add module ID tracking. Compare module ID before setState() to reject stale loads.

---

