# Third-wave fractal types to add

## Method and limits

This extends the prior reports after the first two implementation waves. I searched OpenAlex, Crossref, Semantic Scholar, and arXiv through `rforge`, then checked local source/catalog names for likely gaps. Search coverage: 100 OpenAlex records, 120 Crossref records, 25 Semantic Scholar records, 6 arXiv records, 239 unique DOI-bearing records. arXiv timed out on two queries but wrote error files; no full text was downloaded.

## Bottom line

The best remaining additions are educational/visual families that are still missing from catalog names: **bifurcation diagrams**, **Voronoi fractal/crackle recursion**, **fractal interpolation curves/surfaces**, **Takagi/blancmange/devil-staircase functions**, and **strange nonchaotic attractors**. Laplacian growth is visually good too, but overlaps existing dielectric-breakdown/growth shaders, so it should be a variant only if it looks clearly different.

ELI5: add chaos charts, cracked-cell patterns, jagged math graphs, staircase fractals, and weird almost-chaos ribbons.

## Local gap check

Found in repo/source names: `quasicrystal`, `l-system`, `brownian tree`, `plasma`, `sphere packing`, `kleinian`, `schottky`, `percolation cluster`, `pascal`.

Not found in local source names: `voronoi fractal`, `bifurcation diagram`, `fractal interpolation`, `levy flight`, `brownian motion`, `laplacian growth`, `fractal antenna`, `minkowski sausage`, `takagi`, `blancmange`, `devil staircase`, `cantor function`, `strange nonchaotic`, `basin entropy`, `newton flow`.

## Best next candidates

### 1. Bifurcation diagram explorer

- **What it looks like:** a barcode/tree of chaos as a parameter changes.
- **Why it fits:** repo has Lyapunov/logistic-map style shaders, but local scan did not find `bifurcation diagram`.
- **Implementation shape:** 2D shader: x-axis = parameter, y-axis = orbit value; iterate logistic/tent/sine map and plot settled orbit density.
- **Evidence:** search returned multiple logistic-map bifurcation records, including *The Complete Bifurcation Diagram for the Logistic Map*, DOI `10.1515/zna-1997-6-708`.
- **Priority:** high; educational, cheap, distinctive.

### 2. Voronoi fractal / recursive crackle cells

- **What it looks like:** stained glass, cracked ice, cells inside cells.
- **Why it fits:** local scan did not find `voronoi fractal`; it complements terrain/plasma procedural shaders.
- **Implementation shape:** 2D recursive Voronoi distance field with jitter, domain folding, and nested cell levels.
- **Evidence:** direct “Voronoi fractal” academic hits were sparse, but procedural Voronoi-style graphics are established; related search returned *Procedural voronoi foams for additive manufacturing*, DOI `10.1145/2897824.2925922`.
- **Priority:** high; small shader, high visual payoff.

### 3. Takagi / blancmange / devil-staircase functions

- **What it looks like:** a jagged never-smooth wave and a staircase with infinitely many steps.
- **Why it fits:** local scan did not find `takagi`, `blancmange`, `devil staircase`, or `cantor function`. These are simple number-theory/analysis visuals.
- **Implementation shape:** 2D graph shader with mode selector: Takagi/blancmange, Cantor function, devil staircase/mode-locking approximation.
- **Evidence:** search returned *The Blancmange Function: Continuous Everywhere but Differentiable Nowhere*, DOI `10.2307/3617301`, and devil-staircase/mode-locking records.
- **Priority:** medium-high; easy educational win.

### 4. Fractal interpolation curves / random fields

- **What it looks like:** smooth-ish curves and surfaces that become jagged at every zoom.
- **Why it fits:** local scan did not find `fractal interpolation`; useful bridge between math graphing and terrain/noise.
- **Implementation shape:** 2D graph/surface shader using affine fractal interpolation or midpoint-displacement-like interpolation; params: roughness and control-point seed.
- **Evidence:** *From splines to fractals*, SIGGRAPH, DOI `10.1145/74334.74338`; also `IFS fractal interpolation for 2D and 3D visualization`, DOI `10.1109/visual.1995.480798`.
- **Priority:** medium; good if the app wants more math-function visuals.

### 5. Strange nonchaotic attractor / quasiperiodic map

- **What it looks like:** wispy bands that are fractal-like but not ordinary chaotic attractors.
- **Why it fits:** repo has many attractors; local scan did not find `strange nonchaotic`.
- **Implementation shape:** 2D iterative map shader with quasiperiodic forcing; plot density or escape/phase coloring.
- **Evidence:** search returned *Fractal structures in nonlinear dynamics*, Reviews of Modern Physics, DOI `10.1103/revmodphys.81.333`, and newer quasiperiodic-attractor records.
- **Priority:** medium; add only if preview differs from existing attractors.

### 6. Laplacian growth / viscous fingering variant

- **What it looks like:** branching fingers like fluid pushed through cracks.
- **Why it fits:** local scan did not find `laplacian growth`, but repo already has dielectric breakdown/growth-style shaders, so this may overlap.
- **Implementation shape:** static potential-field approximation or radial harmonic field; avoid claiming exact simulation without state.
- **Evidence:** search returned *Simple Models for Colloidal Aggregation, Dielectric Breakdown and Mechanical Breakdown Patterns*, DOI `10.1007/978-94-009-2653-0_30`, and Laplacian-growth records.
- **Priority:** medium-low; only if visually distinct from dielectric breakdown.

### 7. Fractal antennas / Minkowski sausage curves

- **What it looks like:** compact squiggly wire curves with repeated right-angle detail.
- **Why it fits:** local scan did not find `fractal antenna` or `minkowski sausage`; repo has many curves, so this is a small addition not a gap-filler.
- **Implementation shape:** 2D IFS/distance-field curve shader.
- **Evidence:** not deeply searched in this pass; local gap/art-direction candidate.
- **Priority:** low-medium.

## Skip for now

- More plain random-walk/Brownian motion: Brownian tree/DLA was just added and direct local names are still enough.
- More generic growth models unless visually distinct from DLA/dielectric breakdown/percolation.
- More curve variants unless they are widely recognized educational examples.

## Suggested next implementation order

1. **Bifurcation diagram explorer** — clearest educational gap.
2. **Voronoi fractal/crackle shader** — easiest visual procedural gap.
3. **Takagi/blancmange/devil-staircase graph shader** — simple math-function family.
4. **Fractal interpolation curve/surface shader** — useful if graph visuals are desired.
5. **Strange nonchaotic attractor** — good but verify distinctness before adding.
