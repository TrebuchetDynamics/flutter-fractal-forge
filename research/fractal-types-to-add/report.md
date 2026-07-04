# Fractal types to add — ELI5 research notes

## Method and limits

I searched OpenAlex, Crossref, Semantic Scholar, and arXiv through `rforge` for fractal graphics families, then compared candidates against the local Dart catalog names. Search coverage: 157 OpenAlex records, 201 Crossref records, 72 Semantic Scholar records, 201 arXiv records, 578 unique DOI-bearing records. No full text was downloaded.

## Bottom line

The app already has a lot: escape-time variants, IFS/geometric sets, cellular automata, strange attractors, flames through V40, tilings, Mandelbulb/Mandelbox, and several hypercomplex slices. The best additions now are not “more Mandelbrot powers”; they are families with visibly different behavior and reusable shader kernels.

ELI5: add new toy boxes, not just new colors for the same toy.

## Best candidates

### 1. 3D Apollonian sphere packing / Soddy spheres

- **What it looks like:** bubbles packed inside bubbles forever.
- **Why it fits:** the app has Apollonian-style 2D coverage, but local scan did not find `sphere packing`, `Soddy`, or `Descartes` sphere support.
- **Implementation shape:** one raymarch shader using sphere inversions / distance estimate.
- **Evidence:** Apollonian packings are established fractal objects; see *Apollonian packings as physical fractals*, Molecular Physics, DOI `10.1080/00268976.2011.630598`.
- **Priority:** high; visually distinct, GPU-friendly.

### 2. Poincare disk hyperbolic tilings

- **What it looks like:** Escher-style tiles getting smaller toward a circle edge.
- **Why it fits:** local scan found hyperbolic/Kleinian items, but no `Poincare` module naming; this can be a clean educational visual family.
- **Implementation shape:** 2D fragment shader mapping pixels to Poincare disk, reflect/fold by triangle groups `{p,q}`.
- **Evidence:** hyperbolic tiling appears in the retrieved literature, e.g. *The finite tiling problem is undecidable in the hyperbolic plane*, DOI `10.1142/S0129054108006078`.
- **Priority:** high; easy controls: `p`, `q`, color mode.

### 3. Circle-inversion gasket playground

- **What it looks like:** circles mirrored through circles until lace-like nests appear.
- **Why it fits:** local scan found `inversion` generally, but not `circle inversion`, `Soddy`, or `Descartes`; this is simpler than full Kleinian 3D.
- **Implementation shape:** 2D iterative inversion shader with 3–5 control circles.
- **Evidence:** related Apollonian/circle-packing searches returned many records, including Apollonian geometry/group theory and packing papers.
- **Priority:** high; small shader, lots of visual payoff.

### 4. Fractal terrain / multifractal noise

- **What it looks like:** mountains, clouds, coastlines.
- **Why it fits:** local scan did not find `terrain`, `Perlin`, `fractional Brownian`, or `ridged multifractal` as catalog concepts.
- **Implementation shape:** one shader with fBm/ridged noise, domain warp, and height-color palette.
- **Evidence:** classic graphics literature treats procedural texture generation as a visual modeling tool; related procedural pattern evidence includes *Generating textures on arbitrary surfaces using reaction-diffusion*, SIGGRAPH, DOI `10.1145/122718.122749`.
- **Priority:** medium-high; not a pure math fractal, but very user-visible.

### 5. Pascal / Ulam / number-theory fractals

- **What it looks like:** triangle grids and spiral grids that reveal hidden patterns.
- **Why it fits:** local scan did not find `Pascal` or `Ulam spiral`; these are simple, educational, and cheap to render.
- **Implementation shape:** integer-grid fragment shader; modulo controls for Pascal, prime/probable-prime coloring for Ulam.
- **Evidence:** this is more recreational/math-visualization than graphics-paper driven; local feasibility is the main evidence.
- **Priority:** medium; easiest educational win.

### 6. Brownian tree / diffusion-limited aggregation proper

- **What it looks like:** lightning, coral, branching mineral growth.
- **Why it fits:** local scan found `DLA (Approximation)` and growth models, but not `Brownian tree`; a deterministic GPU approximation could make this family more explicit.
- **Implementation shape:** cheapest version is a static formula/noise approximation; full particle simulation is heavier.
- **Evidence:** DLA and aggregation appeared in search results; avoid promising physically exact simulation unless implemented.
- **Priority:** medium; add only if we accept approximate rendering.

### 7. Quasicrystal / diffraction-style tiling shaders

- **What it looks like:** symmetric star fields and non-repeating crystal patterns.
- **Why it fits:** local scan did not find `quasicrystal`; complements Penrose/aperiodic tilings.
- **Implementation shape:** sum several plane waves with rotational symmetry; expose fold count and phase.
- **Evidence:** aperiodic tilings/monotiles were well represented in search; e.g. *Fractal dual substitution tilings*, Journal of Fractal Geometry, DOI `10.4171/JFG/37`.
- **Priority:** medium; small shader, distinctive output.

### 8. Robust/polynomiography Newton families

- **What it looks like:** colored basins showing which root each point falls into.
- **Why it fits:** repo already has Newton, Damped Newton, Durand-Kerner, Aberth, Halley-ish variants, so add only if the new method is genuinely different.
- **Implementation shape:** one parametric root-finder shader with method selector.
- **Evidence:** *Polynomiography Based on the Nonstandard Newton-Like Root Finding Methods*, DOI `10.1155/2015/797594`.
- **Priority:** low-medium; good math, but many related items already exist.

## Skip for now

- More plain Multibrot/Burning Ship powers: catalog already has many.
- More fractal flame base variations: local catalog already has V0–V40 including curl, horseshoe, polar, handkerchief, noise, blur, etc.
- More generic strange attractor presets: repo already contains many named attractors; add only well-known missing systems with a new look.

## Suggested first three implementation issues

1. **Add 3D Apollonian sphere packing raymarch shader** — biggest visual gap.
2. **Add Poincare disk hyperbolic tiling shader** — educational and parameter-light.
3. **Add fractal terrain / ridged multifractal shader** — broad user appeal and reusable noise code.
