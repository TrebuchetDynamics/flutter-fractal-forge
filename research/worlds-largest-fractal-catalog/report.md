# Toward the Biggest Fractal Catalog in the World

## Method and limits

Retrieval used `rforge v0.1.4` across OpenAlex, Crossref, Semantic Scholar, and arXiv with eight queries focused on fractal catalogs, taxonomies, generation algorithms, escape-time variants, IFS, strange attractors, L-systems, procedural noise, and fractal flames. The sweep returned 452 unique DOI-bearing records. No copyrighted full text was downloaded; this report uses bibliographic metadata/search results plus citation expansion metadata.

Semantic Scholar returned HTTP 429 for `procedural fractal terrain noise algorithms survey` and `strange attractors catalog chaotic maps visualization`, so CS ranking coverage is weaker for those two areas. Broad terms such as “catalog” and “taxonomy” also retrieved unrelated biology/astronomy records, so source titles were filtered for fractal-rendering relevance.

## Bottom line

To build “the biggest catalog in the world,” count **distinct renderable mathematical families and named variants**, not random parameter seeds. The app should grow from the current large thumbnail/module base into a provenance-backed catalog organized by generator type: escape-time, root-finding, rational/transcendental maps, orbit traps/coloring methods, 3D distance-estimated fractals, IFS/geometric fractals, L-systems/plants, strange attractors/maps, cellular automata/reaction-diffusion, procedural noise/terrain, fractal flames/variations, tilings/substitutions, number-theory fractals, and scientific/physical fractals.

Retrieved anchor papers support this split: Norton, **“Generation and display of geometric fractals in 3-D”** (DOI `10.1145/965145.801263`, ACM/Computer Graphics) for geometric 3D fractals; Hart et al., **“Ray tracing deterministic 3-D fractals”** (DOI `10.1145/74333.74363`, ACM SIGGRAPH/Computer Graphics) for ray-traced/distance-style 3D fractals; Musgrave et al., **“The synthesis and rendering of eroded fractal terrains”** (DOI `10.1145/74334.74337`, ACM SIGGRAPH/Computer Graphics) for terrain; Lagae et al., **“A Survey of Procedural Noise Functions”** (DOI `10.1111/j.1467-8659.2010.01827.x`, Computer Graphics Forum) for noise; and Strobin/Swaczyna, **“Algorithms generating images of attractors of generalized iterated function systems”** (DOI `10.1007/s11075-016-0104-0`, Numerical Algorithms) for generalized IFS image generation.

## Main themes

### 1. Catalog strategy: breadth must be structured, not just huge

A “world-largest” catalog needs clear counting rules:

- **Family**: mathematical generator class, e.g. escape-time polynomial, IFS, L-system, ODE attractor.
- **Formula**: distinct equation/rule, e.g. `z^2+c`, Burning Ship, Lorenz, Barnsley fern.
- **Variant**: named formula change, e.g. Multibrot power 3, Celtic Mandelbrot, Clifford butterfly.
- **Preset**: parameter/camera/palette choice; should not inflate catalog size unless marketed as a “preset,” not a fractal type.
- **Renderer path**: shader/CPU/point-cloud/raymarch/mesh; implementation detail, not a catalog count.

Recommended public claim style: “X renderable fractal entries, Y families, Z formulas, plus N presets,” instead of “X fractals” alone.

### 2. Escape-time and root-finding families: easiest path to thousands

These are the highest-leverage families for a Flutter shader app because one fragment shader pattern can support many formulas. Include:

- Mandelbrot / Julia / Multibrot powers
- Burning Ship, Tricorn, Celtic, Buffalo, Phoenix, Nova
- Rational maps and transcendental maps: sine/cosine/exponential/logistic-style complex maps
- Newton, Halley, Householder, Chebyshev, Schröder, Noor/Picard-Mann-style fixed-point methods
- Parameter planes and dynamical planes as separate views when the math meaning differs
- Orbit-trap variants as **coloring modes** unless the geometry formula changes

Retrieved anchors include **“Fractal art using variations on escape time algorithms in the complex plane”** (DOI `10.1080/17513470701210485`) and **“A comparison of fractal dimension estimations for filled Julia fractal sets based on the escape time algorithm”** (DOI `10.1063/1.5095111`).

Code kernel:

```text
for each pixel p:
  z = seed(mode, p, c)
  for n in 0..maxIter:
    z = formula(z, c, params)
    if escaped(z): break
  color = palette(smoothEscape(n, z), orbitTrap(z_history), distanceEstimate)
```

### 3. 3D distance-estimated and geometric fractals: fewer entries, high impact

3D entries are expensive but visually differentiating. Include:

- Mandelbulb powers and variants
- Mandelbox / Amazing Box / Tglad / KIFS fold systems
- Menger sponge, Sierpinski tetrahedron, Koch/snowflake folds
- Quaternion and bicomplex Julia volumes
- Inversive limit sets, Kleinian-like systems, sphere/circle packings

Hart et al., **“Ray tracing deterministic 3-D fractals”** (DOI `10.1145/74333.74363`) and Norton, **“Generation and display of geometric fractals in 3-D”** (DOI `10.1145/965145.801263`) are direct display anchors. Citation expansion produced 74 and 55 edges respectively.

Code kernel:

```text
ray = cameraRay(pixel)
t = 0
repeat maxSteps:
  p = ray.origin + t * ray.dir
  d = distanceEstimator(p, params)
  if d < epsilon: shadeHit(p)
  t += d * safety
```

### 4. IFS/geometric systems: many named classics, different renderer

IFS and substitution/geometric fractals should be first-class, not forced through escape-time. Include:

- Sierpinski triangle/carpet/tetrahedron
- Barnsley fern and variants
- Heighway dragon, Lévy C, twin dragon
- Koch curve/snowflake/islands
- Apollonian gasket/circle packings
- generalized IFS / recurrent IFS / graph-directed IFS

Strobin/Swaczyna, **“Algorithms generating images of attractors of generalized iterated function systems”** (DOI `10.1007/s11075-016-0104-0`, Numerical Algorithms) directly supports the generalized IFS image-generation branch.

Code kernel:

```text
p = initialPoint
for sample in 0..N:
  transform = weightedChoice(transforms)
  p = transform(p)
  accumulate(p)
```

### 5. L-systems and botanical fractals: grammar-based catalog branch

L-systems provide a large branch with clear named rules and visual variety:

- algae, plant, bush, tree, fern grammars
- stochastic L-systems
- parametric/context-sensitive L-systems
- space colonization trees as a related branch

Search retrieved L-system plant work including **“L-System Fractals”** (DOI `10.1016/s0076-5392(07)x8066-4`) and **“Reverse Fractal Design via Lindenmayer Systems Based on Box-Counting Dimension”** (DOI `10.3390/fractalfract10010009`). Prior project research also retrieved Boudon et al., **“L-Py: An L-System Simulation Framework for Modeling Plant Architecture Development Based on a Dynamic Language”** (DOI `10.3389/fpls.2012.00076`).

Code kernel:

```text
word = axiom
repeat depth:
  word = rewrite(word, rules)
segments = turtleInterpret(word, angle, step, stack)
render(segments or instanced branches)
```

### 6. Attractors, maps, cellular automata, and reaction-diffusion

This is the fastest way to add non-Mandelbrot variety:

- ODE attractors: Lorenz, Rössler, Aizawa, Thomas, Chen, Halvorsen, Four-wing
- 2D maps: Clifford, Peter de Jong, Ikeda, Henon, Tinkerbell, Gumowski-Mira, Standard map
- cellular automata: elementary CA rules, Game of Life variants, Brian’s Brain, forest fire
- reaction-diffusion: Gray-Scott presets and Turing patterns

These need point/texture accumulation or grid simulation rather than ordinary escape-time shaders.

Code kernels:

```text
// Attractor
state = initial
repeat N:
  state = integrateOrMap(state, dt, params)
  accumulate(project(state))

// Cellular automaton
repeat steps:
  next[x,y] = rule(neighborhood(current, x, y))
```

### 7. Procedural noise, terrain, and textures

Procedural noise should be cataloged as a family because it generates fractal visual fields:

- fBm, ridged multifractal, turbulence
- Perlin, Simplex/OpenSimplex, Worley/Voronoi, Gabor, wavelet noise
- domain warping and erosion variants
- terrain heightfields and planetary textures

Lagae et al., **“A Survey of Procedural Noise Functions”** (DOI `10.1111/j.1467-8659.2010.01827.x`, Computer Graphics Forum) is the key survey anchor; Musgrave et al., **“The synthesis and rendering of eroded fractal terrains”** (DOI `10.1145/74334.74337`) anchors terrain.

Code kernel:

```text
value = 0
amp = 1
freq = 1
for octave in 0..octaves:
  value += amp * noise(freq * p)
  amp *= persistence
  freq *= lacunarity
```

### 8. Fractal flames and variation systems

Fractal flames can add many entries through variation functions, but catalog hygiene matters. Count a flame entry by a stable transform/variation recipe, not by arbitrary random genome.

Suggested branches:

- affine + nonlinear variation sets
- named variation families: swirl, horseshoe, polar, sinusoidal, spherical, hyperbolic, fisheye, Julia, bent, waves
- curated genomes as presets, not separate formula families unless hand-named and stable

The sweep returned noisy results for “fractal flame variations catalog algorithm,” so treat flame naming as implementation/provenance work rather than a claim backed by one paper in this sweep.

## Proposed world-largest catalog taxonomy

| Top-level family | Target entries | Renderer path | Count rule |
|---|---:|---|---|
| Escape-time polynomial/complex | 500–1500 | fragment shader | formula + exponent/view type |
| Root-finding/polynomiography | 100–400 | fragment shader | method + polynomial family |
| Rational/transcendental maps | 300–1000 | fragment shader | formula identity |
| Orbit traps/coloring modes | 50–200 modes | shader post/color layer | mode, not fractal entry unless geometry changes |
| 3D DE/raymarch | 100–300 | raymarch shader | DE formula/fold system |
| IFS/geometric | 200–600 | point/mesh/accumulation | transform system/rule set |
| L-systems/plants | 100–300 | grammar + turtle/mesh | axiom/rule grammar |
| Strange attractors/maps | 200–800 | point accumulation | ODE/map equation |
| Cellular automata | 300–1000 | grid simulation | rule number/rule family |
| Reaction-diffusion | 50–200 | grid simulation | model + stable preset class |
| Noise/terrain/textures | 100–300 | shader/heightfield | noise basis + fractal composition |
| Tilings/substitution | 100–300 | mesh/recursive geometry | substitution rule |
| Number-theory/special functions | 100–500 | shader/grid | sequence/function identity |
| Fractal flames | 200–1000 | iterated transforms | stable variation recipe |

A credible “largest” target is 5,000–10,000 curated renderable entries, but only if each entry has: stable ID, family, formula/rule, parameters, renderer, thumbnail, provenance, license note if sourced, and visual metrics.

## Performance claims hygiene

Do not claim the catalog is “world’s largest” unless the comparison method is explicit and reproducible. Safe wording: “This is a provenance-backed catalog aiming for the largest renderable fractal catalog in a mobile/web app, with X entries across Y families.” If claiming a rendering method’s speed, name the exact paper or local benchmark. Example safe claim: Lagae et al. (DOI `10.1111/j.1467-8659.2010.01827.x`) surveys procedural noise functions; local app performance for noise shaders must be measured separately.

## Evidence gaps

- No authoritative global registry of every fractal app/catalog was found in this sweep.
- “Fractal flame” literature search was noisy; implementation should use separate provenance records for formulas/variation names.
- Books and classic web resources may define many named fractals but are not fully captured by DOI-based search.
- Semantic Scholar rate-limited two queries, reducing coverage for terrain/noise and attractor catalog ranking.
- Counting rules are a product decision; research can justify taxonomy, not self-approve marketing claims.

## Implications for Flutter Fractal Forge

1. Add a **Catalog Provenance Record** per imported formula/rule before scaling toward thousands.
2. Separate catalog entry from preset: formulas count; random seeds do not.
3. Build family-specific renderers instead of forcing all entries into fragment-shader escape-time.
4. Add family filters and badges: Escape-time, 3D DE, IFS, Attractor, CA, L-system, Noise, Flame, Tiling, Number Theory.
5. Use the existing Visual Fidelity Audit work for launch entries, then apply **Launch Visual Metrics** to any new family representatives.
6. Create a staged ingest pipeline: source list → license/provenance note → formula schema → renderer assignment → thumbnail → metrics → catalog entry.
7. Avoid direct copy-paste from upstream code unless license-compatible and recorded; implement formulas independently from equations/metadata when possible.
