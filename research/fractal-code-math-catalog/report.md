# Fractal code/math catalog research: all kinds, displayable

## Method and limits

Standard ResearchForge sweep. Six query variants were run across OpenAlex, Crossref, Semantic Scholar, and arXiv, then `rforge search stats --dir .` reported 485 total records across source files and 356 unique DOIs. Citation expansion was attempted and succeeded for five DOI seeds spanning escape-time/GPU fractals, iterated function systems, cellular automata, visualization algorithms, and fractal/flame-adjacent literature.

Limits: this report uses metadata/abstract-level search records and citation graphs only. No copyrighted full text was downloaded. Search terms are biased toward renderable mathematical/code families useful for a catalog, not toward every scientific use of fractal analysis.

## Bottom line

For “biggest catalog in the world,” the evidence supports counting deterministic mathematical identities: escape-time formulas, IFS transform systems, L-systems/grammars, cellular automaton rules, strange-attractor maps, root-finding maps, rational/transcendental maps, fractal flames, and 3D distance-estimated systems. The strongest scalable path is rule/formula families with explicit parameters and renderer support, especially Life-like cellular automata, elementary CA, coefficient-map attractors, fractal-flame variations, and parameterized escape-time families.

## Main themes

### 1. Escape-time and polynomial/root-finding fractals

Search results surfaced work on combined polynomial root-finding methods and fractal patterns, e.g. **“Fractal patterns from the dynamics of combined polynomial root finding methods”** (DOI `10.1007/s11071-017-3813-6`). This supports a catalog family where each counted entry is a map or iteration formula, such as Mandelbrot/Julia variants, Newton maps, Nova, Halley, Chebyshev, Secant, and trigonometric escape maps.

GPU/rendering search results also returned **“GPU-Accelerated Rendering of Unbounded Nonlinear Iterated Function System Fixed Points”** (DOI `10.5402/2012/825782`) and “Implementation and Analysis of Fractals Shapes using GPU-CUDA Model” (DOI `10.25007/ajnu.v10n2a1030`). These support renderer-first catalog implementation, but performance claims must stay paper-specific.

### 2. IFS, deterministic geometric fractals, and 3D fractals

IFS/rendering search found canonical computer graphics records: **“Rendering algorithms for deterministic fractals”** (DOI `10.1109/38.364961`), **“Efficient antialiased rendering of 3-D linear fractals”** (DOI `10.1145/127719.122728`), and **“Ray tracing deterministic 3-D fractals”** (DOI `10.1145/74333.74363`). These motivate stable entries for Sierpinski variants, Menger/KIFS, Koch folds, Apollonian/Ford/Circle systems, and deterministic 3D distance estimators.

The IFS sweep also found **“On bounding boxes of iterated function system attractors”** (DOI `10.1016/s0097-8493(03)00035-9`) and **“Construction of fractal objects with iterated function systems”** (DOI `10.1145/325334.325245`), reinforcing that transform systems are countable mathematical identities.

### 3. Cellular automata as scalable rule catalogs

Cellular automata search found **“Using Shape Grammar to Derive Cellular Automata Rule Patterns”** (DOI `10.25088/complexsystems.17.1.79`) plus broader CA literature. For this app goal, CA are unusually valuable: elementary CA rules 0–255 and Life-like B/S masks are deterministic rules, not presets. A catalog can count each explicit rule identity if renderer support exposes the rule/masks and validation ignores palettes/camera views.

This is the cleanest high-cardinality path because a B/S Life-like rule is mathematically specified by two 9-bit masks. Counting must avoid duplicate aliases like named Life variants already represented by the same mask.

### 4. Strange attractor coefficient maps

The search space supports many named maps: Hénon, Lozi, Tinkerbell, Clifford, Peter de Jong, Svensson, Gumowski–Mira, Hopalong, Standard Map, Zaslavsky, Bogdanov, Lorenz/Rössler/Chen flows, etc. A safe catalog counts a coefficient tuple as an identity only when the tuple is explicit and the shader exposes those coefficients.

Practical implementation pattern: use shared builders for coefficient-map families and tests that enforce unique coefficient tuples. Do not count visual aliases or duplicate coefficient sets.

### 5. Fractal flames and variation rules

The sweep includes flame-adjacent retrieval (some hits are combustion “flame” false positives), so provenance is critical. For actual fractal-flame catalog work, the count-safe unit is the variation formula/rule (linear, sinusoidal, spherical, swirl, horseshoe, polar, handkerchief, etc.) or a named transform recipe with explicit coefficients. Do not count random flame seeds or palette variants.

### 6. Visualization and code/display literature

Visualization-oriented search returned **“Generation and display of geometric fractals in 3-D”** (DOI `10.1145/965145.801263`) and **“From splines to fractals”** (DOI `10.1145/74334.74338`). These support a display-first implementation requirement: every counted entry should have a renderer path and thumbnail/accessibility plan. A manifest alone is not enough.

## Performance claims hygiene

Do not make broad claims like “GPU fractals are real-time” without naming the exact paper, hardware, resolution, and algorithm. Safe example: search results include **“GPU-Accelerated Rendering of Unbounded Nonlinear Iterated Function System Fixed Points”** (DOI `10.5402/2012/825782`), but any speed/performance claim must be scoped to that paper’s reported setup. For catalog validation, prefer renderer existence, shader compile/run tests, and thumbnail quality checks over headline timing claims.

## Evidence gaps

- Many search records are about fractal analysis in applications, not renderable fractal formulas.
- Fractal-flame retrieval needs careful filtering because “flame” strongly matches combustion literature.
- DOI metadata often omits exact formulas; source metadata or code review is needed before promotion.
- Large generated rule families need duplicate-risk audits so aliases do not inflate counts.
- Thumbnail sharing for generated rule families should be explicit in the thumbnail plan/provenance.

## Implications for Flutter Fractal Forge

1. Maintain a counted-entry ledger where each entry names a formula/rule, renderer path, provenance, and thumbnail plan.
2. Use parameterized shared builders for large families: Life-like CA masks, elementary CA, coefficient maps, fractal-flame variations, Multibrot/power families, trap modes, and IFS transform systems.
3. Keep validators strict: no random presets, camera views, palettes, or thumbnail-only variants count.
4. For “biggest catalog,” rule families are necessary; hand-curated named formulas alone will not reach 5k–10k quickly.
5. The current app should continue pairing any large generated family with accessible labels and evidence that shader parameters distinguish the mathematical identities.
