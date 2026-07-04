# Fluid mode research for Fractal Forge

## Method and limits

Sources checked: Google Play listing snapshot for `games.paveldogreat.fluidsimfree`, Pavel Dobryakov's MIT-licensed WebGL Fluid Simulation repo, NVIDIA GPU Gems 38, and rforge OpenAlex/arXiv search. Google Play HTML only exposed a short description in machine-readable metadata; rforge hit arXiv rate limiting on one query.

## Bottom line

Do not add fluid code to each fractal shader. The reusable path is a post-process layer: render any fractal normally, then pass the rendered pixels through one `ImageFilter.shader` fluid-warp shader. Full Pavel-style fluid simulation needs ping-pong velocity/dye/pressure textures and multiple passes; Flutter's current CustomPainter path does not expose that cleanly without a larger render-target/GPU backend change.

## What Pavel-style fluid sim is doing

Pavel Dobryakov's WebGL Fluid Simulation is MIT licensed. Its core loop is a standard stable-fluids GPU pipeline:

1. add user splats into velocity/dye textures;
2. advect velocity and dye through the velocity field;
3. compute curl and add vorticity confinement;
4. compute divergence;
5. solve pressure with repeated Jacobi iterations;
6. subtract pressure gradient;
7. display dye.

The repo README cites GPU Gems 38, `fluids-2d`, and `GPU-Fluid-Experiments`. The downloaded source contains separate shaders for `splatShader`, `advectionShader`, `curlShader`, `vorticityShader`, `divergenceShader`, `pressureShader`, and `gradientSubtractShader`.

## Flutter/Fractal Forge implication

Current Fractal Forge renders each module as one `CustomPaint` using one `FragmentShader` in `FractalCanvas`. That is ideal for fractals, not enough for true fluids because real fluids need persistent frame-to-frame textures. Flutter does have `ui.ImageFilter.shader`, and local Flutter SDK docs say it accepts the child layer as the first sampler when Impeller is enabled. That makes a universal post-effect possible without touching every fractal shader.

## Recommended slices

1. **Now:** add a universal `FluidWarpEffect` widget using `ImageFilter.shader`. It samples the already-rendered fractal and applies curl-noise/touch-splat displacement. This works with any shader and CPU-rendered fallback content, but is an approximation, not a pressure-projected fluid solver.
2. **Later, only if needed:** build a real fluid backend with persistent velocity/dye/pressure render targets. That likely means a dedicated Flutter GPU/Impeller/native path, not hundreds of shader edits.

## Evidence gaps

Need device validation for `ImageFilter.shader` on target Android builds: it is Impeller-only per local Flutter SDK docs. Need performance measurement on mid-tier phones because post-filtering samples the full screen every frame.
