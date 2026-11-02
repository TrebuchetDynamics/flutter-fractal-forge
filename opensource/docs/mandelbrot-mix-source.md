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

## Ported variants

| Batch | Source formula | Entries | Shader |
| --- | --- | --- | --- |
| `MandebrotMix4` (two powers) | `MandelbrotMix4` | 10 | `mandelbrot_mix_gpu.frag` |
| Three powers | `MandelbrotMix3a` | 6 | same shader, third term enabled with `g`, `h` |
| Affine-plane 4D slices | `multimin-XZ-YW-new`, `multirot-XY-ZW-new` | 6 | `planar_slice_4d_gpu.frag` |

The three-term members set `g = 0` to fall back to two terms, so both variants
share one shader. The slice entries map the pixel onto two rotated planes before
the orbit: `z0 = e^{i*b}*x + q`, `c = e^{i*a}*y + q`, `z -> (-z)^p + c`. At zero
angles the wiring reduces to the real slice `z0 = x`, `c = y` of the Mandelbrot
map, which the test mirrors and pins.

## Still unported

`MandelbrotMix2` (additive constant inside the seed) and the six-plane `multirot`
labelling from the same file. They need no new mathematics, only more presets.
