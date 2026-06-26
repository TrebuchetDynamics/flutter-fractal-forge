# Follow-up academic expansion candidates

## Method and limits

This is a follow-up research pass saved under the existing date folder:
`research/worlds-largest-fractal-catalog/academic-expansion-2026-06-26/followup-implementation-ready/`.

I searched OpenAlex, Crossref, Semantic Scholar, and arXiv with the requested 10 query families plus focused follow-ups for Blaschke/rational maps, complex Hénon maps, Lenia, Gierer-Meinhardt, Mimura-Murray, Zorich maps, coupled logistic lattices, Bedford-McMullen carpets, and Hofstadter spectra. No full text was downloaded.

Source coverage from `rforge search stats --dir .`:

- OpenAlex: 191 records
- Crossref: 200 records
- Semantic Scholar: 109 records
- arXiv: 200 records
- Total unique DOIs: 582

I also wrote `existing-catalog-hints.txt` from current source hints and excluded obvious duplicates such as the already-present Blaschke product and newly implemented Rule 90/150, Lattès, Klausmeier, cyclic CA, Greenberg-Hastings CA, Arnoux-Rauzy, and dual-substitution entries.

## Bottom line

The next best implementation-ready additions are **Complex Hénon Julia slices**, **Flow-Lenia**, **Bedford-McMullen carpets**, and the **Hofstadter butterfly**. They are academically cited, visually distinct from the catalog, and have concrete formulas/rules. Several reaction-diffusion and root-finding candidates remain useful but should be admitted only when exact source parameters/formulae are copied from cited papers rather than guessed.

## Ranked expansion plan

See `candidates.csv` for all candidate metadata. Top candidates:

1. **Complex Hénon Julia set** — polynomial automorphism of C²; DOI `10.3934/jmd.2014.8.1`.
2. **Flow-Lenia mass-conservative continuous CA** — continuous cellular automaton; DOI `10.1162/artl_a_00471`.
3. **Bedford-McMullen self-affine carpet** — digit-set self-affine IFS; DOI `10.1017/s0305004100072789`.
4. **Hofstadter butterfly spectrum** — spectral fractal; DOI `10.1103/physrevb.73.155304` and `10.1038/s41586-024-08550-2`.
5. **Mimura-Murray prey-predator reaction-diffusion** — ecological patchiness; DOI `10.1016/0022-5193(78)90332-6`.
6. **Gerhardt-Schuster-Tyson excitable-media CA** — curvature/dispersion CA; DOI `10.1126/science.2321017`.
7. **Coupled logistic map lattice** — spatiotemporal chaos; DOI `10.1016/j.physa.2014.01.051`.

## Main themes

### Complex dynamics beyond one-variable escape time

Complex Hénon maps add a genuine two-complex-variable Julia set slice. This is distinct from the existing real Hénon attractor and can still ship as a 2D fragment shader by fixing one complex coordinate.

### Continuous cellular automata are a new visual class

Flow-Lenia is not a discrete CA and not a standard reaction-diffusion system. It needs texture feedback for full fidelity, but a single-kernel prototype is implementation-ready and visually distinctive.

### Self-affine carpets are low-risk and high signal

Bedford-McMullen carpets use simple digit tests but add anisotropic self-affine geometry absent from the current Sierpinski/Menger-style catalog entries.

### Spectral fractals broaden the catalog

The Hofstadter butterfly is a canonical fractal spectrum. It is not an escape-time set, so implementation should start with CPU precomputation or a small q-limit shader.

### Reaction-diffusion needs named kinetics, not more presets

Mimura-Murray and stable-square Turing models are worth adding only with their named kinetics/parameters. Otherwise they risk becoming cosmetic Gray-Scott variants.

## Performance claims hygiene

Feasibility labels are implementation estimates only:

- easy: closed-form or local rule; no persistent texture needed;
- medium: ping-pong textures, CPU precompute, or multi-component state;
- hard: 3D ray casting or interval/affine arithmetic likely needed.

No literature performance claim is made here.

## Evidence gaps

- Semantic Scholar rate-limited or returned empty files for several queries; this is recorded in `provenance.json`.
- Flow-Lenia implementation details should use the cited paper's kernel/growth defaults before final shipping.
- Higher-order root-finding methods should not be implemented until the exact update formula is extracted from the cited paper metadata/source.
- Zorich-map Julia sets appeared in arXiv search output but did not produce enough DOI/implementation evidence for this ranked batch.

## Project implication

Suggested next implementation batch:

1. Bedford-McMullen carpet: fastest, shader-only.
2. Complex Hénon Julia slice: shader + CPU parity.
3. Coupled logistic map lattice: shader + row-step test.
4. Flow-Lenia: prototype after adding ping-pong texture/state support.
