# Seventh-wave fractal types to add

## Method and limits

This pass looked for candidates after the prior waves, especially names not already obvious in current `lib/`, `shaders/`, or `pubspec.yaml`. I ran two `rforge` search batches over OpenAlex, Crossref, Semantic Scholar, and arXiv: an 8-query broad pass and an 8-query gap pass. Official `rforge search stats` coverage: first pass 485 records / 411 unique DOIs; gap pass 456 records / 422 unique DOIs. Citation expansion was attempted on nine DOI seeds and succeeded for seven. No PDFs or copyrighted full text were fetched.

Semantic Scholar rate-limited several live searches and two citation-expansion attempts; arXiv returned HTTP 503 for one Sierpiński-curve Julia query. Those failures are recorded in `failures.jsonl` and `provenance.json`.

## Bottom line

The best remaining additions are **Herman-ring / toral-band Fatou visualizers**, **Mandelbrot-percolation random carpets**, **Sierpiński-curve Julia topology views**, **random/nonlinear IFS superfractal morphers**, **Baker/wandering-domain transcendental maps**, and **Bessel-function fractal fields**. Skip McMullen maps, Blaschke products, complex Hénon slices, Lozi/Gingerbreadman maps, and plain Siegel-disk Julia presets for this wave because those names already appear in app/source files.

ELI5: add donut-shaped Julia regions, random hole carpets, Julia sets shaped like Sierpiński carpets, shuffled IFS fractals, runaway transcendental domains, and Bessel-function texture fields.

## Local duplicate check

Already present or substantially covered in app/source names:

- `McMullen Map`, `Generalized McMullen`, and `Bedford-McMullen Carpet`
- `Blaschke Product` with Cantor-circle comments/presets
- `Complex Hénon Julia Slice`
- `Lozi Map`, `Gingerbreadman Map`
- `Siegel Disk` Julia preset

Not obvious as app entries:

- `Herman ring` / toral-band Fatou components
- `fractal percolation`, `Mandelbrot percolation`, random Sierpiński carpets
- `Sierpiński curve Julia` topology as a named module
- `superfractal`, random/nonlinear IFS morphing
- `Baker domain`, `wandering domain`
- `Bessel` fractal fields

## Best next candidates

### 1. Herman-ring / toral-band Fatou visualizer

- **What it looks like:** annular/donut-like invariant regions in rational or meromorphic dynamics, with Julia boundaries wrapping around holes.
- **Why it fits:** app has Siegel-disk presets, Blaschke/Cantor-circle rational maps, and many Julia variants, but no named Herman-ring module.
- **Implementation shape:** one rational-map shader with safe presets known to produce annular Fatou components; color by basin/rotation estimate and highlight ring boundaries. Avoid arbitrary coefficients that hit poles too often.
- **Evidence:** *The Fine Structure of Herman Rings*, Journal of Geometric Analysis, 2015/2017 metadata, DOI `10.1007/s12220-017-9764-9`; *Single and double toral band Fatou components in meromorphic dynamics*, Conformal Geometry and Dynamics, 2023, DOI `10.1090/ecgd/380`; *Siegel discs, Herman rings and the Arnold family*, Transactions of the AMS, 2001, DOI `10.1090/s0002-9947-01-02662-9`. Citation expansion succeeded for the first two seeds, though the first returned 0 edges.
- **Priority:** high; visually distinct from another Julia color mode.

### 2. Mandelbrot-percolation / random Sierpiński carpet

- **What it looks like:** stochastic Sierpiński-like carpets where squares disappear by seeded random rules; same seed gives reproducible output.
- **Why it fits:** app has deterministic carpets and cellular/stochastic shaders, but no `Mandelbrot percolation` or random carpet module names.
- **Implementation shape:** 2D shader with hash-based subdivision: at each level keep/drop cells by threshold and seed; expose probability, depth, and seed.
- **Evidence:** *The existence of phase V in the Mandelbrot percolation process*, 1995, DOI `10.1007/bf02179876`; *Percolation in random-Sierpiński carpets: A real space renormalization group approach*, Physical Review E, 1996, DOI `10.1103/physreve.54.4590`; `rforge` citation expansion on the PRE DOI returned 21 edges.
- **Priority:** high; cheap, interactive, and non-duplicate.

### 3. Sierpiński-curve Julia topology view

- **What it looks like:** Julia sets whose complementary domains make carpet/curve topology rather than the usual blob/filament look.
- **Why it fits:** app has Sierpiński geometric fractals and many Julia sets, but no named bridge: `Sierpiński-curve Julia`.
- **Implementation shape:** rational-map escape shader with curated presets from Sierpiński-curve Julia families; include a topology-focused description, not just a generic Julia preset.
- **Evidence:** *Sierpiński and non-Sierpiński curve Julia sets in families of rational maps*, Journal of the London Mathematical Society, 2008, DOI `10.1112/jlms/jdn030`; *Sierpiński Curve Julia Sets of Rational Maps*, Computational Methods and Function Theory, 2006, DOI `10.1007/bf03321617`; citation expansion on the JLMS DOI returned 15 edges.
- **Priority:** medium-high; good educational bridge between IFS and complex dynamics.

### 4. Random/nonlinear IFS superfractal morpher

- **What it looks like:** fern/carpet/dragon-like attractors that switch between small IFS rule sets, giving families of related shapes instead of one fixed attractor.
- **Why it fits:** current catalog has many deterministic IFS/geometric entries but no `superfractal`, `random IFS`, or nonlinear-IFS morphing module names.
- **Implementation shape:** lightweight point-accumulation or fragment approximation: select one of 2–4 transform families by seeded probability per iteration; expose family mix and seed.
- **Evidence:** *SuperFractals*, 2006, DOI `10.1017/cbo9781107590168.006`; *Modeling and rendering of nonlinear iterated function systems*, Computers & Graphics, 1994, DOI `10.1016/0097-8493(94)90169-4`; *Image based rendering of iterated function systems*, Computers & Graphics, 2004, DOI `10.1016/j.cag.2004.08.005`. Citation expansion for the first two seeds failed (404/429), so this candidate rests on retrieved metadata rather than citation graph coverage.
- **Priority:** medium; strong catalog leverage, but implementation should stay simple.

### 5. Baker/wandering-domain transcendental maps

- **What it looks like:** domains that escape or wander under transcendental iteration, often forming nested tracts and web-like Julia boundaries.
- **Why it fits:** app has transcendental maps, but local scan found no `Baker domain` or `wandering domain` module names.
- **Implementation shape:** shader for `z -> z + 1 + a*exp(-z)` or similar safe transcendental presets; color by escape tract, iterate displacement, and domain-change bands.
- **Evidence:** *On wandering and Baker domains of transcendental entire functions*, International Journal of Bifurcation and Chaos, 2004, DOI `10.1142/s021812740400903x`; *Some entire functions with multiply-connected wandering domains*, Ergodic Theory and Dynamical Systems, 1985, DOI `10.1017/s0143385700002832`; citation expansion on the 2004 DOI returned 6 edges.
- **Priority:** medium; mathematically distinct, but needs conservative naming.

### 6. Bessel-function fractal fields

- **What it looks like:** oscillatory rings, zero contours, and interference-like bands from Bessel functions, rendered as scalar fields or Newton basins.
- **Why it fits:** app has many special/trig functions but local scan found no `Bessel` app entries.
- **Implementation shape:** start as a scalar-field shader using a stable Bessel approximation and zero/phase contour coloring. Only add Newton basins later if root-finding is numerically stable.
- **Evidence:** *Fractal properties of Bessel functions*, Applied Mathematics and Computation, 2016, DOI `10.1016/j.amc.2016.02.025`; citation expansion returned 22 edges. Related search records covered Airy/Bessel numerical methods, but direct Airy/Gamma fractal evidence was weaker.
- **Priority:** medium-low; good visual texture, but less canonical as a “fractal type.”

## Skip for now

- **McMullen / Generalized McMullen** — already present.
- **Blaschke products / Cantor circles** — already present enough.
- **Complex Hénon, Lozi, Gingerbreadman** — already present.
- **Plain Siegel disks** — already present as Julia presets; only add Herman rings if the annular behavior is explicit.
- **Airy/Gamma Julia claims** — retrieved evidence was too weak for a headline candidate; keep as future special-function exploration.

## Suggested implementation order

1. **Mandelbrot-percolation random carpet** — smallest shader, clear gap.
2. **Herman-ring / toral-band Fatou visualizer** — strongest new complex-dynamics look.
3. **Sierpiński-curve Julia topology view** — educational bridge module.
4. **Random/nonlinear IFS superfractal morpher** — broader IFS family with one module.
5. **Baker/wandering-domain transcendental maps** — add if stable presets are found.
6. **Bessel-function fractal fields** — add as special-function texture/contour module, not overclaimed.
