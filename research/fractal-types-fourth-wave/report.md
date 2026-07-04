# Fourth-wave fractal types to add

## Method and limits

This extends the previous three research waves after their candidates were implemented or planned. I searched OpenAlex, Crossref, Semantic Scholar, and arXiv through `rforge`, then checked local source/catalog names for likely gaps. Final search coverage after two extra targeted antenna/Minkowski queries: 107 OpenAlex records, 103 Crossref records, 46 Semantic Scholar records, 8 arXiv records, 242 unique DOI-bearing records. One broad OpenAlex antenna query returned empty; the narrower follow-up query worked. No full text was downloaded.

## Bottom line

The best remaining additions are: **fractal antenna / Minkowski/H-tree curves**, **Lévy flight and Brownian path fractals**, **basin-entropy / uncertainty maps**, **circle-packing conformal maps**, and **Ulam-Warburton/toothpick cellular automata**. Julia matings are mathematically interesting but harder to make honest in a quick shader, so treat them as later/prototype-only.

ELI5: add squiggly antenna wires, wandering paths, uncertainty heatmaps, circle-map carpets, and growing toothpick grids.

## Local gap check

Not found in local source names: `fractal antenna`, `Minkowski sausage`, `H-tree`, `Levy flight`, `Brownian motion`, `random walk`, `Newton flow`, `basin entropy`, `fractal basin`, `circle packing`, `conformal map`, `Julia mating`, `Mandelbrot mating`, `iterated monodromy`, `Fuchsian`, `Ulam Warburton`, `toothpick`, `escape-time automata`.

Already found from previous waves: `fractal interpolation`, `bifurcation diagram`, `voronoi fractal`, `strange nonchaotic`, `sphere packing`, `quasicrystal`, `brownian tree`, `plasma`.

## Best next candidates

### 1. Fractal antenna / Minkowski sausage / H-tree curves

- **What it looks like:** compact recursive wire patterns, square squiggles, and branching H networks.
- **Why it fits:** local scan found none of `fractal antenna`, `Minkowski sausage`, or `H-tree`. Repo has Koch/Hilbert/Gosper curves, but this family reads differently: engineered wire traces rather than space-filling paths.
- **Implementation shape:** 2D distance-field shader with mode selector: Minkowski sausage, H-tree, fractal antenna meander.
- **Evidence:** antenna/Minkowski follow-up search returned *Fractal Antennas: An Historical Perspective*, DOI `10.3390/fractalfract4010003`, and *Minkowski Island and Crossbar Fractal Microstrip Antennas for Broadband Applications*, DOI `10.3390/app8030334`.
- **Priority:** high; easy shader, clear gap, distinctive educational/engineering angle.

### 2. Lévy flight / fractional Brownian path renderer

- **What it looks like:** wandering trails with occasional huge jumps, or rough Brownian scribbles.
- **Why it fits:** Brownian tree/DLA exists now, but local scan did not find `Lévy flight`, `Brownian motion`, or `random walk` as standalone path families.
- **Implementation shape:** deterministic hash-driven path shader; mode selector for Brownian, Lévy jump, fractional Brownian drift. Keep it explicitly approximate/static.
- **Evidence:** search returned *Beyond Brownian Motion: A levy flight in magic boots*, DOI `10.1007/BF02902528`, and Brownian-motion-as-random-fractal book chapters.
- **Priority:** high; visually different from DLA because it renders paths, not aggregation.

### 3. Basin entropy / uncertainty map overlay

- **What it looks like:** heatmap showing where nearby points disagree about which attractor/root they reach.
- **Why it fits:** repo has many Newton/root-finding and basin shaders, but local scan did not find `basin entropy` or `fractal basin`. This would add a new analysis/coloring mode rather than another root method.
- **Implementation shape:** 2D shader sampling a small neighborhood around each pixel for Newton/logistic basins, coloring local disagreement/entropy.
- **Evidence:** *Basin entropy: a new tool to analyze uncertainty in dynamical systems*, Scientific Reports, DOI `10.1038/srep31416`; Newton-basin search also returned *Fractal Newton basins*, DOI `10.1155/DDNS/2006/28756`.
- **Priority:** medium-high; excellent educational value, slightly heavier shader.

### 4. Circle-packing conformal map playground

- **What it looks like:** dense circles bending into conformal carpets/maps.
- **Why it fits:** repo has Apollonian/Ford/Steiner and circle inversion, but local scan did not find generic `circle packing` or `conformal map` modules. Add only if visually distinct from Apollonian packings.
- **Implementation shape:** deterministic approximate packing patterns: hex packing warped by analytic maps, loxodromic spirals, or disk-to-square conformal-like transforms.
- **Evidence:** circle-packing search returned *Circle Packing: Experiments in Discrete Analytic Function Theory*, DOI `10.1080/10586458.1995.10504331`, and *An inverse problem for circle packing and conformal mapping*, DOI `10.1090/S0002-9947-1992-1081937-X`.
- **Priority:** medium; good, but overlaps circle/gasket content.

### 5. Ulam-Warburton / toothpick automata

- **What it looks like:** grid growth that blooms as diamond/square fractal shells.
- **Why it fits:** local scan did not find `Ulam Warburton` or `toothpick`; repo has many cellular automata, but these are deterministic growth fractals with a different visual story.
- **Implementation shape:** integer-grid shader using bitwise/popcount-style rules or precomputed generation formula approximations; expose generation/depth and coloring.
- **Evidence:** search returned *On the Number of ON Cells in Cellular Automata*, DOI `10.48550/arxiv.1503.01168`, and Ulam-Warburton cellular automaton engineering results.
- **Priority:** medium; cheap educational CA addition.

### 6. Julia/Mandelbrot matings and iterated monodromy visuals

- **What it looks like:** two Julia sets glued into one sphere-like dynamical object.
- **Why it fits:** local scan did not find `Julia mating`, `Mandelbrot mating`, or `iterated monodromy`; mathematically novel compared with plain Julia variants.
- **Implementation shape:** prototype only first. Honest matings are nontrivial; a fake blend would be misleading. Possible first shader: external-ray/paper-folding-inspired visual rather than claiming full mating.
- **Evidence:** search returned *Mating, paper folding, and an endomorphism of ℙℂ²*, DOI `10.1090/ECGD/302`, and iterated-monodromy-group records.
- **Priority:** low-medium; research/prototype before product catalog.

## Skip for now

- More generic circle/gasket variants unless the circle-packing conformal map is clearly distinct.
- More root-finding methods; basin entropy is the better next root/basin contribution.
- Julia matings as a production module without a prototype and acceptance criteria.

## Suggested next implementation order

1. **Fractal antenna / Minkowski / H-tree curves** — easiest visible gap.
2. **Lévy flight / Brownian path renderer** — new stochastic-path family.
3. **Basin entropy / uncertainty map** — strongest educational analytic feature.
4. **Ulam-Warburton / toothpick automata** — simple deterministic CA growth.
5. **Circle-packing conformal map playground** — add only if distinct from Apollonian/circle inversion.
