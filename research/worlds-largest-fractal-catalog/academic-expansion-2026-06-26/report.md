# Academic expansion plan for Flutter Fractal Forge

## Method and limits

Saved under `research/worlds-largest-fractal-catalog/academic-expansion-2026-06-26/`.

Search depth: standard-plus. I swept the requested 10 query families plus 6 focused follow-ups for Lattès maps, Klausmeier vegetation patterns, Arnoux-Rauzy substitutions, cyclic CA, Greenberg-Hastings CA, and rational Lattès formulas. Sources: OpenAlex, Crossref, Semantic Scholar, and arXiv. No full text was downloaded.

Source coverage from `rforge search stats --dir .`:

- OpenAlex: 151 records
- Crossref: 160 records
- Semantic Scholar: 60 records
- arXiv: 160 records
- Total unique DOIs: 433

I also exported `existing-catalog-ids-names.txt` from the live registry and excluded obvious existing catalog identities.

## Bottom line

The strongest additions are not more Mandelbrot variants. The best evidence-backed catalog expansion is: linear/fractal cellular automata, excitable-media cellular automata, Klausmeier vegetation reaction-diffusion, Lattès rational-map Julia sets, and substitution/dual-substitution tiling families.

## Ranked candidates

See `candidates.csv` for formula/rule, defaults, feasibility, citations, and duplicate notes.

Top implementation candidates:

1. **Rule 90 / Rule 150 linear cellular automata** — rank 5, shader-easy. DOI `10.1016/0022-0000(92)90007-6` supports self-similarity of linear CA.
2. **Klausmeier banded vegetation model** — rank 5, shader-medium. DOI `10.1088/0951-7715/23/10/016` supports banded vegetation model pattern solutions.
3. **Lattès rational map Julia set** — rank 5, shader-medium. DOI `10.3934/jmd.2019014` supports Lattès maps in complex dynamics.
4. **Cyclic cellular automaton spiral waves** — rank 4, shader-easy. DOI `10.1142/s0217984997001572` supports cyclic CA spiral waves.
5. **Greenberg-Hastings excitable cellular automaton** — rank 4, shader-easy. DOI `10.25088/complexsystems.27.2.101` supports Greenberg-Hastings CA dynamics.
6. **Arnoux-Rauzy substitution fractal** — rank 4, shader-medium. DOI `10.1051/ita/2014008` supports Arnoux-Rauzy substitution fractals.
7. **Fractal dual substitution tilings** — rank 4, shader-medium. DOI `10.4171/jfg/37` supports fractal dual substitution tilings.

## Main themes

### Cellular automata are underused relative to evidence

The catalog has Rule 30, Wireworld, turmites, and some life-like patterns, but not the canonical linear XOR CA family. Rule 90/150 are small to implement and visually unmistakable. Cyclic CA and Greenberg-Hastings add excitable-media waves without needing PDE textures.

### Reaction-diffusion should branch beyond chemistry presets

Existing entries cover Gray-Scott/Brusselator/Schnakenberg-style chemistry. Klausmeier adds a different mechanism: ecological water/biomass interaction with advection, producing banded vegetation. This is visually distinct and academically grounded.

### Rational complex dynamics can add named non-polynomial maps

Lattès maps fill a gap between polynomial escape-time sets and generic rational-map demos. They are named, cited, and implementable with a single rational formula plus pole guards.

### Tiling expansion should prefer substitution families over cosmetic tile presets

Arnoux-Rauzy and dual-substitution tilings add mathematically named substitution systems. They should be admitted as distinct families only if UI copy distinguishes them from existing Rauzy/Tribonacci entries.

### Root-finding basins need care to avoid duplicates

The search returned many root-finding basin papers. Because the app already has many named solvers, only parameterized or combined-method dynamics are worth adding. Fixed Jarratt/King/Halley-style methods are likely duplicates or near-duplicates.

## Performance claims hygiene

No speed/performance claims are made from the literature. Shader feasibility is an implementation estimate from formula shape only:

- **easy**: no texture feedback or only local discrete rules;
- **medium**: needs ping-pong textures, rational pole guards, or CPU precomputed paths;
- **hard**: needs volumetric/ray-marched geometry or paper-specific numeric details not retrieved here.

## Evidence gaps

- Semantic Scholar returned rate-limit responses for several focused queries; one hypercomplex Semantic Scholar output is empty and recorded in provenance.
- Some candidate formulas, especially root-finding parameter families, need the exact paper formula before implementation. Do not infer these from titles alone.
- Self-replicating reaction-diffusion spots may already be represented as a Gray-Scott preset; admit only if the kinetics differ from current app entries.

## Implications for Flutter Fractal Forge

Start with CA entries: Rule 90/150, cyclic CA, and Greenberg-Hastings. They are shader-friendly, visually distinct, and low-risk. Then add Klausmeier and Lattès. Treat substitution tilings as a small researched batch with identity tests to prevent duplicate catalog bloat.
