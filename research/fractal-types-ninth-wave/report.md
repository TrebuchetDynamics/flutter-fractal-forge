# Ninth-wave fractal types to add

## Method and limits

Fresh research pass after the eighth wave. I searched arXiv, Crossref, OpenAlex,
and Semantic Scholar through `rforge search batch` in two 8-query passes:

- **Broad pass:** 445 records / 428 deduped / 319 unique DOIs. Coverage:
  arXiv 160, Crossref 160, OpenAlex 95, Semantic Scholar 30.
- **Gap pass:** 434 records / 412 deduped / 336 unique DOIs. Coverage:
  arXiv 160, Crossref 158, OpenAlex 116, Semantic Scholar 0 (all 8 queries
  rate-limited, HTTP 429).

Semantic Scholar was again rate-limited on the gap pass (all 8 queries) and 6/8
broad-pass queries; failures are recorded in `failures.jsonl` /
`gap-pass/failures.jsonl`. Citation expansion was run on eight DOI-backed seeds
(`citations/graph-*.json`): 25-edge graphs for the SNA survey, robust-SNA PRL,
aggregation SciRep, Eulerian-walker PRE, and p-adic Mandelbrot (19 edges);
1 edge for the quasifuchsian seed; 0 edges for the nonlinear-IFS chapter; one
404 for the rep-tiling chapter. No PDFs or copyrighted full text were fetched;
evidence rests on retrieved bibliographic metadata, consistent with prior waves.

Candidate names were cross-checked against `lib/`, `shaders/`, and
`pubspec.yaml` for duplicates (details in the local duplicate check below).

## Bottom line

The strongest ninth-wave additions are **Truchet-tile fractal mosaics**,
**strange nonchaotic attractors (SNA)**, **fractal-interpolation heightfields**
(2D relief view), **hidden/hyperchaotic attractors**, and **rep-tile /
self-similar tiling explorers**. Together with the eighth-wave leftovers
(**Baker/wandering domains**, **superfractal/random-IFS morphing**, **Bessel
fields**, **Coxeter reflection**) they form a concrete shader-feasible backlog.

ELI5: add tile-maze mosaics, fractal-but-calm attractors, crumpled-paper
terrain, sneaky double-stretch attractors, self-copying tiles, runaway tangent
webs, shuffled fern blends, and ripple-fields from special functions.

## Local duplicate check

Already present in app/source names (skip as-is):

- Hofstadter butterfly (`hofstadter_butterfly_gpu.frag`), Clifford Butterfly
- Zaslavsky map, Standard/Chirikov map (dedicated shared catalogs)
- Circle-packing conformal map (batch 22); Apollonian gasket/Coxeter-style
  packings exist as IFS entries
- Magnetic pendulum, Chebyshev, Lichtenberg, reaction-diffusion, DLA-adjacent
  dielectric breakdown (`dielectric_breakdown_gpu.frag`)
- Pinwheel, Sphinx tilings; external rays (batch 23); Sprott A–S attractor
  family (shared catalog)

Not present as app entries (genuine gaps):

- `Truchet` — no hits anywhere in lib/ or shaders/
- `strange nonchaotic attractor` — no hits in the *initial* grep pass (the
  wave-3 id `strange_nonchaotic_attractor` surfaced during the catalog
  integrity test after implementation; see candidate 2)
- `quasifuchsian` — no hits
- `p-adic` / p-adic Mandelbrot — no hits
- `hidden attractor` / `hyperchaos` — no hits
- `Coxeter` — no hits (Apollonian exists, but no reflection-group module)
- `fractal interpolation surface` (2D heightfield view) — only a raymarched
  affine 3D surface exists
- `Baker domain` / `wandering domain` — no module (only a comment hit in
  `zeta_newton_gpu.frag`)
- `Bessel` module — only the auto-generated Legalize variant feed
- `superfractal` / random-IFS morphing — no hits
- `rep-tile` / irreptile — no hits
- `Eulerian walker` — no hits
- `Bessel` module — only the auto-generated Legalize variant feed; the
  number-theory shader directory has no Bessel entry

## Best next candidates

### 1. Truchet-tile fractal mosaic (generalized/hinged Truchet)

- **What it looks like:** random arc/Smith-curve tile mosaics; recursive
  hinged-Truchet variants produce nested maze-like fractal lattices.
- **Why it fits:** zero local hits; cheap deterministic-hash tile shader;
  extends the existing tiling/IFS family with a visually distinct mosaic look.
- **Implementation shape:** 2D shader: subdivide into a grid, per-cell hash
  picks one of the two Truchet arc orientations (or hinged recursive variants);
  expose tile size, depth, seed, and curve-thickness.
- **Evidence:** *Truchet Tiles*, 2007, DOI `10.3840/000481`; *The Tiling
  Patterns of Sebastien Truchet and the Topology of Structural Hierarchy*,
  1987, DOI `10.2307/1578535`; *Hinged Truchet tiling fractals*, 2021 (arXiv);
  *Truchet Tilings and Renormalization*, 2011 (arXiv).
- **Priority:** high — cheap, distinct, and evidence-backed.

### 2. Strange nonchaotic attractor (SNA) explorer — ALREADY COVERED

- **Duplicate found during implementation:** `strange_nonchaotic_attractor`
  already exists in the wave-3 catalog (`batch_21_third_wave_research.dart`,
  shader `strange_nonchaotic_gpu.frag`). The ninth-wave implementation of
  this candidate was dropped and replaced by the Bessel zero field (a
  documented wave-7/8 backlog item). Evidence retained for reference:
  *STRANGE NONCHAOTIC ATTRACTORS*, IJBC, 2001, DOI
  `10.1142/s0218127401002195`; *Fractalization of a torus as a strange
  nonchaotic attractor*, PRE 54, 1996, DOI `10.1103/physreve.54.6114`;
  *Fractal Properties of Robust Strange Nonchaotic Attractors*, PRL 87,
  2001, DOI `10.1103/physrevlett.87.254101`.

### 3. Fractal interpolation heightfield (2D relief)

- **What it looks like:** a self-affine rough surface rendered as shaded
  relief/contours — crumpled-paper terrain controlled by vertical scaling.
- **Why it fits:** the 6th wave flagged fractal interpolation surfaces; only a
  raymarched 3D affine surface exists, so a 2D relief/contour module is a
  genuine gap.
- **Implementation shape:** 2D shader: deterministic midpoint-displacement or
  2–4 self-affine refinement levels over a small control grid, shaded by
  height gradient + contour bands.
- **Evidence:** *The Calculus Of Bivariate Fractal Interpolation Surfaces*,
  Fractals, 2020, DOI `10.1142/s0218348x21500663`; *GROWING SELF-AFFINE
  SURFACES*, 1992, DOI `10.1142/9789814360234_0007`; 6th-wave seeds (see
  `research/fractal-types-sixth-wave/report.md`).
- **Priority:** high — distinct visual mode (relief/contours) vs. another
  escape-time formula.

### 4. Hidden / hyperchaotic attractor gallery

- **What it looks like:** 2D projections of hidden-attractor and hyperchaotic
  flows (Matouk systems, 4D hyperchaotic hidden-attractor systems) — multistable,
  unusual attractor geometries.
- **Why it fits:** no hidden-attractor or hyperchaos module names exist; the
  Sprott catalog covers self-excited classics only.
- **Implementation shape:** orbit shader with curated presets (Matouk
  hyperchaotic system, a 4D hidden-attractor system), phase-space scaling like
  the existing Sprott modules.
- **Evidence:** *Self-Excited and Hidden Chaotic Attractors in Matouk's
  Hyperchaotic Systems*, 2022, DOI `10.1155/2022/6458027`; *A new four-
  dimensional hyperchaotic system with hidden attractors and multistability*,
  Phys. Scr., 2023, DOI `10.1088/1402-4896/ad0e55`; *Finite-time Lyapunov
  dimension and hidden attractor of the Rabinovich system*, Nonlinear Dyn.,
  2018, DOI `10.1007/s11071-018-4054-z`.
- **Priority:** medium-high; uses the attractor orbit pattern.

### 5. Rep-tile / irreptile tiling explorer

- **What it looks like:** self-replicating tiles (reptiles/irreptiles) that
  tile scaled copies of themselves — pinwheel-adjacent but distinct: sphinx,
  chair, fish, and custom rep-tile subdivisions.
- **Why it fits:** no rep-tile/irreptile module; complements existing
  pinwheel/sphinx entries with a parametric subdivision family.
- **Implementation shape:** 2D distance-to-boundary shader for a small set of
  rep-tile subdivision schemes (chair, sphinx, trapezoid), depth-exposed.
- **Evidence:** *Rep-tiling Euclidean space*, 1995, DOI
  `10.1007/978-3-0348-9096-0_10` (citation expansion 404 — metadata-only);
  *Rep-Tiles*, 2024; *Three-dimensional Rep-tiles*, 2021; *Solving Rep-tile by
  Computers*, 2021 (arXiv records).
- **Priority:** medium; weakest citation-graph coverage.

### 6. Baker / wandering-domain transcendental map

- **What it looks like:** nested escaping tracts under transcendental
  iteration (e.g. `z -> λ + z + tan z`), web-like wandering/Baker domains.
- **Why it fits:** eighth-wave backlog item, still unimplemented; no module
  names.
- **Implementation shape:** escape shader `z_{n+1} = λ + z + tan(z)` with safe
  λ presets; color by escape tract and displacement bands.
- **Evidence:** *Iteration of some topologically hyperbolic maps in the family
  λ+z+tan z*, 2021, DOI `10.48550/arxiv.2106.02832`; *Wandering domains for
  entire functions of finite order in the Eremenko-Lyubich class*, PLMS,
  2018, DOI `10.1112/plms.12288`; *A Survey of Baker Wandering Domains*, 2026.
- **Priority:** medium; transcendental stability needs care near tan poles.

### 7. Superfractal / random-IFS morph

- **What it looks like:** chaos-game blending of 2–4 IFS rule families; seeded
  random selection per iteration morphs fern/dragon/carpet forms.
- **Why it fits:** eighth-wave backlog item; no superfractal or random-IFS
  module exists.
- **Implementation shape:** per-pixel chaos-game accumulation with seeded
  random family selection; expose family mix and seed.
- **Evidence:** *Composable function systems as a general-purpose rendering
  framework*, 2026 (arXiv); *The Chaos Game on a General Iterated Function
  System*, 2010; *Modeling and rendering of nonlinear iterated function
  systems*, 1994/1998, DOI `10.1016/b978-044450002-1/50063-1` (citation graph
  0 edges — metadata-only); 6th/7th-wave superfractal seeds.
- **Priority:** medium; strong catalog leverage, keep implementation simple.

### 8. Quasifuchsian limit set (deformation view)

- **What it looks like:** quasicircle limit sets between the round circle
  (Fuchsian) and dendrite extremes, parameterized by bending deformation.
- **Why it fits:** Kleinian/Schottky modules exist, but no quasifuchsian
  deformation-space module; the bending-lamination look is distinct.
- **Implementation shape:** iterate a two-generator group word with a
  bending-parameter blend; color by word length and stability. Prototype-grade
  naming ("deformation blend, not exact lamination").
- **Evidence:** *The limit sets of quasifuchsian punctured surface groups and
  the Teichmüller distances*, Kodai Math. J., 2005, DOI
  `10.2996/kmj/1123767011` (citation graph 1 edge); *Limits of quasifuchsian
  groups with small bending*, 2002; *Dimensions of limit sets of Kleinian
  groups*, 2019, DOI `10.1090/conm/731/14674`.
- **Priority:** medium-low; overlaps existing Kleinian family.

### 9. p-adic Mandelbrot / arithmetic dynamics

- **What it looks like:** Mandelbrot-style parameter maps over p-adic metrics
  render as concentric disk/ring structures quite unlike complex dynamics.
- **Why it fits:** no p-adic or arithmetic-dynamics entries; adds a genuinely
  different number system.
- **Implementation shape:** visualize the p-adic filled Julia/Mandelbrot via
  the known radius bounds (concentric annuli in the p-adic tree); expose p and
  iteration depth. Conservative naming: "p-adic-inspired tree/annuli view".
- **Evidence:** *Bounds on the radius of the p-adic Mandelbrot set*, Acta
  Arithmetica, 2013, DOI `10.4064/aa158-3-5` (citation graph 19 edges); *On
  the dynamics of polynomial-like mappings*, 1985, DOI `10.2403/asens.1491`.
- **Priority:** medium-low; visually simple but mathematically distinct.

## Skip for now

- Hofstadter butterfly, Zaslavsky/standard maps, circle packing, magnetic
  pendulum, Chebyshev, Lichtenberg, reaction-diffusion, DLA-dielectric
  breakdown, pinwheel/sphinx, external rays, Sprott family — already present.
- Bessel-function fields — 7th-wave evidence only; special-function texture
  remains a follow-up (no strong new records this wave).
- Coxeter reflection boundaries — evidence still weak/quirky this wave
  (Apollonian/Cayley already present); keep as future prototype.
- Eulerian walkers — mathematically lovely (PRE 80.051118) but simulation
  cost is high for the current fragment pattern; revisit if a bounded-lifetime
  walker shader is wanted.

## Suggested implementation order

1. **Truchet mosaic** — smallest shader, zero-duplicate, distinctive look.
2. **SNA (quasiperiodically forced) attractor** — DUPLICATE of wave-3 module;
   replaced by the Bessel zero field during implementation.
3. **Fractal interpolation heightfield** — new visual mode (relief).
4. **Hidden/hyperchaotic attractor** — orbit-pattern module.
5. **Rep-tile explorer** — geometric tiling family.
6. **Baker/wandering-domain tangent map** — transcendental backlog.
7. **Superfractal random-IFS morph** — IFS backlog.
8. **Quasifuchsian deformation** — SKIPPED: Kleinian family already has 5
   modules (kleinian, schottky, kleinian_schottky_necklace, pseudo_kleinian,
   fuchsian_limit_set_lace).
9. **p-adic Mandelbrot view** — annuli visuals.
10. **Bessel zero field** — wave-7/8 backlog item, promoted into this batch
    as the SNA replacement.
