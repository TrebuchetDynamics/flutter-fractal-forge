# World-Largest Fractal Catalog Plan

## Objective

Target **5,000–10,000 curated renderable entries**, counting formulas/rules rather than random presets.

## Current evidence

- Research report: `research/worlds-largest-fractal-catalog/report.md`
- Machine-readable targets: `research/worlds-largest-fractal-catalog/catalog-targets.json`
- Entry schema: `research/worlds-largest-fractal-catalog/curated-entry-schema.json`
- Seed ingest ledger: `research/worlds-largest-fractal-catalog/curated-entry-ledger.seed.json`
- Wave 0 promoted ledger: `research/worlds-largest-fractal-catalog/curated-entry-ledger.wave0.json` with 5 counted app-renderable formula/rule entries.
- Existing app discovery ledger: `research/worlds-largest-fractal-catalog/curated-entry-ledger.existing-app.json` with 848 metadata+thumbnail source leads and 0 counted promoted entries.
- Existing app gap report: `research/worlds-largest-fractal-catalog/existing-app-ledger-gap-summary.md`
- Existing app shader-linkage audit: `research/worlds-largest-fractal-catalog/existing-app-shader-linkage-audit.md` / `.json`, currently 355 shared-shader candidates and 493 still-unmapped leads.
- Shared renderer promotion plan: `research/worlds-largest-fractal-catalog/shared-renderer-promotion-plan.md` / `.json`, grouping 355 non-counted implementation candidates into 19 shader batches; detailed first-batch worklists currently cover Julia, Sprott, and Phoenix.
- Julia shared mapping worklist: `research/worlds-largest-fractal-catalog/julia-shared-mapping-worklist.md` / `.json`, extracting parseable Julia `c` constants for 50 of 56 Julia-style candidates.
- Sprott shared mapping worklist: `research/worlds-largest-fractal-catalog/sprott-shared-mapping-worklist.md` / `.json`, identifying exact live shader counterparts for 15 of 34 Sprott-style candidates.
- Phoenix shared mapping worklist: `research/worlds-largest-fractal-catalog/phoenix-shared-mapping-worklist.md` / `.json`, parsing degree overrides for all 3 Phoenix-style candidates.
- Elementary CA shared mapping worklist: `research/worlds-largest-fractal-catalog/elementary-ca-shared-mapping-worklist.md` / `.json`, parsing Wolfram rule numbers for all 99 elementary CA candidates.
- Mandelbrot shared mapping worklist: `research/worlds-largest-fractal-catalog/mandelbrot-shared-mapping-worklist.md` / `.json`, extracting 19 ready period/view-region mappings from 44 Mandelbrot-family candidates.
- Orbit-trap shared mapping worklist: `research/worlds-largest-fractal-catalog/orbit-trap-shared-mapping-worklist.md` / `.json`, parsing 25 stable trap-geometry identities.
- Multibrot shared mapping worklist: `research/worlds-largest-fractal-catalog/multibrot-shared-mapping-worklist.md` / `.json`, parsing 18 exponent/power identities from 20 Multibrot candidates.
- 3D shared mapping worklist: `research/worlds-largest-fractal-catalog/3d-shared-mapping-worklist.md` / `.json`, parsing 27 Mandelbox/Mandelbulb/Quaternion/KIFS parameter mappings.
- Escape-variant shared mapping worklist: `research/worlds-largest-fractal-catalog/escape-variant-shared-mapping-worklist.md` / `.json`, parsing 37 ready tricorn/burning-ship/sine/cosine mappings from 39 candidates.
- Residual CA shared mapping worklist: `research/worlds-largest-fractal-catalog/residual-ca-shared-mapping-worklist.md` / `.json`, parsing 8 residual CA/stochastic rule mappings.
- Shared-renderer duplicate-risk audit: `research/worlds-largest-fractal-catalog/shared-renderer-duplicate-risk-audit.md` / `.json`, marking 220 detailed-worklist candidates as duplicate-risk and 135 as non-duplicate implementation candidates after promoting all 50 reviewed Julia candidates, 3 Phoenix degree candidates, 1 exact Sprott C candidate, 18 reviewed 3D parameter identities, 7 residual CA rule identities, 99 Elementary CA rule identities, and 18 Multibrot exponent identities.
- Shared-renderer ready backlog: `research/worlds-largest-fractal-catalog/shared-renderer-ready-backlog.md` / `.json`, narrowing to 85 non-duplicate mapping-ready implementation candidates.
- Shared-renderer ready backlog validator: `research/worlds-largest-fractal-catalog/validate_shared_renderer_ready_backlog.py`, proving candidates remain uncounted and gated before promotion.
- Shared-renderer implementation batches: `research/worlds-largest-fractal-catalog/shared-renderer-implementation-batches.md` / `.json`, splitting 85 ready candidates into 4 non-counting implementation batches.
- Shared-renderer implementation batch validator: `research/worlds-largest-fractal-catalog/validate_shared_renderer_implementation_batches.py`.
- Shared-renderer semantic-support audit: `research/worlds-largest-fractal-catalog/shared-renderer-semantic-support-audit.md` / `.json`, distinguishing candidates whose shared renderer already exposes formula/rule identity parameters.
- Semantic-supported implementation batches: `research/worlds-largest-fractal-catalog/semantic-supported-implementation-batches.md` / `.json`, now showing 0 immediate candidates after promoting all reviewed Julia, Phoenix, exact-Sprott, semantically supported 3D, residual CA, Elementary CA, and Multibrot mappings; 85 require shader/mapper extension first.
- Live registry gap report: `research/worlds-largest-fractal-catalog/live-registry-gap-summary.md`
- Live registry promoted ledger: `research/worlds-largest-fractal-catalog/curated-entry-ledger.live-registry.json` (generated research artifact). The live app has 977 production modules; the debug/test `ModuleRegistry` has 984 modules including 7 diagnostics.
- Live thumbnail worklist: `research/worlds-largest-fractal-catalog/thumbnail-worklist.live-registry.json` with 30 missing thumbnails split into 2 batches; these are known strict-quality rejects needing framing/render fixes.
- Live category-family mapping now covers all thumbnail-backed live modules; no thumbnail-backed modules remain blocked by unknown-family classification.
- Live thumbnail batch runner: `research/worlds-largest-fractal-catalog/run_thumbnail_batch.py` dry-runs by default and requires `--execute --update-assets` to write bundled assets.
- Live registry ledger generator: `research/worlds-largest-fractal-catalog/tool/generate_live_registry_ledger.dart`
- Completion audit script: `research/worlds-largest-fractal-catalog/audit_catalog_goal.py`
- Latest completion audit: `research/worlds-largest-fractal-catalog/completion-audit.live-registry.json`
- Live registry guardrail test: `test/features/catalog/world_largest_catalog_goal_test.dart`
- Live registry ledger generation test: `test/features/catalog/generate_live_registry_ledger_test.dart`
- Validator: `research/worlds-largest-fractal-catalog/validate_catalog_goal.py`
- Existing reference seed: `research/fractals-library/data/fractal_manifest.json` with 200 formula/rule definitions.
- Current thumbnail PNG count observed: 1347 under `assets/catalog_thumbs/`; this is not a formula/rule count by itself.

## Counting contract

Count one catalog entry only when it has a stable renderable mathematical identity:

- formula, grammar, transform system, map, rule, simulation model, or named stable variant
- stable catalog ID
- family classification
- renderer path
- provenance and license context
- thumbnail plan and validation signal

Do **not** count these as new entries:

- random parameter seeds
- camera-only presets
- palette-only presets
- thumbnail-only variants
- renderer implementation details
- unproven copied upstream source

Presets can exist, but they do not inflate the world-largest count unless they encode a named, stable formula/rule variant.

## Target ledger

`catalog-targets.json` currently allocates **5,150–8,850 counted entries**, inside the 5k–10k objective range.

| Family | Target range | Renderer path | Count rule |
|---|---:|---|---|
| Escape-time polynomial/complex | 1,200–1,800 | fragment shader | formula + exponent/view type |
| Root-finding/polynomiography | 300–500 | fragment shader | method + polynomial family |
| Rational/transcendental maps | 600–1,000 | fragment shader | formula identity |
| 3D distance-estimated/raymarch | 200–350 | raymarch shader | distance estimator/fold system |
| IFS/geometric | 400–700 | point/mesh/accumulation | transform system/rule set |
| L-systems/plants/curves | 200–350 | grammar + turtle/mesh | axiom/rule grammar |
| Strange attractors/maps | 500–900 | point accumulation | ODE/map equation |
| Cellular automata | 500–900 | grid simulation | rule number/rule family |
| Reaction-diffusion | 100–200 | grid simulation | model + stable parameter class |
| Noise/terrain/textures | 200–350 | shader/heightfield | noise basis + fractal composition |
| Tilings/substitution/graphs | 200–350 | mesh/recursive geometry | substitution or graph rule |
| Number-theory/special functions | 250–450 | shader/grid | sequence/function identity |
| Fractal flames/variation systems | 500–1,000 | iterated transform accumulation | stable variation recipe, not random genome |

Non-counted mode target:

- Orbit traps/coloring modes: 50–200 modes. These are catalog capabilities, not formula/rule entries unless geometry changes.

## Ingest pipeline

1. **Source lead** — paper, book, reference corpus item, or generated formula family lead.
2. **Provenance record** — source, DOI/URL/path, license context, reuse decision, and validation target.
3. **Formula/rule schema** — mathematical identity and parameter bounds.
4. **Renderer assignment** — shader, raymarch, point accumulation, grid simulation, turtle/mesh, or CPU precision path.
5. **Catalog identity** — stable ID, family, display name, aliases, accessibility label.
6. **Thumbnail plan** — Launch Thumbnail Standard for bundled assets when promoted.
7. **Validation** — compile/render smoke, visual metrics, family-specific invariant, and catalog lookup test.
8. **Promotion** — count as curated renderable entry only after validation passes.

## First implementation wave

Use the existing 200-entry `research/fractals-library` seed as Wave 0. Next practical waves:

1. **Escape-time expansion**: powers, signs/folds, Julia/parameter-plane pairs, rational/transcendental variants.
2. **CA expansion**: elementary rule families and named Life-like rules; high count, clear rule identity.
3. **Attractor/map expansion**: ODE/map formulas with point-accumulation renderer.
4. **IFS/L-system expansion**: classic named grammars and transform systems.
5. **Noise/flame expansion**: only after provenance naming is stable; avoid random-genome count inflation.

## Completion gates for the 5k–10k claim

Before claiming the catalog target is achieved, audit:

- counted entry total between 5,000 and 10,000
- every counted item has formula/rule identity, not only preset data
- no random seeds counted as entries
- every counted item has provenance and license context
- every counted item maps to a renderer path
- every counted item has a thumbnail or tracked thumbnail plan
- family totals match `catalog-targets.json` or a superseding reviewed target ledger
- public copy says “renderable entries / families / formulas / presets” distinctly

## Validation commands

```sh
python3 research/worlds-largest-fractal-catalog/validate_catalog_goal.py
python3 research/worlds-largest-fractal-catalog/validate_catalog_goal.py --entries research/worlds-largest-fractal-catalog/curated-entry-ledger.wave0.json
python3 research/worlds-largest-fractal-catalog/validate_catalog_goal.py --entries research/worlds-largest-fractal-catalog/curated-entry-ledger.wave0.json --require-objective-complete
python3 research/worlds-largest-fractal-catalog/audit_catalog_goal.py
python3 research/worlds-largest-fractal-catalog/validate_shared_renderer_ready_backlog.py
python3 research/worlds-largest-fractal-catalog/validate_shared_renderer_implementation_batches.py
python3 research/worlds-largest-fractal-catalog/audit_shared_renderer_semantic_support.py
```

The first command validates target math and seed-ledger count safety. The second validates the 5-entry promoted Wave 0 ledger. The live-registry promoted ledger is a generated research artifact; its runtime thumbnail-plan strings are not accepted by the older thumbnail-path validator. The existing app discovery ledger also validates but currently contributes 0 counted entries because remaining leads require reviewed shared-renderer promotion or shader assets. The live registry guardrail test confirms current production modules are shader-backed but still below 5,000. The objective-complete validator and completion-audit commands are expected to fail until 5,000–10,000 promoted entries exist.

## Current status

Not achieved. The repo now has research, a target ledger, schema, validator, completion audit, source-lead ledgers, and a refreshed live-registry promoted ledger. The live app has 977 production fractals; the debug/test `ModuleRegistry` has 984 modules including 7 diagnostic shaders. The current ledger reports 0 missing thumbnails and 0 unknown-family skips. Existing backlog and shared-renderer planning artifacts remain useful for growth toward the 5,000+ target, but public copy should distinguish the current 977 production fractals from the larger future 5,000–10,000 curated-entry objective.
