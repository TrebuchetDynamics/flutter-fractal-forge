# Eighth-wave fractal types to add

## Method and limits

Fresh research pass beyond prior research waves (third–seventh). I searched
arXiv, Crossref, OpenAlex, and Semantic Scholar through `rforge search batch`
in two 8-query passes (broad + gap):

- **Broad pass:** 419 records / 400 deduped / 300 unique DOIs. Coverage:
  arXiv 160, Crossref 160, OpenAlex 91, Semantic Scholar 8.
- **Gap pass:** 390 records / 372 deduped / 275 unique DOIs. Coverage:
  arXiv 160, Crossref 155, OpenAlex 75, Semantic Scholar 0.

Semantic Scholar was rate-limited (HTTP 429) on most live queries in both
passes (14 failures recorded in `failures.jsonl`), so its coverage of recent
CS/graphics records is the weakest evidence area — the same limitation noted in
the sixth and seventh waves. Citation expansion was run on eight DOI-backed
seeds (`citations/graph-*.json`); seven returned 25-edge graphs and one
returned 0 edges. No PDFs or copyrighted full text were fetched; all candidate
evidence below comes from retrieved bibliographic metadata, which is what the
prior waves also used to ground naming and claims.

I cross-checked candidate names against `lib/`, `shaders/`, and `pubspec.yaml`
to avoid obvious duplicates.

## Bottom line

The strongest *new* research themes this wave are **fixed-point iteration
fractals (Mann / Ishikawa / Noor / SP / Picard-S / CR / DK / Fibonacci-Mann)**,
**parabolic dynamics / Leau–Fatou petals**, **modular forms (Dedekind
η-function and the Klein j-invariant)** and **meromorphic/transcendental
compositions with essential singularities (e.g. `z·sin z`)**. Together with
the still-unimplemented sixth- and seventh-wave backlog (Minkowski
question-mark, Möbius-transformation Julia, fractional complex cosine,
Herman rings, Mandelbrot percolation carpets, Sierpiński-curve Julia,
superfractal IFS morphing, Baker/wandering domains, Bessel fields), these form
a concrete, shader-feasible implementation list that is mostly *not* already
covered by module names in the app.

ELI5: add Julia sets drawn through "shuffled" iteration formulas, flower-shaped
parabolic basins, η-function lace, `z·sin(z)` webs, a number-line staircase,
a Möbius-twisted Julia, cosine escape maps, donut Fatou regions, random-hole
carpets, and blended random IFS.

## Fresh eighth-wave findings (not covered by prior waves)

### 1. Fixed-point iteration fractals (Mann / Ishikawa / Noor / SP / CR / DK / Picard-S)

- **What it looks like:** Julia/Mandelbrot renderings produced by substituting
  the standard `z_{n+1}=F(z_n)` iteration with weighted fixed-point iteration
  schemes (`z_{n+1} = (1-α)z_n + α F(z_n)` Mann, two-stage Ishikawa,
  three-stage Noor, SP, hybrid Picard-S, CR, DK, Fibonacci-Mann, Jungck). These
  interpolate between the classical Julia and parameter-space Mandelbrot forms
  and produce visually distinct, smoother, self-similar variants.
- **Why it fits:** the app's escape-time family uses only the classical
  iteration; there are no iteration-scheme variants. This is a whole *family*
  from one parameterized shader (scheme selector + weights).
- **Implementation shape:** one escape-time shader with an `iterationScheme`
  param (Mann/Ishikawa/Noor/SP/Picard-S) forced around a base quadratic or
  transcendental map, plus weighting params. Standard escape-time uniform layout.
- **Evidence:** *Fractals as Julia and Mandelbrot Sets of Complex Cosine
  Functions via Fixed Point Iterations*, Symmetry, 2023, DOI
  `10.3390/sym15020478` (citation graph 25 edges); *Escape Criteria Using Hybrid
  Picard S-Iteration Leading to a Comparative Analysis of Fractal Mandelbrot
  Sets Generated with S-Iteration*, Fractal and Fractional, 2024, DOI
  `10.3390/fractalfract8020116`; *Julia and Mandelbrot Sets of Transcendental
  Function via Fibonacci-Mann Iteration*, 2022, DOI `10.1155/2022/2592573`;
  *Escape Criteria for Generating Fractals of Complex Functions Using
  DK-Iterative Scheme*, Fractal and Fractional, 2023, DOI
  `10.3390/fractalfract7010076`; *On the viscosity approximation type
  iterative method…*, Numerical Algorithms, 2023, DOI `10.1007/s11075-023-01644-4`.
- **Priority:** high — very broad visual return from one param set, and a clear
  gap.

### 2. Parabolic dynamics / Leau–Fatou petal basins

- **What it looks like:** neighborhoods of parabolic fixed points form
  "petal" basins (Leau–Fatou flowers) and inhaling/exhaling regions; escape
  coloring plus a petal-overlay channel gives organic floral Julia structures
  distinct from hyperbolic bulbs.
- **Why it fits:** no named parabolic-petal / parabolic-Julia module; the app
  has hyperbolic Julia variants only.
- **Implementation shape:** escape-time shader iterating a parabolic family
  (e.g. `z -> z + z² + c` near a parabolic parameter, or a curated parabolic
  multiplier), coloring by basin plus petal index derived from angle/rotation
  number. Conservative naming: "parabolic aware" not "precise implosion".
- **Evidence:** *Fatou Coordinates for Parabolic Dynamics*, 2015, DOI
  `10.1007/978-3-319-20337-9_11` (citation graph 0 edges); *Using the Fatou Set
  to Study the Julia Set*, 2000, DOI `10.1007/978-3-663-08092-3_6`; *Bifurcation
  of parabolic fixed points*, 2000, DOI `10.1017/cbo9780511569159.018`.
- **Priority:** high — distinct visual and concrete math to color from.

### 3. Modular forms: Dedekind η-function / Klein j-invariant field

- **What it looks like:** lace-like self-similar fields from |η(τ)| or
  ℜ(η(τ)) in the upper half-plane, plus fundamental-domain tessellation of the
  modular group; the Klein j-invariant (via the η-quotient `j=(E₄³/η²⁴)`) gives
  level-set contours with fractal modular symmetries.
- **Why it fits:** app scan found no `Dedekind`, `eta`, `modular form`, or
  `j-invariant` module (only Spanish locale strings). Complements
  number-theory visuals.
- **Implementation shape:** 2D scalar-field shader approximating η via the
  finite q-product `η(τ)=q^(1/24)∏(1−qⁿ)`, `q=exp(2πiτ)`, coloring by |η|,
  arg, or modular tessellation; no claim of full modular-form arithmetic.
- **Evidence:** *Dedekind's Eta Function and Modular Forms*, 2011, DOI
  `10.1007/978-3-642-16152-0_1`; *The construction of modular forms as products
  of transforms of the Dedekind eta function*, Acta Arithmetica, 1990, DOI
  `10.4064/aa-54-4-273-300` (citation graph 25 edges); *Reflective modular
  forms and Weyl invariant E8 Jacobi modular forms* (metadata-only record).
- **Priority:** medium-high — visually fresh, cheap 2D scalar field.

### 4. Meromorphic / transcendental compositions with essential singularities

- **What it looks like:** Julia sets for maps with essential singularities
  (`z -> z·sin z`, `z -> exp(cos z)`, exponential-Picard maps) forming web-like
  tracts, spirals, and dynamic rays rather than compact blobs.
- **Why it fits:** app has an exponential-Julia and some transcendental maps,
  but no composition-with-essential-singularity modules and no named dynamic-ray
  rendering.
- **Implementation shape:** escape-time shader for `z_{n+1} = zₙ·sin(zₙ)+c`
  (and a sine composition) with the standard layout; color by escape tract.
- **Evidence:** *Iteration of meromorphic functions*, Bulletin AMS, 1993, DOI
  `10.1090/s0273-0979-1993-00432-4` (citation graph 25 edges); *Dynamic rays of
  bounded-type entire functions*, Annals of Mathematics, 2011, DOI
  `10.4007/annals.2011.173.1.3`; *Dimensions of Julia sets of transcendental
  meromorphic functions*, 2008, DOI `10.1017/cbo9780511735233.017`.
- **Priority:** medium — distinct look; watch stability near singularities.

### 5. Hidden attractors / hyperchaos (strange-attractor family)

- **What it looks like:** 2D projections of hidden-attractor and hyperchaotic
  systems (Chua circuits, Lorenz-like flows with stable equilibria, hyperjerk
  systems) — unusual multi-stable attractor geometries.
- **Why it fits:** app has a Sprott catalog and many attractors, but no
  hidden-attractor / multi-stability / hyperjerk modules by name.
- **Implementation shape:** an attractor-module (point accumulation / fragment)
  with curated parameter sets from the cited systems. Higher implementation cost
  than escape-time; consider as follow-up after the 2D modules.
- **Evidence:** *Hidden attractors in Chua circuit: mathematical theory meets
  physical experiments*, Nonlinear Dynamics, 2022, DOI `10.1007/s11071-022-08078-y`
  (citation graph 25 edges); *A New Hyperjerk System With a Half Line
  Equilibrium…*, IEEE Access, 2024, DOI `10.1109/access.2024.3351693`;
  *Homoclinic orbits, and self-excited and hidden attractors in a Lorenz-like
  system*, Eur. Phys. J. ST, 2015, DOI `10.1140/epjst/e2015-02470-3`.
- **Priority:** medium; distinct, but needs the attractor module path.

## Unimplemented backlog from sixth and seventh waves (verified still absent)

Verified against current `lib/` + `shaders/` (the "Legalize" auto-batch
entries and unrelated hits do not constitute named modules):

1. **Minkowski question-mark / Stern-Brocot visualizer** — no named module
   (`Minkowski` in source is the *Minkowski Island* antenna, a different object).
   High educational value. Evidence in sixth-wave report.
2. **Möbius-transformation Julia/Mandelbrot** — `Möbius` appears only inside
   Kleinian/Cayley/Blaschke shaders; no named transformation-family Julia module.
3. **Fractional-order complex cosine map** — no `cosine map` module hit.
4. **Herman-ring / toral-band Fatou visualizer** — no named module (Legalize
   `hermanm` entries are auto-converted variant feeds, not Herman-ring modules).
5. **Mandelbrot-percolation / random Sierpiński carpet** — distinct from the
   existing deterministic `Percolation Cluster`.
6. **Sierpiński-curve Julia topology view** — no hit.
7. **Random / nonlinear IFS superfractal morpher** — no hit.
8. **Baker / wandering-domain transcendental maps** — no hit.
9. **Bessel-function fractal fields** — no real module (Legalize `BESSEL-1` is a
   generic variant feed).
10. **Coxeter / reflection boundary fractals** — weaker evidence; prototype only.
11. **Fractal interpolation (2D) surfaces** — a raymarched *affine* surface
   exists; a 2D relief/heightfield variant is lower priority.

See `research/fractal-types-sixth-wave/report.md` and
`research/fractal-types-seventh-wave/report.md` for the full evidence and DOIs.

## Skip for now

- Thales/Schottky/Kleinian/Maskit/Riley, Rauzy/substitution tilings,
  Takagi/white noise/Weierstrass, Hilbert/Peano/Gosper, Tinkerbell/Gumowski-Mira,
  Lattès, McMullen, Blaschke, complex Hénon, Lozi/Gingerbreadman, plain Siegel
  disks — already present by name in the app (prior waves).
- Euler/Zeta/Gamma Newton — `zeta_newton` and special-function Newton modules
  already exist.
- fBm/Perlin/Diamond-square terrain, Penrose, Spectre monotile, L-systems,
  fractiflame IFS — already present.
- RF/antenna and image-encryption papers: geometry inspiration only, never an
  app capability claim.

## Suggested implementation order (2D escape-time/field shaders first)

1. **Fixed-point iteration fractal** (scheme parameter) — broadest new visual.
2. **Minkowski question-mark / Stern-Brocot** — cheap, unique, educational.
3. **Möbius-transformation Julia** — bridges Kleinian and escape-time.
4. **Fractional complex cosine map** — quick transcendental win.
5. **Parabolic petal / Leau–Fatou Julia** — distinct organic basins.
6. **Herman-ring / toral-band Fatou** — distinctive annular complex dynamics.
7. **Sierpiński-curve Julia topology** — educational bridge.
8. **Meromorphic composite `z·sin z`** — web-like transcendental.
9. **Baker / wandering-domain transcendental** — safe-preset domain view.
10. **Mandelbrot-percolation random carpet** — small stochastic shader.
11. **Superfractal IFS morpher** — blended random IFS.
12. **Dedekind η / j-invariant field** — modular lace.
13. **Bessel-function fields** — follow-up special-function texture.
14. **Hidden attractor / hyperchaos modules** — attractor-module follow-up.
