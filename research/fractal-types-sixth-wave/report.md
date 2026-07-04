# Sixth-wave fractal types to add

## Method and limits

This pass looked for candidates beyond the already-added research waves. I searched OpenAlex, Crossref, Semantic Scholar, and arXiv through `rforge` with two 8-query passes, then checked app/source names in `lib/`, `shaders/`, and `pubspec.yaml` to avoid obvious duplicates. Coverage from `rforge search stats`: first pass 398 records / 371 unique DOIs; gap pass 350 records / 303 unique DOIs. Citation expansion was run on ten DOI-backed seed records. No PDFs or copyrighted full text were fetched.

Semantic Scholar was rate-limited on most live search queries, so the weakest area is Semantic Scholar coverage for newer CS/graphics records. Existing dirty worktree already contains many previous-wave additions, so this report prefers names that are not already obvious app entries.

## Bottom line

The best next additions are **fractal interpolation surfaces**, **Minkowski question-mark/Stern-Brocot visualizer**, **Möbius-transformation Mandelbrot/Julia sets**, **fractional complex cosine maps**, and **Minkowski-sausage / antenna curve geometry**. Do not spend another wave on Wada, Rauzy, Schottky/Kleinian, Weierstrass/Takagi, Hilbert/Peano, Tinkerbell/Gumowski-Mira, or Lattès unless the implementation is a clearly new view; those names already appear in current app/source files.

ELI5: add a fractal surface, a number-line staircase, a Möbius-twisted Julia toy, a cosine escape map, and a jagged antenna curve.

## Local duplicate check

Already present in app/source names from prior work:

- `Wada / Riddled Basin Visualizer`
- `Rauzy Fractal`, `Arnoux-Rauzy Fractal`, `Fractal dual substitution tiling`
- `Schottky Limit Set`, `Kleinian / Schottky Necklace`, Maskit/Riley-style comments
- `Takagi / Blancmange / Devil Staircase`, `Weierstrass Function`, Weierstrass root/elliptic modules
- `Hilbert Curve`, `Peano Curve`, `Gosper`, `Moore`
- `Tinkerbell`, `Gumowski-Mira`, `Bedhead`
- `Lattès`/Lattes-style entries

Not obvious as app entries, or only partially covered:

- `fractal interpolation surfaces` — only `Fractal Interpolation Curves` was found.
- `Minkowski question mark` — no app hits.
- `Minkowski sausage` — no app hits.
- `Möbius transformation Julia/Mandelbrot` — Möbius is used inside Kleinian code, but no named transformation-family Julia/Mandelbrot module.
- `fractional-order complex cosine map` — no named cosine-map module.

## Best next candidates

### 1. Fractal interpolation surfaces

- **What it looks like:** a heightfield/sheet whose roughness is controlled by interpolation points and vertical scaling; visually between terrain, cloth, and mathematical graph.
- **Why it fits:** app has `Fractal Interpolation Curves`, but not a 2D surface/heightfield version. This is more distinct than another escape-time formula and can reuse renderer/palette infrastructure.
- **Implementation shape:** one 2D shader: sample a small fixed grid of control heights, apply 2–4 self-affine IFS refinement levels or a deterministic approximation, shade as relief/contours.
- **Evidence:** *Fractal Interpolation Surfaces derived from Fractal Interpolation Functions*, Journal of Mathematical Analysis and Applications, 2007, DOI `10.1016/j.jmaa.2007.01.112`; *The Study on Bivariate Fractal Interpolation Functions and Creation of Fractal Interpolated Surfaces*, Fractals, 1997, DOI `10.1142/s0218348x97000504`; `rforge` citation expansion on the 2007 DOI returned 25 edges.
- **Priority:** high.

### 2. Minkowski question-mark / Stern-Brocot visualizer

- **What it looks like:** a singular staircase mapping rationals/continued fractions into a fractal distribution, with optional Stern-Brocot tree bands.
- **Why it fits:** no app hits for `Minkowski question` or `question mark`. It complements Farey/Ford/number-theory visuals without being another prime-grid shader.
- **Implementation shape:** 2D shader: approximate `?(x)` by finite continued-fraction expansion or Stern-Brocot iteration; render graph, derivative heatmap, and rational tree stripes.
- **Evidence:** *Fractal analysis for sets of non-differentiability of Minkowski's question mark function*, Journal of Number Theory, 2008, DOI `10.1016/j.jnt.2007.12.010`; *The Minkowski question mark function: explicit series for the dyadic period function and moments*, Mathematics of Computation, 2010, DOI `10.1090/s0025-5718-09-02263-7`; citation expansion on the 2008 DOI returned 25 edges.
- **Priority:** high educational value, cheap implementation.

### 3. Mandelbrot/Julia sets of Möbius transformations

- **What it looks like:** familiar Mandelbrot/Julia exploration, but the iteration is wrapped by fractional-linear transforms, producing warped basins and circle-preserving distortions.
- **Why it fits:** current source uses Möbius transforms for Kleinian-style modules, but local scan did not find a named `Möbius transformation` Julia/Mandelbrot module. This bridges escape-time and inversive geometry.
- **Implementation shape:** escape-time shader with `z = (a*z+b)/(c*z+d)` as a transform step around a quadratic/rational map; expose transform coefficients through a small stable preset list rather than arbitrary unsafe singular values.
- **Evidence:** *Visualization of Mandelbrot and Julia Sets of Möbius Transformations*, Fractal and Fractional, 2021, DOI `10.3390/fractalfract5030073`; citation expansion returned 25 edges.
- **Priority:** medium-high; watch singularities.

### 4. Fractional-order complex cosine map

- **What it looks like:** transcendental Julia/parameter fields with cosine lobes and fractional-order deformation controls.
- **Why it fits:** no named `cosine map` app hit. It adds a controllable transcendental family instead of another polynomial power.
- **Implementation shape:** start lazy: ordinary complex cosine escape map plus a single `order` exponent/weight; label it as fractional-inspired unless the exact numerical method is implemented.
- **Evidence:** *On the Fractional-Order Complex Cosine Map: Fractal Analysis, Julia Set Control and Synchronization*, Mathematics, 2023, DOI `10.3390/math11030727`; citation expansion returned 25 edges.
- **Priority:** medium; simple visual win, but claim hygiene matters.

### 5. Minkowski sausage / fractal antenna curve

- **What it looks like:** rectilinear Koch-like curve/island used in compact antenna geometry; good for line-art, thickness, and distance-field fills.
- **Why it fits:** no app hits for `Minkowski sausage`; only one generic `fractal antenna` hit. It is visually simple and belongs near IFS/geometric curves.
- **Implementation shape:** line-distance shader for 3–5 recursive levels, with curve/island/patch modes. Avoid RF-performance claims; render geometry only.
- **Evidence:** *Toward an optimum design of fractal sausage Minkowski antenna for GPS applications*, Bulletin of Electrical Engineering and Informatics, 2022, DOI `10.11591/eei.v11i1.3333`; *Fractal antenna based on the Minkowski sausage for digital TV reception*, CISTI 2022, DOI `10.23919/cisti54924.2022.9820022`; citation expansion on the first DOI returned 23 edges.
- **Priority:** medium; easy but less novel than the first three.

### 6. Coxeter/reflection boundary fractals

- **What it looks like:** recursive mirror/reflection domains with fractal boundary dust, adjacent to kaleidoscopes but driven by group words/root systems.
- **Why it fits:** app scan found no `Coxeter`; it could extend existing kaleidoscope/fold shaders with a named mathematical frame.
- **Implementation shape:** prototype-only first: finite reflection group fold field plus boundary accumulation. Do not claim full Coxeter-boundary math until the generator and references are validated.
- **Evidence:** search retrieved *On boundaries of Coxeter groups and topological fractal structures* and related infinite-Coxeter boundary records, but DOI metadata was weak.
- **Priority:** low-medium; promising look, weaker evidence.

## Skip for now

- **Wada/riddled basins** — already implemented by name.
- **Rauzy/substitution tilings** — already implemented by name, including dual substitution.
- **Schottky/Kleinian/Maskit/Riley** — already present enough for now.
- **Takagi/Blancmange/Weierstrass** — already present.
- **Hilbert/Peano/Gosper/Moore** — already present.
- **Tinkerbell/Gumowski-Mira/Bedhead/Lattès** — local source already has these names.
- **RF/antenna papers as performance claims** — okay as geometry inspiration, not as app claims.

## Suggested implementation order

1. **Fractal interpolation surfaces** — biggest new visual gap and shader-feasible.
2. **Minkowski question-mark visualizer** — educational, no current app hits, cheap.
3. **Möbius transformation Julia/Mandelbrot** — bridges existing Kleinian and escape-time systems.
4. **Fractional complex cosine map** — quick transcendental addition with careful naming.
5. **Minkowski sausage curve/island** — easy geometric filler if you want another lightweight module.
