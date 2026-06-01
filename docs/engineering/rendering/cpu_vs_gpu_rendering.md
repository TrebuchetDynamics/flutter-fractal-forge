# CPU vs GPU Fractal Rendering in Flutter (Decision + Playbook)

This document explains how to choose between CPU and GPU fractal rendering in Flutter, and how this repo implements a GPU-first renderer with a deliberate CPU fallback for stability/precision.

## Quick Checklist (TL;DR)

1. Prefer GPU fragment shaders for interactive viewing (`FragmentProgram` + `FragmentShader`).
2. Write shaders in Flutter runtime-effect style: `#include <flutter/runtime_effect.glsl>` and `FlutterFragCoord()`.
3. Keep uniforms float-indexed and stable; pass "iterations" as float and cast in-shader.
4. Avoid uniform-bounded loops; use a compile-time max and early-break (runtime-effect friendly).
5. Optimize shaders first: LOD for iterations during navigation, reduce branching in palettes, precompute constants.
6. Rendering many fractals: reuse the same `FragmentProgram`, but set uniforms per draw; lower iterations/resolution for thumbnails.
7. Keep interaction smooth: update uniforms from gestures, consider dynamic resolution during gestures, and isolate repaint to the renderer with `RepaintBoundary`.
8. Deep zoom needs a plan: float32 precision will break eventually; switch to a CPU precision path (or implement perturbation later).
9. CPU fallback should render into a pixel buffer (not per-pixel canvas ops); use isolates if you need it to scale.
10. Test on real devices early: emulator/driver behavior varies; measure shader compile stalls and frame pacing in profile mode.

## The Two Real Options In Flutter

### Option A: CPU rendering (Dart + pixel buffer)

**What it is**
- Compute the fractal on the CPU (ideally in an isolate).
- Write pixels into an RGBA buffer (`Uint8List`).
- Convert that buffer into a `ui.Image` (`decodeImageFromPixels`) and display it (`RawImage`).

**Pros**
- Can use `double`/`BigInt`/arbitrary precision on CPU (deep zoom correctness).
- Debugging is straightforward (normal Dart tools, unit tests).
- No shader language constraints.

**Cons**
- Hard to hit 60 FPS at full resolution with high iteration counts.
- Battery/thermal cost is usually worse for interactive full-screen rendering.
- If you update per gesture/frame, you need careful throttling/debouncing.

**Repo implementation**
- CPU fallback widget: `lib/features/renderer/cpu_fractal_renderer.dart`
- CPU formulas registry: `lib/features/renderer/cpu_formulas.dart`

Key implementation details in this repo's CPU path:
- Debounced re-render to avoid doing a full render on every micro-update.
- Double-precision math for deep zoom stability.
- 2x2 multi-sample anti-aliasing (configurable) for less grain.
- Validates frames for "nearly black" output and uses a safe fallback view.

### Option B: GPU rendering (FragmentProgram + fragment shader)

**What it is**
- Write a fragment shader in Flutter's runtime effect style.
- Flutter compiles it into a `FragmentProgram` and runs it per pixel on the GPU.
- Dart sets uniforms via `FragmentShader.setFloat(index, value)` in a fixed order.

**Pros**
- Massive parallelism: full-screen escape-time fractals animate smoothly.
- Excellent for interactive pan/zoom/parameter scrubbing.
- Scales to "many fractals" (thumbnails, grids) better than CPU.

**Cons**
- Float32 precision limits deep zoom (artifacts are inevitable past a threshold).
- Shader debugging is harder (limited introspection, platform differences).
- You must respect runtime-effect restrictions (uniform layout, loops, precision).

**Repo implementation**
- Shader painter: `lib/features/renderer/fractal_canvas.dart`
- Main renderer widget: `lib/features/renderer/fractal_renderer.dart`
- Shader assets: `shaders/*.frag` (declared in `pubspec.yaml`)

Key shader conventions used here:
- Runtime effect include: `#include <flutter/runtime_effect.glsl>`
- Pixel coordinates: `FlutterFragCoord().xy` (not `gl_FragCoord`)
- Uniforms are laid out as a flat float buffer. Shaders keep an explicit index map:
  - Example: `shaders/mandelbrot.frag`

## Recommendation (For This App): GPU First, CPU As A Targeted Fallback

For a fractal exploration app with real-time interaction and lots of fractal modes, the correct default is:
- **GPU for normal exploration**
- **CPU fallback only when the GPU path is known to be unreliable or imprecise**

This repo already follows that strategy:
- Backend selection logic: `lib/features/renderer/backend_policy.dart`
- Viewer wiring (manual toggle, GPU health probe, emulator guard, deep zoom): `lib/features/viewer/fractal_viewer_screen.dart`
- Deep-zoom thresholding: `lib/features/renderer/deep_zoom_precision_policy.dart`
- Capability notes: `renderer_backend_matrix.md`

CPU fallback is used when any of these are true:
- Forced via build flag (`FORCE_CPU_FALLBACK=true`).
- User manually requests the stable renderer.
- Device is an Android emulator (deterministic output policy).
- A GPU "health check" frame probe indicates invalid output.
- Zoom exceeds the per-module float32 precision threshold (deep zoom).
- Module is unsupported on the GPU path.

## Flutter Shader Reality Check (Corrections That Matter)

If you copy/paste typical desktop GLSL examples, you will hit Flutter-specific gotchas:

- Use `FlutterFragCoord()` from `flutter/runtime_effect.glsl` instead of `gl_FragCoord`.
- Don't rely on `uniform int` for parameters you set from Dart.
  - In practice, treat "iterations" as a `float` uniform and cast in shader.
- Avoid `for (int i = 0; i < uIterations; i++)` with a uniform upper bound.
  - Prefer a compile-time cap `const int MAX_ITERS = ...;` and early-exit when `i >= target`.
- Uniform ordering is not "by name".
  - It is **by float index**, and must stay aligned with the Dart side.
- Precision qualifiers matter:
  - Use `highp` for fractal coordinate math.
  - If you use `mediump`, keep it for color/palette/shading only (using it for coordinates will break deep zoom quickly).

## Minimal Mandelbrot Shader (Flutter Runtime Effect Style)

```glsl
#include <flutter/runtime_effect.glsl>
precision highp float;

uniform vec2  uResolution; // setFloat 0,1
uniform vec2  uCenter;     // setFloat 2,3
uniform float uScale;      // setFloat 4 (complex-plane units per pixel)
uniform float uMaxIter;    // setFloat 5

out vec4 fragColor;

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 c = uCenter + (fragCoord - 0.5 * uResolution) * uScale;

  vec2 z = vec2(0.0);

  const int MAX_ITERS = 1024;
  int maxIter = int(clamp(uMaxIter, 1.0, float(MAX_ITERS)));

  int it = 0;
  for (int i = 0; i < MAX_ITERS; i++) {
    if (i >= maxIter) break;
    if (dot(z, z) > 4.0) break;
    z = vec2(z.x*z.x - z.y*z.y, 2.0*z.x*z.y) + c;
    it = i + 1;
  }

  float t = float(it) / float(maxIter);
  fragColor = vec4(vec3(t), 1.0);
}
```

In this repo, the concrete "how to set uniforms" lives in each module's `setUniforms` callback:
- Module interface: `lib/core/modules/fractal_module.dart`
- Examples: `lib/core/modules/*_module.dart`

## Practical Performance Notes (What To Optimize First)

For GPU:
- Reduce branch divergence in palettes and shading where practical (see `../performance/SHADER_OPTIMIZATIONS.md`).
- Use LOD (iteration scaling) at low zoom and/or during gestures (see `../performance/PERFORMANCE.md`).
- Use a compile-time iteration cap and early break (runtime-effect friendly).
- Warm common shaders at startup to reduce first-frame "jank" (see `../performance/PERFORMANCE.md`).
  - Note: uniform updates are usually cheap; the real cost is per-pixel iteration work.

For CPU:
- Never paint per pixel with `Canvas.drawRect` loops.
- Compute into an RGBA buffer and upload as a single image.
- Prefer isolate computation and transfer pixel buffers efficiently.
- Debounce input changes; consider progressive refinement (fast preview, then refine).

## Coloring: Smooth Gradients Without Banding

Best practice for this style of app is to keep coloring on the GPU:
- Compute a smooth/continuous iteration value (log-based smoothing) in the shader.
- Map that value through a palette function (math palette or custom gradient stops).
- If you see gradient banding, add lightweight dithering in-shader (or prefer higher-precision pipelines where available).

Repo examples:
- Smooth coloring pattern: `shaders/mandel_step_smooth.frag` and `shaders/julia_gpu.frag`
- Palette infrastructure (texture or legacy stop uniforms): `lib/core/services/palette_service.dart`

## Deep Zoom: Why CPU Still Matters

Fragment shaders run in float32 on most targets. Even with `highp`, you only get ~7 significant digits, which means at sufficiently high zoom you will see:
- pixel "swimming"
- incorrect boundary detail
- banding/quantization artifacts in the geometry itself (not just color)

This repo's `DeepZoomPrecisionPolicy` (`lib/features/renderer/deep_zoom_precision_policy.dart`) flips to CPU at conservative per-fractal thresholds, because CPU can use `double` and stay stable longer.

If you later want GPU deep zoom beyond float32, look into perturbation/series approximation techniques (often implemented as a hybrid: CPU computes a reference orbit, GPU shades deltas).

## Validation And "Stable Renderer" UX

This repo treats "a fast wrong frame" as worse than "a slower correct-ish frame".
- GPU output is probed periodically with a tiny `RenderRepaintBoundary` capture pair and validated:
  - `lib/features/renderer/render_validation.dart`
  - Used in `lib/features/viewer/fractal_viewer_screen.dart`
- Users get release-safe copy like "Using stable renderer..." rather than internal engine labels:
  - `lib/features/renderer/backend_policy.dart`

## Open-Source Projects To Study (Ideas To Borrow)

Below is a reading list based on your curated set. Treat it as inspiration: implementations vary widely, and you should verify licenses and the current repo state before copying code.

| Project | Primary approach | What to study | How it maps to Flutter |
|---|---|---|---|
| Fractl (Rust/wgpu) | GPU compute + CPU variants | Backend layering, tiling/batching, precision modes (`f32`/`f64`) | Great for architecture ideas; Flutter GPU path will still be fragment shaders |
| Fractal Explorer (Web) | GPU fragment shader (GLSL/WebGL) | Uniform-driven zoom/pan, UI-to-shader plumbing | Closest conceptual match to `FragmentProgram` + uniforms |
| PyMandel (Python) | CPU (Numba/JIT-style optimization) | CPU optimization patterns, parallel loops | Useful if you build/expand the isolate-based CPU fallback |
| Fraqtive (C++) | CPU (SIMD/multi-core) | SIMD-friendly iteration loops, multi-thread scheduling | CPU fallback performance ideas (tile rendering, vectorization concepts) |
| XaoS (C) | CPU (incremental / reuse) | Reuse prior frames during pan/zoom, progressive refinement | Inspires "fast preview then refine" CPU fallback strategies |
| FlashMandel (Amiga) | CPU (extreme hand optimization) | How far low-level CPU optimization can go | Historical; mostly conceptual inspiration |
| Mandelbulber2 (C++) | 3D fractals (often GPU/OpenGL/OpenCL-style pipelines) | Raymarching/SDF shading, camera conventions, lighting models | Shader-side 3D patterns (raymarch) are directly portable in spirit |
| Fragmentarium (Qt) | GPU fragment shader (GLSL) | Many ready-made fractal shaders and coloring ideas | Shader snippets often adapt well to Flutter runtime effects |
| Fractol (C/OpenCL) | GPU compute (OpenCL) or CPU (varies by project) | Simple fractal engine structure and iteration kernels | Architecture ideas; direct OpenCL is not part of Flutter |

GPU-first (shader-based)
- Fragmentarium (Qt + GLSL): great source of fractal shader snippets and palette ideas.
- Mandelbulber2 (3D fractals): useful for raymarching/SDF shading patterns and 3D camera conventions.
- Web fractal explorers (Three.js/WebGL/Svelte): good examples of mapping UI gestures to shader uniforms.

Hybrid / multi-backend architecture
- Rust/wgpu "Fractl"-style projects: useful for how to structure backends, precision modes (`f32` vs `f64`), and tiling/batching work.

CPU-first (performance and deep zoom)
- Fraqtive (C++): study SIMD/vectorization patterns and multi-core scheduling.
- XaoS (C): study incremental rendering (reusing prior frames on pan/zoom) and adaptive refinement.
- CPU + JIT (Python/Numba-style): highlights how much "plain CPU" can improve with JIT + parallel loops.

How these map back to Flutter:
- Flutter fragment shaders are closest to "WebGL fragment shader explorers" and "Fragmentarium-style shader sketches".
- CPU deep zoom ideas (incremental refinement, multi-thread tiling, higher precision) are applicable to a Flutter CPU fallback isolate.
- Compute shader pipelines (wgpu/OpenCL) are conceptually useful, but Flutter does not expose general compute shaders directly; you'll typically implement GPU fractals as fragment shaders.

## Related Docs In This Repo

- Performance measurements and shader warm-up strategies: `../performance/PERFORMANCE.md`
- Shader optimization tactics (branchless palettes, LOD, etc.): `../performance/SHADER_OPTIMIZATIONS.md`
- Backend capability notes and deterministic fallback policy: `renderer_backend_matrix.md`
