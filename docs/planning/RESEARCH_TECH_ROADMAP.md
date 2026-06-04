# Research & Technology Roadmap

**Date:** 2026-06-03  
**Status:** Recommended planning artifact  
**Scope:** Frameworks, rendering technology, research pipeline, and fractal-family priorities for improving Flutter Fractal Forge.

## Evidence Snapshot

This roadmap is grounded in the current repository state rather than a generic framework comparison.

| Evidence | Result |
|---|---|
| `PYTHONDONTWRITEBYTECODE=1 python3 scripts/research/forge.py doctor --strict-app-catalog` | `forge doctor: OK (1588 entries, 0 error(s), 0 warning(s))` |
| Shader files | 469 `.frag` files under `shaders/` |
| Registry tiers | 357 `implemented`, 1231 `reference` entries |
| Existing app direction | GPU-primary Flutter renderer with CPU precision safety net |
| Existing specs | 10K catalog design, research-pipeline spec, deep-zoom precision-ladder spec |
| Existing dirty worktree during this research pass | Precision Ladder code slice; this roadmap does not change production code |

## Recommendation Summary

1. **Keep Flutter as the app framework.** Do not switch frameworks now.
2. **Invest in the existing research pipeline.** The fastest safe path to “more fractals” is admission automation, not hand-adding random shaders.
3. **Prioritize quality gates over raw catalog count.** Every app-visible fractal needs shader validation, thumbnail proof, metadata, and catalog audit coverage.
4. **Continue the Precision Ladder.** Deep zoom should evolve through preview/refine separation, not scattered renderer toggles.
5. **Add visually distinct families next.** Prefer Newton/root-finding, reaction-diffusion, fractal flames/IFS, 3D raymarched, and number-theory families.

## Framework Direction

### Now: Stay on Flutter + FragmentShader

Flutter remains the right app framework for the current product:

- It already has working navigation, catalog, localization, export, accessibility, and tests.
- The renderer is already organized around Flutter shader assets.
- The app’s core risk is not framework capability; it is catalog quality, shader correctness, and deep-zoom honesty.

**Decision:** keep Flutter as the product shell and keep GPU fragment shaders as the default renderer path.

### Later: Investigate Flutter GPU / runtime shader loading

Runtime shader compilation and `flutter_gpu_shaders`-style approaches are useful later, but not a near-term dependency.

Promote this only when one of these becomes true:

- implemented app catalog exceeds roughly 1000 shaders and bundle size becomes painful;
- Flutter stable exposes a sufficiently safe runtime shader-loading path across target platforms;
- user-defined formula workflows are explicitly prioritized.

### Avoid Now: Full rewrite to native, wgpu, Unity, or web-first

A rewrite would slow the project more than it helps right now.

| Candidate | Why not now |
|---|---|
| Native Android/Vulkan | High rewrite cost; loses existing Flutter UI, tests, and product surface |
| Rust/wgpu app shell | Interesting compute architecture, but not a direct replacement for existing Flutter product |
| Unity/Unreal | Poor fit for shader catalog governance and app-style UI/accessibility |
| Web-first rewrite | Useful for a public catalog site later, not for the Android app’s current quality gaps |

## Rendering Technology Priorities

### P0/P1: Continue Precision Ladder into preview/refine

Current direction is correct: one decision module should describe whether the viewer is in realtime GPU, extended GPU preview, or CPU precision.

Next technical slices:

1. canonical deep-zoom viewport;
2. preview/refine scheduler after gesture idle;
3. cancellable CPU precision refine;
4. honest exactness labels in HUD/status text;
5. tests for tier transitions, cancellation, and semantics.

### P1: Dynamic resolution during gestures

The PRD and performance docs already call for lower-cost interaction frames. Implement this before exotic compute backends.

Expected benefit:

- smoother pinch/pan on mid-range Android;
- less thermal pressure;
- cleaner separation between preview and refine.

### P1: Shader warm-up service

Pre-warm common shaders after first frame, not during startup blocking work.

Suggested policy:

- warm the last-used shader;
- warm the top 5–10 popular shaders;
- keep telemetry local in `SharedPreferences` only.

### P1/P2: Supersampled and tiled export

For still-image quality, export can be slower than interactive rendering.

Recommended direction:

- tile large exports to avoid GPU memory spikes;
- support 2x/4x supersampling where device memory allows;
- validate output framing against viewer state.

### P2: Series approximation and period detection

For Mandelbrot-family deep zoom, use CPU reference orbit plus GPU perturbation improvements:

- period detection for reference orbits;
- series approximation to skip early iterations;
- explicit capability metadata per recurrence family.

This belongs after the precision-ladder decision and preview/refine seams are stable.

## Fractal Family Priorities

### 1. Newton / root-finding

Why first:

- registry already contains many reference-tier Newton-family entries;
- shader structure is reusable across methods;
- visuals differ strongly from Mandelbrot-family escape-time sets;
- root labels and basin coloring are testable.

Good targets:

- Chebyshev method;
- Müller method;
- Durand-Kerner;
- Ehrlich-Aberth;
- Mitchell Newton variants;
- Polynomiography variants.

Suggested first slice:

- promote one reference-tier Newton entry to implemented tier with a real shader, thumbnail, module wiring, and focused tests.

### 2. Reaction-diffusion and chemical patterns

Why next:

- underrepresented relative to the 10K taxonomy;
- visually distinct from existing escape-time inventory;
- good for animated or parameter-exploration experiences later.

Good targets:

- Gray-Scott;
- Turing patterns;
- cyclic cellular reaction systems;
- Belousov-Zhabotinsky-inspired waves.

Implementation caution:

- many reaction-diffusion systems are naturally multi-pass or stateful;
- if Flutter fragment shaders cannot keep state directly, start with static/procedural approximations or CPU-generated thumbnails before adding live simulation.

### 3. Fractal flames and richer IFS

Why:

- high visual payoff;
- good for presets and thumbnails;
- bridges reference catalog and art-app appeal.

Good targets:

- Apophysis-style flame variations;
- Apollonian gasket variants;
- Barnsley fern variants;
- Pythagorean trees;
- parameterized affine IFS families.

Implementation caution:

- stochastic accumulation is not a simple one-pass fragment shader problem;
- app-visible entries should either have deterministic shader approximations or an explicit CPU/progressive-render path.

### 4. 3D raymarched / hypercomplex

Why:

- showcase value;
- strong screenshots and store assets;
- current shader tree already has 3D/hypercomplex categories.

Good targets:

- Kleinian groups;
- quaternion Julia variants;
- Mandelbox variants;
- KIFS folds;
- Menger and Sierpinski raymarched structures.

Implementation caution:

- frame-time risk is high;
- require performance budgets and fallback copy before adding many app-visible 3D entries.

### 5. Number-theory fractals

Why:

- differentiates the catalog from ordinary fractal apps;
- supports “fractal encyclopedia” positioning;
- often works well as static/procedural shader visuals.

Good targets:

- Gaussian integer basins;
- Ford circles / modular group visuals;
- prime spirals;
- continued-fraction fractals;
- Eisenstein-series-inspired visuals.

## Research Source Priorities

Use the existing pipeline hierarchy instead of ad hoc additions.

### First: Existing reference backlog

The registry already has 1231 reference-tier entries. Promote from this backlog before crawling new sources.

Benefits:

- no new discovery infrastructure;
- dedup already partly solved;
- app-catalog doctor already understands the registry.

### Second: Structured sources

Best next external sources once the backlog pipeline is flowing:

1. Ultra Fractal formula database;
2. Shadertoy fractal-tag scan;
3. Wikipedia and MathWorld;
4. Paul Bourke fractal pages;
5. GitHub repos with permissive licenses and clear shader provenance.

### Third: Unstructured sources

Use only after deterministic sources are productive:

- arXiv;
- Fractal Forums archives;
- Bridges Math Art archive;
- Mu-Ency;
- CNKI / Chinese sources for discovery and aliases only.

## Admission Gates for New App Fractals

A fractal should become app-visible only when these checks pass.

### Required metadata

- stable id;
- canonical English name;
- category from the 19-category taxonomy;
- formula or construction description;
- citation/provenance;
- license status;
- default params;
- thumbnail params;
- shader path or renderer path;
- exactness/deep-zoom capability flag where applicable.

### Required validation

- `PYTHONDONTWRITEBYTECODE=1 python3 scripts/research/forge.py doctor --strict-app-catalog`;
- Dart analyzer for touched module/catalog code;
- shader asset declared in `pubspec.yaml`;
- thumbnail exists and is non-placeholder for implemented tier;
- pixel sanity check: non-black ratio and frame progression where applicable;
- widget/catalog smoke test for app visibility;
- semantics label if the fractal adds a new visible status/control.

### Required honesty

Do not mark a fractal as app-implemented if it only has:

- a placeholder thumbnail;
- copied source without license clearance;
- metadata but no render path;
- a proxy shader that does not match the formula;
- deep-zoom claims without a tested precision path.

## Concrete Next Slices

### Slice A: Promote one Newton reference to implemented

Deliverables:

- one real GLSL shader;
- one Dart module wired into the registry;
- real thumbnail;
- focused tests;
- strict app-catalog doctor green.

Recommended target: a simple Chebyshev or Householder variant before more exotic Mitchell entries.

### Slice B: Add dynamic gesture resolution

Deliverables:

- preview scale lowered during active gestures;
- full resolution restored after idle;
- no change to final framing;
- renderer/widget tests for active vs settled state.

### Slice C: Add shader warm-up service

Deliverables:

- non-blocking warm-up after first frame;
- local popularity list;
- tests around no duplicate loads and failure policy.

### Slice D: Build a promotion report for reference backlog

Deliverables:

- ranked list of easiest 25 reference entries to promote;
- required shader family/template for each;
- blocked reason for entries needing multi-pass/stateful rendering.

## Adjacent Hygiene

Tracked Python bytecode files were observed in the repository. They are not part of this roadmap slice, but they should be cleaned in a separate hygiene commit so research validation can continue using `PYTHONDONTWRITEBYTECODE=1` without cache churn.

## Decision Record

- **Chosen now:** Flutter + existing shader pipeline + research admission gates.
- **Chosen next:** promote from existing reference backlog and continue precision/rendering quality improvements.
- **Deferred:** runtime shader compilation, user formula uploads, public web dashboard, community marketplace.
- **Avoided:** framework rewrite before catalog/rendering quality gaps are solved.
