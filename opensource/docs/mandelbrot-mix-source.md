# Mandelbrot mix family — provenance

## Provenance

- Source repo: https://github.com/EdwinYoung/fract4d-formulas (local clone `opensource/repos/formula-catalogs/fract4d-formulas`)
- Source path: `orgform/fotdv7.frm`, formula `MandelbrotMix4`
- Source commit: `2b3e04b`
- License: MIT via `LICENSE` (Copyright (c) 2020 Edwin Young)
- Idea summary: the "MandelbrotMix" mapping `z -> k*(a*z^b + d*z^f) + c` mixes two real powers in one orbit. The formula collection also supplies `MandelbrotMix2`, `MandelbrotMix3a`, `multimin` and `multirot` variants.
- Reuse mode: adapted idea (mathematics only; no source text or code copied)
- Target app area: `shaders/escape_time_family/families/mix/mandelbrot_mix_gpu.frag`, `lib/core/modules/builders/escape_time_catalog/research_batches/batch_31_mix_family.dart`
- Validation signal: `test/modules/mix_family_test.dart`. Degenerate parameters `a = d = 0.5, b = f = 2, k = 1` must reproduce `z^2 + c` exactly. The shader must declare its eight extra uniforms in ABI order and keep the chain-rule derivative. All ten catalog entries must compile and draw a non-blank frame.

## What was and was not taken

The mapping and its parameter roles come from the formula. The shader is an
independent GLSL implementation built on this repository's escape-time template
(palette, smooth colouring, transparent background). No line of the `.frm` file or
of fract4d is copied.

## Deferred variants

`MandelbrotMix3a` (three powers), `multimin` and `multirot` (4D rotation slices)
need more uniforms than this batch exposes. They stay unported. Add them as their
own shader when a batching need appears.
