# World Fractal Catalog Expansion Backlog

**Date:** 2026-06-06
**Status:** Research backlog / planning artifact
**Goal:** Grow Flutter Fractal Forge toward the coolest and biggest fractal catalog while keeping the app catalog honest: app-visible entries need real render paths, metadata, and validation.

## Evidence snapshot

This backlog is grounded in the current repo state:

| Signal | Current evidence |
|---|---:|
| Reference library manifest | 200 entries in `research/fractals-library/data/fractal_manifest.json` |
| Registry | 1,610 entries in `docs/catalog/fractal_registry.yaml` |
| Implemented tier | 367 entries marked `tier: implemented` |
| Reference tier | 1,243 entries marked `tier: reference` |
| Shader inventory | 469 `.frag` files under `shaders/` |
| Active catalog strategy | 10K catalog specs in `docs/superpowers/specs/2026-04-11-fractal-catalog-design.md` and `docs/superpowers/specs/2026-04-12-fractal-research-pipeline-design.md` |

## Definition of “coolest and biggest”

Use two counters, not one inflated number:

1. **World reference catalog:** 10K+ researched entries with formula/construction, provenance, category, aliases, and dedup evidence.
2. **App catalog:** only implemented entries with working shader/renderer, thumbnail, app metadata, and validation.

A candidate should not become app-visible just because it has a name. It becomes app-visible when it renders correctly and has a measurable visual proof.

## Highest-value frontiers

Animated fractals now have a dedicated backlog: `docs/planning/ANIMATED_FRACTAL_CATALOG_BACKLOG.md`.

The next frontier-research batch is tracked in `docs/planning/FRACTAL_FRONTIER_CANDIDATES_2026_06_06.csv`: 105 additional candidate families spanning complex dynamics, root-finding, 3D/hyperbolic systems, aperiodic tilings, number theory, stateful simulations, natural growth, progressive orbit-density renderers, and audio-reactive/rhythmic fractals. Every row is deliberately marked `reference_candidate` until provenance, dedup, renderer feasibility, and validation gates are satisfied.

The first ranked promotion slice is tracked in `docs/planning/FRONTIER_REFERENCE_PROMOTION_REPORT_2026_06_06.md` and `docs/planning/FRONTIER_REFERENCE_PROMOTION_TOP25_2026_06_06.csv`. These rank 25 registry-safe reference-promotion targets and classify whether each should be added as a new reference entry, reconciled with an existing reference, or held behind stateful/prototype gates. The first fifteen source-checked entries from that report have now been promoted to reference tier only; implemented app counts remain unchanged.

Batch summary:

| Signal | Count |
|---|---:|
| Candidate families | 105 |
| Promoted to reference tier from frontier matrix | 15 |
| Remaining frontier candidates | 90 |
| Motion-aware candidates | 105 |
| `growth_process` candidates | 21 |
| `stateful_grid` animation candidates | 16 |
| `progressive_accumulation` animation candidates | 6 |
| `audio_reactive` candidates | 3 |
| `interactive_dynamical` candidates | 1 |

| Priority | Frontier | Why it is cool | Renderer class | First targets |
|---:|---|---|---|---|
| 1 | Fractal flames and nonlinear IFS | Iconic generative-art look; huge parameter space; visually unlike Mandelbrot sets | Progressive / histogram; start with deterministic preview shaders | Classic flame variations, Apophysis/Xaos-inspired packs, affine IFS presets |
| 2 | 3D inversive / Kleinian / Coxeter systems | Pearl necklaces, sphere packings, hyperbolic architecture; strong screenshots | Raymarched SDF / distance bounds | Schottky group limit sets, Apollonian sphere packings, Coxeter kaleidoscopes |
| 3 | Reaction-diffusion and morphogenesis | Organic spots, stripes, coral, slime, chemical waves; animation-ready | Stateful/multipass or deterministic approximations | Gray-Scott, Brusselator, Oregonator/BZ, FitzHugh-Nagumo, Lenia/Physarum |
| 4 | Root-finding and polynomiography | Reusable shaders, distinct basin coloring, easy to validate | Single-pass fragment shader | Chebyshev, Müller, Durand-Kerner, Ehrlich-Aberth, relaxed Newton |
| 5 | Number-theory and modular fractals | Differentiates from ordinary fractal apps; encyclopedia value | Single-pass / domain-coloring / geometric construction | Modular group tilings, continued-fraction maps, Gaussian/Eisenstein integer basins |
| 6 | Strange attractor mega-pack | Massive named-source surface; beautiful orbit-density images | Orbit map shader or progressive accumulation | Sprott variants, jerk systems, finance/economic attractors, multi-scroll Chua |
| 7 | Botanical / natural-growth fractals | Familiar and accessible; great catalog thumbnails | L-system / IFS / simulation | Branching plants, vascular trees, roots, coral, lightning, river networks |
| 8 | Tiling, aperiodic, and substitution systems | Modern math-art appeal; good for zoomless exploration | Procedural geometry shader or reference docs first | Hat/spectre variants, Ammann families, chair/table, substitution tiling zoo |

## Wave 1 — High-ROI app-catalog candidates

These are good first implementation targets because they are visually distinct and can be validated without new app architecture.

### A. Root-finding / polynomiography

Single-pass candidates with shared shader structure:

- Chebyshev method basins
- Halley variants by polynomial degree: z^4-1, z^5-1, z^6-1
- Householder order-4 and order-5 basins
- Schröder variants with damping
- Damped/relaxed Newton basins
- Secant-method basins with seed offset controls
- Müller method basins
- Laguerre method basins
- Durand-Kerner / Weierstrass basins
- Ehrlich-Aberth basins
- Aberth-Ehrlich vs Durand-Kerner comparison preset
- Newton basins for Chebyshev, Legendre, Hermite, and Laguerre polynomials
- Newton basins for trigonometric equations: sin(z)=0, cos(z)=z, tan(z)=z
- Newton basins for exponential equations: exp(z)=a, z exp(z)=1
- Polynomiography gallery presets for symmetric, asymmetric, and clustered roots

### B. Single-pass complex dynamics

Good shader candidates with rich visual variety:

- Blaschke product Julia sets
- Lattès maps
- McMullen-map named subfamilies
- Herman-ring rational maps
- Siegel-disk showcase presets
- Newton maps of rational functions
- Alternating Julia maps: z²+c alternated with z³+c
- Coupled Mandelbrot maps with two complex parameters
- Parameter-plane slices for rational maps
- Exponential family: z -> λ exp(z)
- Sine family: z -> λ sin(z)
- Cosine family: z -> λ cos(z)
- Tangent family Julia/parameter planes
- Zeta-function Newton fractals
- Gamma-function Newton fractals
- Lambert-W iteration maps
- Weierstrass elliptic-function maps
- Modular lambda-function domain-coloring presets

### C. 3D raymarched / hypercomplex

High screenshot value; admit only when frame budget and compile tests pass:

- Schottky group limit-set raymarcher
- True Kleinian group limit sets
- Apollonian sphere packing 3D
- Coxeter group kaleidoscopic honeycombs
- Hyperbolic honeycomb slices
- Menger sponge variants: rounded, twisted, dodecahedral, icosahedral
- Mandelbox variants: rotated fold, anisotropic fold, shape inversion variants
- Mandelbulb variants: sine-modulated, cosine-modulated, triplex variants, power sweep presets
- Quaternion Julia 3D parameter packs
- Bicomplex/tricomplex Julia slices as 3D volumes
- Octonion Mandelbrot slices with safe iteration caps
- KIFS cathedral / crystal / tunnel presets
- Kali set 3D fold systems
- Jos Leys-style sphere inversion scenes

## Wave 2 — Bigger catalog via reference-tier first

These should enter the reference catalog before app implementation because many need state, accumulation, or careful source/provenance work.

### A. Fractal flames / nonlinear IFS

Research and dedup as families plus variation packs, not thousands of duplicate presets:

- Linear, sinusoidal, spherical, swirl, horseshoe, polar
- Handkerchief, heart, disc, spiral, hyperbolic, diamond
- Ex, Julia, Bent, Waves, Fisheye, Popcorn, Exponential
- Power, Cosine, Rings, Fan, Fan2, Blob, PDJ
- Perspective, Cylinder, Curl, Rectangles, Boarders, Butterfly
- N-gon, JuliaN, JuliaScope, RadialBlur, Pie, Wedge
- Bubble, Cylinder2, PreBlur, GaussianBlur, PostCurl
- Xaos matrix families and symmetry packs
- Flame density-estimation and tone-mapping variants
- Apophysis-style named parameter packs with license-cleared provenance

### B. Reaction-diffusion / chemical / morphogenesis

Stateful or multi-pass; reference-tier first, implemented later when renderer supports it:

- Gray-Scott parameter atlas: spots, worms, labyrinths, mitosis
- Brusselator
- Oregonator / Belousov-Zhabotinsky waves
- FitzHugh-Nagumo reaction diffusion
- Barkley model
- Gierer-Meinhardt activator-inhibitor
- Cahn-Hilliard phase separation
- Swift-Hohenberg equation
- Complex Ginzburg-Landau patterns
- Turing pattern families on square, hex, and polar grids
- Cyclic cellular automata reaction waves
- Lenia families
- Physarum / slime-mold transport networks
- Eden growth, DLA variants, DBM/Lichtenberg discharge variants
- Electrodeposition and corrosion fronts

### C. Strange-attractor mega-pack

The registry already has many attractors, but this category can grow dramatically. Prioritize named systems with formulas and known parameter sets:

- Sprott A-Z plus Sprott simple chaotic flows variants
- Jerk systems and memory jerk systems
- Multi-scroll Chua variants
- Lorenz-63, Lorenz-84, Lorenz-96 visual slices
- Rucklidge, Shimizu-Morioka, Qi, Chen-Lee, Lu-Chen variants
- Rabinovich-Fabrikant variants
- Finance/economic attractors: Kaldor, IS-LM, business-cycle chaotic models
- Ecological attractors: predator-prey chaotic systems, food-chain chaos
- Mechanical attractors: Duffing variants, forced pendulum, double pendulum phase maps
- Conservative maps: Hénon-Heiles, standard-map islands, area-preserving twist maps
- Fractal basin maps for chaotic ODE systems

### D. Natural and physical fractals

Great for education/reference; app implementations may be procedural approximations:

- River network / drainage-basin fractals
- Coastline generators and measured coastline references
- Mountain terrain via fBm, multifractal terrain, ridge noise
- Cloud and turbulence multifractals
- Lightning/Lichtenberg growth
- Crack patterns, mud cracks, fracture networks
- Snow crystal growth approximations
- Coral and sponge growth models
- Vascular trees, bronchial trees, neuron dendrites
- Leaf venation and phyllotaxis families
- Romanesco/broccoli, cauliflower, fern morphology variants
- Shell-growth logarithmic spirals with fractal ornament

## Wave 3 — World-scale encyclopedia expansion

These are excellent for 10K reference growth and can be app-visible selectively.

### A. Tiling, aperiodic, and substitution systems

- Penrose P1/P2/P3 variants
- Ammann-Beenker variants
- Ammann A2/A3/A4 families
- Pinwheel tiling variants
- Chair, table, domino, sphinx, trilobite, crab substitutions
- Hat monotile and spectre monotile families
- Rauzy fractal variants from substitutions
- Tribonacci and n-bonacci word fractals
- Fibonacci word curve variants
- Paperfolding dragon variants
- Gosper island / flowsnake variants
- Peano, Hilbert, Moore, Lebesgue, Sierpinski curve variants
- Terdragon, twindragon, Lévy, Heighway, golden dragon families
- Hyperbolic tiling {p,q} gallery
- Modular tessellation and Farey tessellation variants

### B. Number-theory fractals

- Gaussian integer Newton basins
- Eisenstein integer Newton basins
- Modular group fundamental-domain visuals
- Ford circle and Apollonian-Ford hybrids
- Farey tree and Stern-Brocot fractal maps
- Continued-fraction digit fractals
- Minkowski question-mark function graph/detail views
- Ulam spiral variants and prime-gap textures
- Gaussian prime spirals
- Eisenstein prime lattice visuals
- Collatz inverse-tree variants and parity-vector textures
- Pascal/Sierpinski mod-p triangle atlas
- Cellular automata generated by modular arithmetic
- Zeta zero domain coloring and Newton basins
- Modular form / eta-function domain coloring presets

### C. High-dimensional and algebraic systems

- Clifford algebra Julia sets
- Sedenion and split-sedenion slices
- Tessarine and coquaternion variants
- Dual-complex and dual-quaternion families
- Hypercomplex Newton maps
- Clifford torus projection fractals
- Quaternionic rational maps
- 4D Julia/Mandelbrot slices by plane parameter
- 4D polychora/kaleidoscopic fold systems
- Hyperbolic 4D honeycomb slices

### D. Domain-coloring encyclopedia

Treat domain coloring as a platform category. Each function family can become a reference entry plus app preset when shader-friendly:

- Polynomial families and root structures
- Rational functions and poles
- Trigonometric, inverse trigonometric, hyperbolic functions
- Exponential and logarithmic functions
- Gamma, beta, zeta, eta, and theta functions
- Elliptic functions and modular forms
- Branch cuts, Riemann surfaces, and phase portraits
- Newton-step vector fields and basin overlays

## Source-mining plan

Prioritize sources by yield and reviewability:

1. **Existing reference backlog:** promote from 1,231 reference entries before crawling new sources.
2. **Structured formula sources:** Ultra Fractal formula DB, Shadertoy fractal-tag scan, MathWorld, Wikipedia, Paul Bourke pages.
3. **Shader and code repositories:** GitHub projects with permissive licenses and clear provenance.
4. **Academic sources:** arXiv, Bridges Math Art, SIAM/AMS papers where formulas are explicit.
5. **Forum/gallery sources:** Fractal Forums, Mu-Ency, Apophysis/Xaos parameter archives; require strong dedup and license review.
6. **Chinese sources:** discovery and alias harvesting for Chinese-origin systems, with English-only docs per the approved 2026-04-12 pipeline.

## Admission and quality rules

A candidate can become **reference-tier** only when it has:

- canonical English name;
- category and renderer class;
- formula/construction or explicit generation algorithm;
- at least one provenance source;
- alias/dedup notes;
- implementation feasibility classification.

A candidate can become **implemented-tier** only when it additionally has:

- working shader or renderer path;
- declared shader asset where applicable;
- default params and at least one visually useful preset;
- non-placeholder thumbnail or pixel/entropy proof;
- strict app-catalog doctor pass;
- focused Dart/analyzer/widget/shader validation for touched code.

## Near-term recommended slices

1. **Frontier matrix review:** ✅ completed in `FRONTIER_REFERENCE_PROMOTION_REPORT_2026_06_06.md` and `FRONTIER_REFERENCE_PROMOTION_TOP25_2026_06_06.csv`.
2. **Reference promotion micro-batches:** ✅ completed for 15 Top-25 entries as reference-tier only, adding the first three source-checked micro-batches while keeping implemented app counts unchanged.
3. **Promotion report:** rank the 25 easiest reference-tier entries to promote by renderer class, shader-template reuse, and visual payoff.
4. **Root-finding slice:** implement one Newton-family reference entry with real shader + thumbnail + tests.
4. **3D showcase slice:** pick one raymarched inverse/Kleinian/Coxeter candidate and validate frame budget before broad 3D expansion.
5. **Fractal-flame prototype:** create a throwaway renderer prototype to decide whether Flutter can support progressive accumulation acceptably.
6. **Reaction-diffusion prototype:** test Gray-Scott ping-pong feasibility or define a deterministic approximation path.
7. **Reference ingestion batch:** add 50 new reference candidates from this backlog, with categories and dedup notes, without app visibility.
8. **Catalog honesty dashboard:** expose counts by implemented/reference, category balance, shader compile status, and thumbnail health.

## Explicit non-goals for this backlog

- Do not pad the app with placeholder shaders.
- Do not count mere presets as new fractal types unless the underlying family or construction changes.
- Do not ingest formulas with unclear license/provenance.
- Do not promise deep zoom for non-escape-time families.
- Do not make stateful simulations app-visible until the renderer path is proven.
