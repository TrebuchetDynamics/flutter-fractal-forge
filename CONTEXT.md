# Flutter Fractal Forge Context

Flutter Fractal Forge is a fractal exploration app centered on GPU-first rendering with honest fallback paths when deep zoom exceeds the current preview path.

## Language

**Precision Ladder**:
The ordered set of render paths used as zoom depth increases: realtime GPU, extended GPU preview, then CPU precision. It is the source of truth for deep-zoom render-path copy and routing.
_Avoid_: Scattered thresholds, backend toggle

**Extended GPU Preview**:
A GPU render path that extends useful deep zoom beyond ordinary float32, currently through double-float Mandelbrot or perturbation shaders. It is preview-grade unless a later refine path proves exactness.
_Avoid_: Exact GPU, CPU fallback

**CPU Precision**:
The stable renderer path used when the precision ladder decides the GPU preview paths are insufficient or unavailable. It is slower, but it is the current exact-intended deep-zoom path.
_Avoid_: Slow mode, fallback-only mode

## Example Dialogue

Developer: “At 1e10 zoom, should Julia jump to CPU?”
Domain expert: “No. Julia has Extended GPU Preview, so the Precision Ladder should keep interaction on GPU and describe it as Deep GPU.”

Developer: “When an unknown 2D module crosses its threshold?”
Domain expert: “The Precision Ladder should move to CPU Precision after hysteresis, because no extended preview path is known.”
