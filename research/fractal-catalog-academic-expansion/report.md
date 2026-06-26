# Academic research topics for expanding Fractal Forge's fractal catalog

## Method and limits

This is a provenance-first literature sweep for academically grounded fractal families that can become real **Counted Catalog Identities** in Fractal Forge. Searches ran across OpenAlex, Crossref, Semantic Scholar, and arXiv using broad and targeted queries around complex dynamics, Kleinian groups, nonlinear IFS, fractal flames, Sprott/chaotic attractors, distance-estimated fractals, and substitution tilings. No copyrighted full text was downloaded; conclusions are based on metadata/search results and citation graphs.

The search was intentionally biased toward topics that can yield many distinct, working modules without repeating the elementary-CA mistake of counting near-duplicate parameter values as separate fractals.

## Bottom line

The best catalog-growth directions are: **complex dynamics/rational maps**, **Kleinian/circle-inversion limit sets**, **nonlinear and projective IFS**, **strange attractor equation families**, **substitution/aperiodic tilings**, and **3D distance-estimator/KIFS variants**. Cellular automata should stay curated as rule families, not all elementary rules. Fractal flames are promising visually, but the academic-index search had weak direct DOI coverage, so they need a separate source/provenance pass around the original algorithm and implementation lineages.

## Priority research topics

### 1. Rational maps and advanced complex dynamics

**Why it matters:** A single rational-map renderer can expose many named formula identities: polynomial-like maps, parabolic maps, meromorphic maps, exponential maps, and critical-point families.

Evidence:
- DOI `10.24033/asens.1491`, *On the dynamics of polynomial-like mappings*.
- DOI `10.1007/s000140050140`, *Hausdorff dimension and conformal dynamics II: Geometrically finite rational maps*.
- DOI `10.1080/10586458.2000.10504657`, *On Rational Maps with Two Critical Points*.
- DOI `10.1017/s014338570000225x`, *Dynamics of exp(z)*.

Catalog targets:
- Rational maps: `(z^2 + a)/(b z^2 + c)`, McMullen maps, Newton-like rational maps.
- Parameter-plane / dynamical-plane pairs.
- Critical-point families where each family has a named mathematical identity, not only presets.

### 2. Kleinian groups, Möbius transformations, and circle inversion limit sets

**Why it matters:** This is a deep vein of visually distinctive fractals not covered by ordinary Mandelbrot-family escape-time shaders.

Evidence:
- DOI `10.1090/s1088-4173-09-00198-2`, *Wild knots in higher dimensions as limit sets of Kleinian groups*.
- DOI `10.1090/s1088-4173-06-00134-2`, *The core chain of circles of Maskit's embedding for once-punctured torus groups*.
- DOI `10.5186/aasfm.2015.4046`, *From Apollonian packings to homogeneous sets*.
- DOI `10.48550/arxiv.2202.10530`, *A geometric study of circle packings and ideal class groups*.

Catalog targets:
- Apollonian gasket families.
- Schottky group limit sets.
- Maskit/once-punctured torus group visualizations.
- Circle inversion systems and gasket variants.

### 3. Nonlinear IFS and projective IFS

**Why it matters:** Existing affine IFS classics are only the start. Nonlinear/projective IFS can produce many distinct renderers with small, reusable infrastructure.

Evidence:
- DOI `10.1090/s0025-5718-06-01861-8`, *Iterated function systems, Ruelle operators, and invariant projective measures*.
- DOI `10.1007/s00009-016-0720-x`, *Fractional Calculus on Fractal Interpolation for a Sequence of Data with Countable Iterated Function System*.
- DOI `10.5402/2012/825782`, *GPU-Accelerated Rendering of Unbounded Nonlinear Iterated Function System Fixed Points*.
- DOI `10.2991/mecae-18.2018.107`, *A Synthesis Method of Nonlinear Transformation and Affine Transformation for Constructing NIFS*.

Catalog targets:
- Mobius/projective IFS.
- Nonlinear transform IFS.
- Fractal interpolation functions.
- Deterministic + randomized IFS variants with documented transform sets.

### 4. Strange attractor equation families

**Why it matters:** Attractors produce many legitimate identities when each entry is a different equation family, not just a random coefficient preset.

Evidence:
- DOI `10.1103/revmodphys.81.333`, *Fractal structures in nonlinear dynamics*.
- DOI `10.1016/j.chaos.2017.11.027`, *A plethora of coexisting strange attractors in a simple jerk system with hyperbolic tangent nonlinearity*.
- DOI `10.1016/j.chaos.2017.12.023`, *Coexisting attractors and circuit implementation of a new 4D chaotic system with two equilibria*.
- DOI `10.3906/mat-1305-64`, *Degenerate Hopf bifurcations, hidden attractors, and control in the extended Sprott E system with only one stable equilibrium*.

Catalog targets:
- Sprott named systems.
- Jerk systems.
- Hidden/self-excited attractor families.
- Memristive and fractional-order attractors only when equations are stable and renderable.

### 5. Aperiodic substitution tilings and fractal boundaries

**Why it matters:** Tilings expand the catalog beyond escape-time and attractors, while giving deterministic identities with strong mathematical provenance.

Evidence:
- Search results surfaced substitution tiling / circle packing / homogeneous set literature, including DOI `10.5186/aasfm.2015.4046`, *From Apollonian packings to homogeneous sets*.
- Existing project ADR `docs/adr/0003-shared-thumbnails-for-systematic-rule-families.md` supports target-bounded deterministic subsets rather than unbounded spam.

Catalog targets:
- Penrose P2/P3 substitution variants.
- Ammann-Beenker, Rauzy, chair, pinwheel, dragon tilings.
- Boundary fractals from substitution rules.

### 6. 3D distance estimators and KIFS variants

**Why it matters:** A small set of DE kernels can generate many visually distinct 3D fractals: fold systems, sphere inversions, shape inversions, quaternion maps, and hybrid DEs.

Evidence:
- arXiv search surfaced *Extending Mandelbox Fractals with Shape Inversions*.
- DOI `10.1016/j.chaos.2015.02.012`, *Helicalised fractals*.
- DOI `10.1142/s0218348x14500121`, *Micro and Macro Fractals generated by multi-valued dynamical systems*.

Catalog targets:
- Mandelbox fold variants.
- KIFS polyhedral fold families.
- Quaternion Julia variants.
- Shape-inversion and helicalised 3D fractals.

### 7. Fractal flames and variation systems — separate provenance pass needed

**Why it matters:** Flame variation systems can yield a large catalog of visually rich identities. But search results for “fractal flame variations” were polluted by combustion/flame science, not the graphics algorithm.

Evidence:
- Search for `fractal flame algorithm Draves Reckase` surfaced weak academic coverage plus related NIFS/GPU fixed-point results such as DOI `10.5402/2012/825782`.

Catalog targets:
- Treat as a separate research pass using original algorithm sources, implementation docs, and license/provenance records.
- Count named variation transforms or transform families, not arbitrary random coefficient presets.

### 8. Curated cellular automata beyond elementary rule spam

**Why it matters:** CA is still valuable, but the catalog should count families/rulesets with distinct behavior and working renderers, not every elementary rule as a module.

Catalog targets:
- Life-like rules as curated families: Life, HighLife, Seeds, Day & Night, Replicator.
- Cyclic CA.
- Reaction-diffusion CA.
- Lenia / continuous cellular automata.
- Neural CA only with stable, documented update equations.

## Performance claims hygiene

- Do not claim “biggest catalog” from parameter spam. Count stable formula/rule/transform identities.
- Do not add every coefficient tuple as a new catalog entry; use presets unless the literature names a distinct system.
- For rendering claims, cite exact source papers and test the shader numerically or visually.
- For 3D and CA, require at least one screenshot/pixel smoke per promoted identity family.

## Evidence gaps

- Direct academic DOI coverage for fractal flames was weak; needs a targeted provenance pass outside generic DOI search.
- Distance-estimator literature is partly web/community-originated; academic search alone misses important sources.
- Some query results were broad or noisy, especially “fractal flame” and “distance estimated fractals.”
- This report did not download full text or validate shader feasibility.

## Implications for Fractal Forge

Recommended next implementation backlog:

1. Build a **RationalMapModule** with a small catalog of named rational-map formulas.
2. Build a **CircleInversion/KleinianModule** for Apollonian and Schottky-like limit sets.
3. Build a **NonlinearIFSModule** that accepts curated transform families.
4. Expand **AttractorModule** around named Sprott/jerk/hidden-attractor equations.
5. Keep CA as curated family modules; do not restore elementary rule spam.

The highest leverage path is reusable renderers with curated academic catalogs behind them: one deep module per mathematical family, many legitimate Counted Catalog Identities.