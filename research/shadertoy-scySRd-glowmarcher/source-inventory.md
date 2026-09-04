# Source inventory — Shadertoy scySRd glowmarcher visual lead

## Classified sources

### Public visual lead (observation only)

- Platform: Shadertoy
- Author: mrange
- Identifier: `scySRd`
- URL: https://www.shadertoy.com/view/scySRd
- Public description of the post: "Another glowmarcher FTW?" (r/Fractalish, 2026-09)
- Retrieval status: **unavailable**. The page could not be fetched by the
  repository tooling (direct fetch returned HTTP 403; search mirrors exposed no
  source text). Title, source code, license, assets, and exact behavior are
  therefore **unverified**.
- License: unknown. Unknown licensing grants no reusable-source rights.

### Construction and rendering sources (cited, not copied)

- John C. Hart, "Sphere tracing: A geometric method for the antialiased
  ray tracing of implicit surfaces," Vis. Comput. 12(10), 1996 — the
  sphere-tracing method used by the renderer.
- Inigo Quilez, "Distance functions" — published primitive/operator SDF
  references used as mathematical context:
  https://iquilezles.org/articles/distfunctions/
- Inigo Quilez, "3D orbit traps" — context for orbit-trap coloring:
  https://iquilezles.org/articles/orbittraps3d/
- Hadji-Kyriacou & Arandjelović, "Raymarching Distance Fields with CUDA,"
  Electronics 10(22):2730, 2021 — general raymarching background (CC BY).

## Non-exclusive grammar transferred

Only aesthetic-level, non-exclusive grammar from the visual lead is carried
over:

1. A dominant dark background with genuine black negative space.
2. A single readable recursive structure occupying a bounded central region.
3. Slow continuous orientation drift instead of discrete scene jumps.
4. Emissive accumulation near surfaces ("glow marching") rather than a
   post-process blur only.
5. Generated palette color instead of imported textures.

## Explicitly not transferred

- No Shadertoy GLSL source, identifiers, constants, coefficients, expressions,
  comments, function organization, or file structure.
- No screenshots, video frames, thumbnails, textures, cubemaps, audio, or any
  other media.
- No palette samples, camera path, timing values, or parameter values.
- No claim of a port, translation, or derivative implementation. The
  implementation in
  `shaders/3d_and_hypercomplex/raymarched_volumes/luminous_fold_lattice_gpu.frag`
  is original code authored for Fractal Forge.
