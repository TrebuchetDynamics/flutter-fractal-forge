# CPU Formula Coverage Limitation

## Overview

As of v1.0, the **CPU rendering engine** (used for thumbnails and deep-zoom fallback) implements **8 out of 197** available fractal formulas.

The GPU renderer is complete (100% coverage), but the CPU fallback path is not.

## Impact

1. **Thumbnails**: In the Catalog, fractals without a specific CPU implementation use a generic **Mandelbrot** thumbnail as a placeholder. This is marked with a "Preview approximate" badge.
2. **Deep Zoom**: If a user zooms past the float32 precision limit (~1e-7) on a non-implemented fractal, the renderer will **not** switch to CPU high-precision mode. It will remain on the GPU, potentially showing pixelated artifacts.
3. **Autopilot**: The autopilot's "interesting spot" finder relies on CPU calculations. For non-implemented fractals, it may struggle to find optimal zoom locations.

## Implemented Formulas (CPU)

The following 8 formulas have full CPU parity with their GPU counterparts:

1. `mandelbrot`
2. `julia`
3. `burning_ship`
4. `celtic`
5. `buffalo`
6. `tricorn`
7. `multibrot3`
8. `phoenix`

## Future Plan

We plan to reach 100% parity in Phase 2. The priority order for implementing remaining formulas is based on usage analytics (e.g., Nova, Lambda, Magnet).
