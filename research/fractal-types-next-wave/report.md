# Next-wave fractal types to add

## Method and limits

This extends `research/fractal-types-to-add/report.md` after the first five candidates were implemented. I searched OpenAlex, Crossref, Semantic Scholar, and arXiv through `rforge`, then checked local catalog/source names for likely gaps. Search coverage: 101 OpenAlex records, 79 Crossref records, 26 Semantic Scholar records, 5 arXiv records, 198 unique DOI-bearing records. arXiv was sparse for these applied graphics queries, including one empty multifractal search file. No full text was downloaded.

## Bottom line

The next best additions are still visually distinct families, not more power variants. The strongest next batch is: **quasicrystal shaders**, **L-system plant/tree renderer**, **Brownian tree/DLA explicit renderer**, **multifractal cascade texture**, and **Kleinian/Schottky circle-chain variants**.

ELI5: add new pattern machines: crystals, plants, lightning trees, cloud blankets, and mirror-world circles.

## Local gap check

Found in repo/source names: `kleinian`, `schottky`, `clifford torus`, `l-system` base/scaffold.

Not found as active catalog families/names: `quasicrystal`, `lindenmayer`, `brownian tree`, `diffusion limited`, `multifractal cascade`, `mandelbrot cascade`, `plasma fractal`, `diamond square`, `random walk`, `midpoint displacement`, `voronoi fractal`, `strange nonchaotic`.

## Best next candidates

### 1. Quasicrystal / diffraction interference shader

- **What it looks like:** non-repeating star-crystal wallpaper.
- **Why it fits:** local scan did not find `quasicrystal`; complements Penrose, Ammann-Beenker, monotiles, and Poincare tilings without needing heavy state.
- **Implementation shape:** 2D shader summing 5/8/10/12 plane waves; params: symmetry count, phase, sharpness.
- **Evidence:** quasicrystal/fractal tiling searches returned current tiling literature, including *Metallic mean fractal systems and their tilings*, Journal of Fractal Geometry, DOI `10.4171/JFG/170`.
- **Priority:** high; smallest shader, very different look.

### 2. Lindenmayer / L-system plants and trees

- **What it looks like:** fernlike branching plants, trees, weeds, seaweed.
- **Why it fits:** repo has an `LSystemModule` base and one promoted `f0054_l_system`-style entry, but no explicit reusable Lindenmayer plant/tree family was found.
- **Implementation shape:** simplest GPU version: deterministic branch-distance field with recursive angle presets; full string-rewrite L-system can wait.
- **Evidence:** *Real time design and animation of fractal plants and trees*, SIGGRAPH/ACM, DOI `10.1145/15886.15892`.
- **Priority:** high; strong user-recognizable category.

### 3. Brownian tree / explicit DLA lightning growth

- **What it looks like:** branching lightning/coral grown by wandering particles.
- **Why it fits:** earlier report found only `DLA (Approximation)`/growth models. Local scan did not find `Brownian tree` or `diffusion limited` naming.
- **Implementation shape:** static deterministic approximation first: hash-driven radial walkers / branch distance field. Do not promise exact particle simulation unless adding compute/state.
- **Evidence:** aggregation searches returned *Fractality à la carte: a general particle aggregation model*, Scientific Reports, DOI `10.1038/srep19505`.
- **Priority:** medium-high; visually strong, but exact DLA is stateful.

### 4. Multifractal cascade / plasma fractal texture

- **What it looks like:** turbulent clouds, lava, marble, weather maps.
- **Why it fits:** first batch added terrain noise; cascade/plasma/diamond-square names are still absent. This is a different “texture fractal” family.
- **Implementation shape:** 2D multiplicative cascade or diamond-square-inspired value field; params: lacunarity, intermittency, bands.
- **Evidence:** terrain/surface synthesis searches returned *Fractal-based analysis and interpolation of 3D natural surface shapes and their application to terrain modeling*, CVGIP, DOI `10.1016/0734-189X(89)90095-9`.
- **Priority:** medium; useful as texture/background family.

### 5. Kleinian / Schottky circle-chain variants

- **What it looks like:** pearl necklaces and mirrored circular tunnels.
- **Why it fits:** repo already has `kleinian`, `schottky`, and new circle inversion, so this is not a first-priority gap. Add only a variant that gives a new view: quasi-Fuchsian mask, necklace chain, or loxodromic spiral.
- **Implementation shape:** 2D circle inversion/Mobius shader variant, not a broad rewrite.
- **Evidence:** *The Intrigues and Delights of Kleinian and Quasi-Fuchsian Limit Sets*, Mathematical Intelligencer, DOI `10.1007/S00283-018-09856-6`; Crossref also returned multiple limit-set/Schottky-group works.
- **Priority:** medium-low; overlaps existing families.

### 6. Voronoi fractal / crackle recursion

- **What it looks like:** cells inside cells, stained glass, cracked ice.
- **Why it fits:** local scan did not find `voronoi fractal`; cheap procedural shader.
- **Implementation shape:** recursive Voronoi distance with domain folding and jitter.
- **Evidence:** less direct in this sweep; this is a local-feasibility/art-direction candidate, not a literature-backed math priority.
- **Priority:** low-medium; easy filler after stronger gaps.

### 7. Strange nonchaotic attractor / quasiperiodic map

- **What it looks like:** wispy attractor bands that are not classic Lorenz/Clifford blobs.
- **Why it fits:** repo has many strange attractors; this is only worth it if it looks distinct.
- **Implementation shape:** 2D iterative map shader with quasiperiodic forcing.
- **Evidence:** not strong enough in this quick next-wave sweep to outrank visual/procedural gaps.
- **Priority:** low.

## Skip for now

- More Newton/root-finding method variants: repo already has many.
- More named strange attractors without a visual gap check: catalog already has broad coverage.
- More Apollonian/circle-inversion variants immediately: first batch just added these.
- More terrain-only noise unless it is cascade/plasma/distinct from the new terrain shader.

## Suggested next implementation order

1. **Quasicrystal interference shader** — easiest, obvious gap.
2. **L-system plants/trees** — recognizable and repo has scaffold hints.
3. **Brownian tree / explicit DLA renderer** — strong visual, approximate first.
4. **Multifractal cascade / plasma texture** — complements terrain.
5. **Kleinian/Schottky necklace variant** — only if a new visual preset is clearly different.
