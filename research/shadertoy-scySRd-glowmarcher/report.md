# Shadertoy scySRd glowmarcher study

## Decision summary

Fractal Forge adds one original, sampler-free glowmarcher identity,
**Luminous Fold Lattice** (`luminous_fold_lattice`), inspired at the
aesthetic level by mrange's public Shadertoy post `scySRd`. The referenced
page itself could not be retrieved, so nothing was ported. The implementation
is a clean-room recursive fold lattice (reflection/ordering folds, alternating
twist, project-authored translation) sphere-traced with bounded near-miss
emission accumulation, tone mapping, and premultiplied transparent misses.

Three curated presets — Ember Vault, Violet Cathedral, and Ice Lantern — span
fold scale, recursion depth, step budget, glow reach, palette, and camera. No
`fractalType` selector is exposed because this is one formula identity, not a
family of parameter clones.

## Research depth and coverage

Depth: **limited / unverified**.

No scholarly database sweep was performed and no rforge artifacts were
generated, because the construction does not depend on any retrieved study.
The visual lead was not retrievable (HTTP 403; no source mirror found), so no
shader text, license, title, or assets were inspected. This package therefore
contains no `queries.txt`, `results.jsonl`, or coverage statistics by design;
fabricating search artifacts would misrepresent coverage.

## Reference inspection

- Public visual lead: https://www.shadertoy.com/view/scySRd (author mrange).
- Retrieval attempts: direct fetch blocked (HTTP 403); web search exposed only
  the Reddit post metadata ("Another glowmarcher FTW?", r/Fractalish) and the
  Shadertoy URL.
- Nothing from the lead was downloaded, cached, screenshotted, or inspected
  beyond its public URL and title.

### Visual traits adopted as acceptance criteria

- Near-black negative space dominates the frame.
- One centered recursive object with a readable silhouette.
- Slow orientation drift; no discrete scene cuts.
- Internal emissive glow from near-miss accumulation rather than blur-only.
- Generated palette color; no sampled textures.

## Implementation translation

- Shader: `shaders/3d_and_hypercomplex/raymarched_volumes/luminous_fold_lattice_gpu.frag`
- Catalog: one `Raymarched3DConfig` entry in
  `lib/core/modules/builders/raymarched_3d/catalog_impl.dart`.
- Uniform ABI: unchanged shared 16-float 3D layout (`uTime`, `uResolution`,
  `uMousePos`, `uZoom`, `uRotation`, `uPower`, `uIterations`, `uSteps`,
  `uBailout`, `uColorScheme`, reserved `uFractalType`, `uTransparentBg`).
- Recurrence: `q = abs(q)` → coordinate-order fold → alternating
  bounded twist → `q = scale * q - offset * (scale - 1.0)`, with an inverse
  accumulated scale and a rounded-octahedron/cross terminal primitive.
  Constants `0.391, -0.617, 0.233` (fixed rotation) and offset
  `(0.82, 0.67, 0.91)` were authored here.
- Renderer: bounding-sphere interval pre-pass, conservative 0.61 step factor,
  zoom-scaled hit epsilon, per-step `emission += exp(-|d| * falloff)`,
  `1 - exp(-color * exposure)` tone map, linear→sRGB, premultiplied
  transparent misses.

## Acceptance criteria (all verified by tests)

1. `luminous_fold_lattice` is a 3D, time-driven formula identity.
2. No sampler uniforms; analytic construction only.
3. Shader compiles as a Flutter runtime effect.
4. 64×64 default render: visible structure, >12.5% genuine black, >32
   quantized colors.
5. Visible advancement after one production-clock second (`1000/86400`).
6. Every exposed control (fold scale, depth, steps, glow reach, palette,
   rotation) measurably changes output.
7. Curated presets render structures distinct from the default view.
8. Transparent misses stay clear and premultiplied (RGB ≤ alpha).
9. Maximum accepted zoom keeps finite visible output.
10. Analyzer, focused module test, standalone shader asset test, 3D
    diagnostic, render audit, and the full Flutter suite pass.

Physical-device frame-time evidence remains a release-gate concern and is not
claimed by this study.

## Weakest evidence gap

The referenced shader's source and license are unavailable, so code-level
attribution or comparison to `scySRd` is impossible. Mitigation: the formula,
constants, palette, camera, and timing are original; provenance records the
lead as observation-only with unknown licensing, and source-contract tests
prevent sampler/asset drift.
