# Fifth-wave fractal types to add

## Method and limits

This extends the prior four research waves after their candidates were implemented or queued. I searched OpenAlex, Crossref, Semantic Scholar, and arXiv through `rforge`, then checked local source/catalog names for likely gaps. Search coverage: 44 OpenAlex records, 120 Crossref records, 70 Semantic Scholar records, 63 arXiv records, 264 unique DOI-bearing records. No full text was downloaded.

## Bottom line

The remaining promising additions are more specialized: **Newton-flow stream/basin fields**, **Wada/riddled basin boundary visualizers**, **external-ray/equipotential overlays**, **Fuchsian/quasi-Fuchsian limit-set masks**, and **wild-knot / Indra's Pearls-inspired limit sets**. Julia matings are interesting but should stay prototype-only until we can validate the math and avoid a misleading blend.

ELI5: add flowing root maps, impossible shared borders, Mandelbrot guide-lines, hyperbolic masks, and knotted pearl fractals.

## Local gap check

Not found in local source names: `newton flow`, `wada`, `riddled basin`, `fractal knots`, `wild knots`, `fuchsian`, `klein quartic`, `riemann surface`, `julia mating`, `mandelbrot mating`, `iterated monodromy`, `external rays`, `equipotential`, `escape-time automata`, `substitution system`.

Already found from prior waves or existing repo: `basin entropy`, `fractal antenna`, `circle packing`, `domain coloring`, `magnetic pendulum`, `pinwheel`, `rauzy`.

## Best next candidates

### 1. Newton-flow streamlines and continuous basins

- **What it looks like:** flow-field arrows/stream ribbons sliding into polynomial roots, with fractal separatrices.
- **Why it fits:** repo has many discrete Newton/root methods and basin colors, but local scan did not find `newton flow` or continuous Newton visualizations.
- **Implementation shape:** 2D shader: evaluate `dz/dt = -f(z)/f'(z)` direction field, draw LIC-like streaks or stream contours, with root colors underneath.
- **Evidence:** search returned *Fractal Newton basins*, DOI `10.1155/DDNS/2006/28756`, and continuous Newton-method approximation records.
- **Priority:** high; reuses root math but gives a new visual language.

### 2. Wada / riddled basin boundary visualizer

- **What it looks like:** colored regions where every boundary point touches three or more outcomes.
- **Why it fits:** `basin_entropy_uncertainty` was added, but local scan still found no `wada` or `riddled basin`. This is a stricter boundary property and can be a separate educational module.
- **Implementation shape:** shader samples three/four attractor outcomes around each pixel and highlights multi-outcome neighborhoods; use a simple three-well or magnetic-pendulum-like map.
- **Evidence:** search returned *Fractal and Wada escape basins in the chaotic particle drift motion in tokamaks*, DOI `10.1063/5.0147679`, and *A test for fractal boundaries based on the basin entropy*, DOI `10.1016/j.cnsns.2020.105588`.
- **Priority:** high; strong educational extension of basin entropy.

### 3. External rays and equipotential overlays

- **What it looks like:** guide-lines around Mandelbrot/Julia sets, like contour maps and rays pointing to features.
- **Why it fits:** local scan did not find `external rays` or `equipotential`; current Mandelbrot variants focus on coloring, not explanatory overlays.
- **Implementation shape:** 2D Mandelbrot/Julia shader with potential field contours plus approximate external-angle rays. Could be an overlay module rather than a new fractal family.
- **Evidence:** *Drawing and computing external rays in the multiple-spiral medallions of the Mandelbrot set*, Computers & Graphics, DOI `10.1016/j.cag.2008.04.005`; also *Mandelbrot Set as a Particular Julia Set of Fractional Order, Equipotential Lines and External Rays...*, DOI `10.3390/fractalfract8010069`.
- **Priority:** high; educational, user-visible, not another formula variant.

### 4. Fuchsian / quasi-Fuchsian limit-set masks

- **What it looks like:** hyperbolic-circle dust and lace on the disk boundary, between Poincare tiling and Kleinian pearls.
- **Why it fits:** repo now has Poincare tilings and Kleinian/Schottky visuals, but local scan did not find `fuchsian` or `quasi-fuchsian`.
- **Implementation shape:** 2D disk shader with Möbius generators/folds; color by word length or generator sequence.
- **Evidence:** *Fuchsian groups of the second kind and representations carried by the limit set*, DOI `10.1007/s002220050117`, plus several Fuchsian limit-set search hits.
- **Priority:** medium-high; overlaps hyperbolic work but fills a named gap.

### 5. Wild-knot / Indra's Pearls-inspired limit sets

- **What it looks like:** pearl chains forming knotted loops or tangled limit sets.
- **Why it fits:** local scan did not find `wild knots` or `fractal knots`; existing Kleinian/circle modules are unknotted pearls.
- **Implementation shape:** start as a 2D/3D raymarch-inspired projection: torus-knot guide curve plus inversion pearls; avoid claiming exact wild-knot topology unless verified.
- **Evidence:** *Wild Knots as Limit Sets of Kleinian Groups*, DOI `10.1090/CONM/389/07276`, and *A wild knot S² ↪ S⁴ as limit set of a Kleinian group: Indra's pearls in four dimensions*, DOI `10.1142/S0218216507005610`.
- **Priority:** medium; high visual payoff, but math honesty needs care.

### 6. Julia/Mandelbrot mating prototype

- **What it looks like:** two Julia worlds glued by external-ray structure.
- **Why it fits:** local scan did not find `Julia mating`, `Mandelbrot mating`, or `iterated monodromy`. It is mathematically distinct from simple side-by-side Julia dual views.
- **Implementation shape:** prototype first: external-ray/paper-folding inspired visualization. Do not ship a fake blended Julia as “mating.”
- **Evidence:** *Mating, paper folding, and an endomorphism of ℙℂ²*, DOI `10.1090/ECGD/302`, and iterated-monodromy-group search results.
- **Priority:** low-medium; research/prototype before catalog.

## Skip for now

- More plain root-finding methods; Newton-flow/Wada/external rays add more value.
- More generic Kleinian pearls unless the new module is explicitly Fuchsian or knot-inspired.
- Julia matings as production without a math-validation prototype.

## Suggested next implementation order

1. **External rays/equipotential overlay** — best educational payoff and shader-feasible.
2. **Newton-flow streamlines** — reuses root math, new look.
3. **Wada/riddled basin visualizer** — extends basin entropy with a named phenomenon.
4. **Fuchsian/quasi-Fuchsian limit set** — fills hyperbolic group gap.
5. **Wild-knot pearl limit set** — prototype carefully, then add if visually/topologically honest.
