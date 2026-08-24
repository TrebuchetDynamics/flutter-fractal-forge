# Log-Polar Fractal Tessellation Study

## Scope

This study evaluates the public mathematical sketch supplied from BryceGuy's Reddit post, “I wrote some code that made these,” and adapts the technique for Fractal Forge without downloading or bundling the post's portrait, animal, or other third-party image tiles.

The implementation target is a static, GPU-safe family of escape-time fractals using original analytic motifs.

## Primary technique

The supplied sketch maps a complex iterate `z = r + i·im` into a repeating 2:1 tile:

```text
angle = mod(atan(im, r) * (px / PI) + phaseOffset, 2 * px)
radius = (log(bailout) - log(|z|)) * py / (log(bailout) / 2)
```

After dividing by the texture dimensions, the essential dimensionless mapping is:

```text
u = fract(arg(z) / (2π) + phaseTurns)
v = 2 · (log(B) - log(|z|)) / log(B)
```

The angle is a periodic coordinate. The logarithmic radius creates repeated scale bands, which is why a tile appears nested around escape-time boundaries.

## Numerical interpretation

The post does not specify whether `z` is sampled before or after the escape-producing update. Sampling the already escaped iterate makes `v` negative and highly sensitive to orbit overshoot. The production implementation therefore retains the **last finite bounded iterate** and uses it for both angle and radius.

Safety rules:

- `B = max(bailout, 1.0001)` keeps `log(B)` finite.
- Magnitude squared is clamped before `log`.
- `!(nextMagnitudeSquared <= B²)` treats both overflow and NaN as escape while preserving the prior finite sample.
- Interior points use a deterministic dark fill and never consume an uninitialized escape sample.
- Angular and radial repetition counts are dimensionless controls replacing source-image pixel dimensions.

## Research context

The exact tile formula appears to be an artistic implementation note rather than a named peer-reviewed coloring algorithm. The broader mathematical basis is consistent with:

- Böttcher coordinates, which conjugate polynomial dynamics near infinity to monomial dynamics and provide natural magnitude/angle coordinates: Fletcher, “On Böttcher coordinates and quasiregular maps” ([arXiv:1205.1978](https://arxiv.org/abs/1205.1978)).
- External-ray angle coordinates for the Mandelbrot set: Schleicher, “Rational parameter rays of the Mandelbrot set” ([arXiv:math/9711213](https://arxiv.org/abs/math/9711213)).
- Computational rendering of external rays from Böttcher coordinates: “A Method to Solve the Limitations in Drawing External Rays of the Mandelbrot Set” ([DOI:10.1155/2013/105283](https://doi.org/10.1155/2013/105283)).

These sources support the angle/equipotential interpretation, not the ownership or exact provenance of the Reddit formula.

## Product design decision

Four curated modules share one shader and select different initial formulas and original procedural motifs:

1. Mandelbrot Log-Polar Tessellation — eye glyph
2. Julia Log-Polar Tessellation — theatrical mask
3. Burning Ship Log-Polar Tessellation — feline-like analytic glyph
4. Tricorn Log-Polar Tessellation — serpent ribbon

Users can vary formula, motif, Julia constant, angular repeats, radial repeats, phase, and the existing 64-color palette control.

No sampler, uploaded image, scraped image, or copyrighted post artwork is included. This keeps the first production slice portable across Flutter runtime-effect targets and avoids unresolved image licensing and file-picker/storage UX.

## Accessibility and motion

The shader declares but intentionally does not consume `uTime`; all defaults are static. Color motion, luminance pulses, and full-field inversion are absent. Motif output is clamped below full white, and interior regions remain dark. Any future phase animation must honor reduced motion and use slow spatial translation rather than temporal luminance modulation.

## Evidence coverage and limitations

ResearchForge queried 25 variants across OpenAlex, arXiv, and Semantic Scholar: 1,025 retrieved records and 742 deduplicated records. Semantic Scholar rate-limited 18 query/source combinations, while OpenAlex and arXiv completed all 25 queries.

Weakest evidence gap: no archival source for the complete Reddit code or a formal publication defining this exact image-tessellation mapping was found. The supplied excerpt is therefore treated as the primary implementation lead, and all bundled motifs are newly authored procedural geometry.
