# Fractal Research Pipeline — State of Play

**Last updated:** 2026-04-12
**Branch:** `main`
**Working tree:** clean modulo a handful of lingering edits in `lib/core/modules/builders/` catalog files

## 1. Executive Summary

The fractal catalog now contains **370 entries** in `docs/catalog/fractal_registry.yaml`, of which **357 are fully renderable in the app today** (shader + Dart builder + ~209 real thumbnail PNGs) and **13 are pipeline-emitted reference-tier Newton/Root-Finding variants** (f0001–f0013) that have emitted Dart modules and scaffolds but are not yet wired into `ModuleRegistry`. The research pipeline (Python) has completed **Stages A and B** (foundation, schemas, retrofit, doctor, canonical aliases, formula hashing, dedup, taxonomy classifier, Dart emitter, admission orchestrator, E2E test) with **110 Python tests passing**. Stages C (structured discovery), D (unstructured discovery), and E (maintenance dashboard) have detailed implementation plans written but have not been executed — they require external infrastructure (Anthropic API key, GROBID Docker, Shadertoy/GitHub tokens). Four Maestro flows exercise launch, navigation, viewer, and export; over 20 Flutter integration tests cover critical journeys, thumbnails, shader pipeline diagnostics, and catalog ID integrity. This document captures the full state of the work and lays out the prioritized next steps for bringing the 10K-fractal vision home.

---

## 2. Catalog Inventory

### 2.1 Tier breakdown

| Tier | Count | Notes |
|------|-------|-------|
| `implemented` | 357 | Real Dart builders + real GLSL shaders + mostly real thumbnails |
| `reference` | 13 | Pipeline-emitted Dart scaffolds, placeholder thumbnails, no GLSL shader yet |
| **Total** | **370** | |

### 2.2 Category breakdown

| Category | Count |
|----------|-------|
| Escape-Time | 341 |
| Newton / Root-Finding | 13 |
| 3D Fractals | 9 |
| Convergent & Root-Finding | 3 |
| Advanced Rational & Polynomial | 2 |
| IFS / Geometric Fractals | 1 |
| Cellular & Stochastic Growth | 1 |

(Category taxonomy as of Stage A retrofit — the spec §13 defines 19 canonical categories which the pipeline emits into, but the legacy registry still uses the original ad-hoc categories. Harmonization is a follow-up task.)

### 2.3 Source

| Source | Count |
|--------|-------|
| Hand-authored Dart builders (`lib/core/modules/builders/escape_time_catalog.dart`, `raymarched_3d_catalog.dart`) | 357 |
| Pipeline-emitted (`python3 scripts/research/forge.py admit …`) into `lib/core/modules/newton_root_finding/` | 13 |

### 2.4 Renderability

| Check | Count |
|-------|-------|
| Has a working shader in-app today | 357 |
| Has `hasThumbnail: true` in registry | 209 |
| Has an actual PNG in `assets/catalog_thumbs/` | 212 |
| Appears in the app's catalog UI (`ModuleRegistry`) | 357 |
| `tier: reference` (not yet wired, invisible to UI) | 13 |

### 2.5 The 13 pipeline-emitted entries

| id | Name | Category | Source paper / citation |
|----|------|----------|------------------------|
| `f0001_mitchell_adjusted_newton` | Mitchell Adjusted Newton | Newton / Root-Finding | Mitchell, Bridges 2019 |
| `f0002_mitchell_rotating_c_newton` | Mitchell Rotating-C Newton | Newton / Root-Finding | Mitchell, Bridges 2019 |
| `f0003_mitchell_alternating_equations_newton` | Mitchell Alternating-Equations Newton | Newton / Root-Finding | Mitchell, Bridges 2019 |
| `f0004_mitchell_real_systems_newton` | Mitchell Real-Systems Newton | Newton / Root-Finding | Mitchell, Bridges 2019 |
| `f0005_mitchell_matrix_newton_sand_storm` | Mitchell Matrix Newton (Sand Storm) | Newton / Root-Finding | Mitchell, Bridges 2019 |
| `f0006_halley_s_method` | Halley | Newton / Root-Finding | Traub 1964; classical |
| `f0007_schr_der_s_method` | Schröder | Newton / Root-Finding | Schröder 1870; classical |
| `f0008_chebyshev_s_method` | Chebyshev | Newton / Root-Finding | classical |
| `f0009_householder_s_method_3rd_order` | Householder H3 | Newton / Root-Finding | Householder 1970 |
| `f0010_secant_method` | Secant | Newton / Root-Finding | classical |
| `f0011_m_ller_s_method` | Müller | Newton / Root-Finding | Müller 1956 |
| `f0012_nova_fractal` | Nova (Jones) | Newton / Root-Finding | Jones 1990s |
| `f0013_polynomiography_basic_family_iteration` | Polynomiography (Kalantari) | Newton / Root-Finding | Kalantari 2005 |

All 13 currently have `tier: reference` (no shader → not rendered).

---

## 3. What Works Today

- **357 legacy fractals render end-to-end** via the app’s GPU pipeline (SwiftShader on emulator, real GPU on device).
- **212 real thumbnail PNGs** checked into `assets/catalog_thumbs/` (209 flagged `hasThumbnail: true` in registry — the delta is a minor audit cleanup).
- **`forge doctor` is green:** `python3 scripts/research/forge.py doctor` reports 370 entries, 0 errors, after retrofit + seed-aliases.
- **`flutter analyze lib/core/modules/` is green** including the pipeline-emitted Newton modules.
- **Python pipeline: 110 tests pass** across 15 test files under `tests/research/`.
- **Flutter integration tests: 20 files in `integration_test/`** cover critical journeys, thumbnails, navigation, gestures, shader diagnostics, etc.
- **Flutter unit tests: 100+ files under `test/`** covering services, widgets, catalog repo/search, shader compatibility, accessibility, backend policy, etc.
- **4 Maestro flows** (`.maestro/01..04`) covering launch, navigation, viewer, export; `run_all.sh` handles ANR dismissal, driver reinstall, SwiftShader cold-start timing.

---

## 4. Known Gaps

Be blunt about what is NOT done:

1. **The 13 pipeline-emitted entries are NOT wired into `ModuleRegistry`.** They exist as Dart files under `lib/core/modules/newton_root_finding/f000X_*/` with a module class, tests, and a placeholder thumbnail, but no code path registers them with the app. They will not appear in the catalog UI until a wiring pass is done.
2. **Pipeline-emitted entries have placeholder gradient thumbnails**, not real shader renders. Real thumbnails require a shader + a Flutter headless rendering pass.
3. **Pipeline-emitted entries lack GLSL shader files.** `tier: reference` is semantically correct ("we have the math, we have a Dart module, but we haven’t shaded it yet") but it means no visual in the app.
4. **No automated test iterates all 370 entries and verifies each opens.** That’s exactly what the companion deliverables in this commit (the Maestro sampling flow and programmatic integration test) begin to address, but a true exhaustive per-fractal smoke remains an item on the TODO.
5. **Category taxonomy is not yet harmonized** between the legacy ad-hoc categories (e.g. "Escape-Time", "3D Fractals") and the spec §13 19-category canonical taxonomy the pipeline emits into.
6. **Pre-existing `lib/core/modules/builders/escape_time_catalog.dart` + `raymarched_3d_catalog.dart` have lingering working-tree edits** (from a prior session) that should be committed or reverted.
7. **`__pycache__/` at repo root** is lingering in git status despite the research-pipeline `.gitignore` rules — root-level Python cache is not covered.

---

## 5. Pipeline Architecture (recap)

```
 ┌─────────────┐    ┌────────────┐    ┌───────────────┐    ┌────────────┐    ┌──────────────┐    ┌──────────────┐
 │  Discovery  │──▶ │ Extraction │──▶ │Canonicalization│──▶ │ Admission  │──▶ │  Registry    │──▶ │ Dart emission│
 │ (Stage C/D) │    │ (GROBID,   │    │ (aliases,     │    │ (dedup,    │    │ (YAML single │    │ (§14 per-    │
 │ + manual    │    │  LLM, etc.)│    │  formula_hash,│    │  review,   │    │  source of   │    │  fractal Dart│
 │ seed files  │    │            │    │  taxonomy)    │    │  promote)  │    │  truth)      │    │  files)      │
 └─────────────┘    └────────────┘    └───────────────┘    └────────────┘    └──────────────┘    └──────────────┘
                                                                                     │
                                                                                     ▼
                                                                          ┌─────────────────────┐
                                                                          │  forge doctor       │
                                                                          │  (invariant check)  │
                                                                          └─────────────────────┘
```

### 5.1 Stage responsibilities

- **Stage A (Foundation)** — schemas (JSON Schema for `candidate`, `registry_entry`, `metadata`), registry round-trip loader, retrofit migration (tier/formula_hash/quality), `forge doctor` invariant checker, canonical alias seed. **DONE.**
- **Stage B (Dedup + Admission + Dart)** — sympy-based formula AST normalizer + SHA-256 hash, 3-stage dedup pipeline (hash → fuzzy via rapidfuzz → family via taxonomy), taxonomy classifier mapping iteration-type into 19 canonical categories, Dart emitter with 6 Jinja templates (one per iteration type) compiling to per-fractal Dart modules, `build_batch`/`review_batch` CLI flows, `promote_candidate` orchestrator, end-to-end Stage B pipeline test. **DONE.**
- **Stage C (Structured Discovery)** — harvesters for Ultra Fractal DB, Shadertoy, Wikipedia, MathWorld, Paul Bourke. Plan written, not executed; blocked on API keys.
- **Stage D (Unstructured Discovery)** — LLM-assisted extraction from arXiv, GitHub, Fractal Forums, Bridges Math Art archive, CNKI (Chinese). Plan written; blocked on Anthropic key + GROBID Docker.
- **Stage E (Maintenance & Dashboard)** — link-health, dedup-rescan, taxonomy-audit, shader-regression, citation-refresh cron jobs; static HTML dashboard at `reports/dashboard.html`. Plan written, not executed.

### 5.2 Data flow invariants enforced by `forge doctor`

1. Every entry has a unique `id`.
2. Every entry has a valid `formula_hash` (`sha256:` prefix, 64 hex chars).
3. `tier` is one of `{implemented, reference, aspirational}`.
4. Category is one of the 19 canonical values (or legacy, gated during migration).
5. No two entries share the same `formula_hash` unless explicitly marked as an intentional duplicate (family variant).
6. Every `implemented`-tier entry must declare a shader path.
7. Every `citation.doi` must resolve (checked lazily by Stage E cron).

**Full spec:** `docs/superpowers/specs/2026-04-12-fractal-research-pipeline-design.md` (includes §14 Dart emission contract, §13 canonical taxonomy).
**Parking lot for deferred ideas:** `docs/superpowers/specs/FUTURE-PLAN.md`.

---

## 6. Recent Commits (chronological, this session)

| sha | Summary |
|-----|---------|
| `982fd25` | Add superpowers brainstorm session artifacts |
| `33ea170` | docs: add 10K fractal catalog design spec |
| `9644f3a` | docs: add Phase 0 implementation plan for 10K fractal catalog |
| `b5f2b4c` | chore: add `.worktrees` to `.gitignore` |
| `224eb03` | Add fractal catalog audit scripts and generate registry YAML |
| `aaeae55` | docs: add fractal research pipeline spec + FUTURE-PLAN parking lot |
| `3bfe419` | docs: add Stage A implementation plan (pipeline foundation) |
| `c1a31f9` | feat(research): scaffold Python tooling package structure |
| `3f4e018` | feat(research): add forge CLI skeleton with subcommand dispatch |
| `1f3e381` | feat(research): add common JSON sub-schemas (formula_ast, params, citation, quality_block) |
| `ccffda9` | feat(research): add registry_entry JSON schema + cross-ref test harness |
| `56801c6` | test(research): fix legacy-fields test + pin additionalProperties behavior |
| `b18eedc` | feat(research): add candidate JSON schema |
| `51b9f75` | feat(research): add metadata JSON schema |
| `658e219` | feat(research): add round-trip Registry loader with ruamel.yaml |
| `14d49ae` | feat(research): add schema_lint helper with cross-schema `$ref` resolution |
| `01d9805` | docs(spec): add Dart emission contract (§14) |
| `5d9c06b` | feat(research): add `formula_hash` module (Stage A legacy hashing) |
| `8398e1a` | feat(research): add `retrofit_registry` migration |
| `120b058` | fix(catalog): populate 7 entries with missing names |
| `6ccc672` | feat(research): add `forge doctor` invariant checker |
| `1617a91` | test(research): doctor passes on real registry after retrofit |
| `feafdbe` | chore(catalog): retrofit registry — add tier, formula_hash, quality to 357 entries |
| `bf55ee1` | safety(audit): refuse to overwrite retrofitted registry without `--force-overwrite` |
| `fa15d9a` | feat(research): seed `canonical_aliases.yaml` from registry + manual seed file |
| `da29b9e` | chore: gitignore fractal research working dirs, keep canonical and seeds |
| `8e15197` | ci: add research tooling CI (pytest + forge doctor) |
| `f5ba856` | docs: add Stage B/C/D/E implementation plans |
| `ad6d8ef` | chore(research): add Stage B deps (rapidfuzz, jinja2, sympy, Pillow) |
| `3d9c00b` | feat(research): `formula_ast` normalizer + SHA-256 hasher (sympy-based) |
| `f13b094` | feat(research): taxonomy classifier (iteration_type → 19 categories + family detection) |
| `556b026` | feat(research): dedup pipeline (hash → fuzzy → family, 3 stages) |
| `357051f` | feat(research): Dart emitter with 6 iteration-type templates (§14) |
| `8fb784e` | feat(modules): add base classes for pipeline-emitted modules (§14) |
| `d4434ab` | feat(research): `build_batch` + `review_batch` (Stage B Tasks 5+6) |
| `6b1a3a0` | chore: remove `__pycache__` files committed in previous commit |
| `1e7efa4` | feat(research): thumbnail stub + `promote_candidate` orchestrator (Stage B Tasks 9+10) |
| `9ab5afd` | ci(research): add `dart-emit-check` job (flutter analyze on emitted fixtures) |
| `af7c7ce` | fix(research/emit): emitted Dart passes `flutter analyze` |
| `2dbd9ca` | test(stage-b): end-to-end admission pipeline test |
| `8f8f3c5` | docs: add Bridges Math Art archive as Stage D discovery source |
| `c0014a9` | feat(catalog): admit 5 Newton variants from Mitchell Bridges 2019 paper |
| `2be3a88` | feat(catalog): admit 8 classic Newton-family fractals |

---

## 7. Test Inventory

### 7.1 Python (110 tests, 15 files) — `tests/research/`

| File | Purpose |
|------|---------|
| `test_schemas.py` | JSON Schema validation for registry_entry / candidate / metadata |
| `test_forge_cli.py` | CLI subcommand dispatch |
| `test_registry.py` | Round-trip YAML loader (ruamel) |
| `test_formula_normalizer.py` | sympy-based formula normalization + SHA-256 hashing |
| `test_retrofit.py` | Registry migration (adds tier/formula_hash/quality) |
| `test_doctor.py` | Invariant checker |
| `test_seed_aliases.py` | canonical_aliases seed from registry + manual seed |
| `test_taxonomy_classifier.py` | iteration_type → 19 categories + family detection |
| `test_dedup.py` | 3-stage dedup (hash → fuzzy → family) |
| `test_emit_dart.py` | Dart emitter for 6 iteration types (§14) |
| `test_build_batch.py` | Stage B: build a candidate batch |
| `test_review_batch.py` | Stage B: review a candidate batch |
| `test_thumbnail_render.py` | Thumbnail placeholder stub |
| `test_promote_candidate.py` | Admission orchestrator (promote → registry + Dart) |
| `test_e2e_stage_b.py` | End-to-end Stage B: discovery → admission |

### 7.2 Flutter integration (20 files) — `integration_test/`

- `app_test.dart` — boot smoke
- `backend_screenshot_test.dart` — backend-path screenshot
- `catalog_thumbnail_smoke_test.dart` — thumbnails load from asset bundle
- `cpu_fallback_gestures_test.dart` — CPU fallback gesture correctness
- `critical_journey_test.dart` — full journey (catalog → viewer → export)
- `double_tap_anchor_test.dart` — double-tap zoom anchoring
- `emulator_gpu_policy_evidence_test.dart` — GPU policy on emulator
- `emulator_gpu_proof_test.dart` — GPU proof artifacts
- `full_screenshots_test.dart` — screenshot suite
- `generate_gpu_thumbnails_test.dart` — headless thumbnail generator
- `navigation_diagnostics_test.dart` — navigation instrumentation
- `perf_smoke_test.dart` — perf smoke
- `render_validation_test.dart` — render correctness
- `screenshots_test.dart` — standard screenshots
- `semantics_audit_test.dart` — a11y / semantics
- `shader_benchmark_test.dart` — shader perf
- `shader_pipeline_diagnostic_test.dart` — shader pipeline diagnostics
- `user_flows_test.dart` — sampled user flows
- `viewer_hold_test.dart` — viewer hold gesture
- `every_fractal_programmatic_test.dart` — **NEW** (this commit): iterates all `tier: implemented` entries, asserts metadata integrity

### 7.3 Flutter unit (100+ files) — `test/`

Broad coverage: accessibility service, animation controller, app logger, backend policy, batch export, catalog ID integrity, catalog repository, catalog search widget, catalog thumbnail audit, CPU formula coverage, CPU Mandelbrot visual gate, crash reporter, debug runner, deep-zoom precision ladder, etc. (100+ Dart test files in `test/` including subdirectories like `test/core/`, `test/a11y/`.)

### 7.4 Maestro (5 flows) — `.maestro/`

- `01_app_launch.yaml` — catalog loads, Mandelbrot visible
- `02_catalog_navigation.yaml` — search + scroll + tap (Julia, Mandelbrot)
- `03_viewer_controls.yaml` — viewer + controls button
- `04_export_flow.yaml` — open + export
- `05_every_fractal_smoke.yaml` — **NEW** (this commit): samples 20+ diverse fractals across categories
- `run_all.sh` — robust runner (ANR dismiss, driver install, SwiftShader cold-start)

---

## 8. What To Do Next (prioritized)

### P0 — Verify everything still works

1. `pytest tests/research -v --tb=short` — expect 110 passing.
2. `flutter test` — run all unit tests.
3. `flutter test integration_test/` — run all integration tests (including the new programmatic per-fractal check).
4. Build a debug APK: `flutter build apk --debug`.
5. Install and run `bash .maestro/run_all.sh` — expect 5 flows (including the new `05_every_fractal_smoke.yaml`) to pass.

### P1 — Close the Stage-B integration gap

1. **Wire the 13 pipeline-emitted Newton modules into `ModuleRegistry`** (`lib/core/modules/module_registry.dart`) so they surface in the catalog UI.
2. **Write real GLSL shaders** for the 13 Newton variants; promote each entry from `tier: reference` to `tier: implemented`.
3. **Render real thumbnails** via the existing Flutter headless render pipeline (`integration_test/generate_gpu_thumbnails_test.dart`) to replace the placeholder gradients.
4. **Harmonize categories**: migrate legacy registry entries into the 19 canonical categories from spec §13.

### P2 — Grow the catalog (Stages C + D)

- Provision `ANTHROPIC_API_KEY`.
- Stand up GROBID in Docker.
- Provision Shadertoy + GitHub tokens.
- **Stage C (structured discovery)** — target +7,600 candidates:
  - Ultra Fractal DB, Shadertoy, Wikipedia, MathWorld, Paul Bourke.
- **Stage D (unstructured discovery)** — target +3,000 candidates:
  - arXiv, GitHub, Fractal Forums, **Bridges Math Art archive**, CNKI.
- Budget: ~$20–$50 in LLM costs across full Stage D runs.

### P3 — Maintenance (Stage E)

- Cron: link-health, dedup-rescan, taxonomy-audit, shader-regression, citation-refresh.
- Static HTML dashboard at `reports/dashboard.html`.

### P4 — Quality & Polish

- Run `flutter analyze` on the entire `lib/` (not just `lib/core/modules/`) and fix pre-existing issues.
- Commit the lingering `lib/core/modules/builders/escape_time_catalog.dart` + `raymarched_3d_catalog.dart` working-tree edits.
- Add repo-root `__pycache__/` to `.gitignore`.
- Consolidate legacy ad-hoc category labels into the canonical 19-category taxonomy.

---

## 9. How to Test the App Right Now

```bash
# 1. Python pipeline
pytest tests/research -v --tb=short

# 2. Flutter unit + integration
flutter test
flutter test integration_test/

# 3. Build debug APK for Maestro (if not built)
flutter build apk --debug

# 4. Install on connected device/emulator
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# 5. Run all Maestro flows
bash .maestro/run_all.sh

# Or run only the per-fractal smoke
~/.maestro/bin/maestro test .maestro/05_every_fractal_smoke.yaml

# Run only the new programmatic integration test
flutter test integration_test/every_fractal_programmatic_test.dart
```

---

## 10. Key Paths Reference

| Concern | Path |
|--------|------|
| Pipeline CLI entry point | `python3 scripts/research/forge.py {doctor,retrofit,batch,review,admit,seed-aliases}` |
| Registry (single source of truth) | `docs/catalog/fractal_registry.yaml` |
| Pipeline tests | `tests/research/` |
| Emitted Dart modules | `lib/core/modules/{category_slug}/{id}/` (currently `newton_root_finding/f0001..f0013`) |
| Dart base classes (§14) | `lib/core/modules/base_classes/` |
| Dart emission Jinja templates | `scripts/research/admit/templates/dart/` |
| Spec (with §14 Dart emission) | `docs/superpowers/specs/2026-04-12-fractal-research-pipeline-design.md` |
| Stage A plan | `docs/superpowers/plans/2026-04-12-stageA-pipeline-foundation.md` |
| Stage B plan | `docs/superpowers/plans/2026-04-12-stageB-dedup-admission-dart.md` |
| Stage C plan | `docs/superpowers/plans/2026-04-12-stageC-structured-discovery.md` |
| Stage D plan | `docs/superpowers/plans/2026-04-12-stageD-unstructured-discovery.md` |
| Stage E plan | `docs/superpowers/plans/2026-04-12-stageE-maintenance-dashboard.md` |
| Maestro flows | `.maestro/0*.yaml` + `run_all.sh` |
| Canonical aliases | `research/canonical/canonical_aliases.yaml` |
| Manual seed sources | `research/seeds/` |

---

## Appendix A — How to add a new fractal via the pipeline

1. Drop a candidate JSON into `research/candidates/batch_{date}/` (schema: `scripts/research/schemas/candidate.json`).
2. `python3 scripts/research/forge.py build --batch batch_{date}` — enriches with formula_ast, hash, taxonomy.
3. `python3 scripts/research/forge.py review --batch batch_{date}` — human review.
4. `python3 scripts/research/forge.py admit --batch batch_{date}` — promotes approved candidates: writes to registry + emits Dart module + placeholder thumbnail.
5. `python3 scripts/research/forge.py doctor` — verifies invariants still hold.
6. (Follow-up) Wire the new module into `ModuleRegistry`, write real GLSL shader, render real thumbnail, promote tier → `implemented`.

### A.1 `forge` CLI quick reference

| Subcommand | Purpose |
|------------|---------|
| `forge doctor` | Run all invariant checks on the registry. Exits non-zero on error. |
| `forge retrofit [--dry-run] [--force-overwrite]` | Migrate a pre-Stage-A registry to the new schema. Refuses to re-run without `--force-overwrite`. |
| `forge seed-aliases` | (Re)build `research/canonical/canonical_aliases.yaml` from the registry + manual seed file. |
| `forge build --batch <name>` | Enrich a candidate batch in place: formula AST, hash, category, family. |
| `forge review --batch <name>` | Human-review loop over a built batch. Writes approvals under `research/decisions/`. |
| `forge admit --batch <name>` | Promote approved candidates: append to registry, emit Dart module, write placeholder thumbnail. |

### A.2 Registry entry schema (essentials)

```yaml
- id: snake_case_unique_id
  name: Human Readable Name
  shader: shaders/snake_case_gpu.frag
  category: Escape-Time | Newton / Root-Finding | 3D Fractals | …
  dimension: 2D | 3D
  defaultPower: float
  defaultIterations: float
  defaultSteps: float
  defaultBailout: float
  defaultColorScheme: int
  hasThumbnail: bool
  implemented: bool
  presets: [string]
  variants: [string]
  references: [{ title, url, doi?, year? }]
  tier: implemented | reference | aspirational
  formula_hash: sha256:<64 hex>
  quality:
    formula_hash: sha256:<64 hex>
    citation_health: { last_checked, status }
    shader_compile: { sksl, glsl, checked }
    thumbnail: { entropy, checked }
    review: { approved_by, batch }
    confidence: 0.0..1.0
```

## Appendix B — How to regenerate the registry from scratch (defensive)

Do not do this in anger. The retrofit is destructive on purpose (`--force-overwrite`) and there is only one source of truth.

```bash
python3 scripts/research/forge.py retrofit --dry-run   # show diff
python3 scripts/research/forge.py retrofit             # refuses on retrofitted data
python3 scripts/research/forge.py retrofit --force-overwrite   # only if you mean it
python3 scripts/research/forge.py seed-aliases
python3 scripts/research/forge.py doctor
```

## Appendix C — Why 370 and not 357?

The registry contains 370 entries today because **Stage B validated the full admission path** by running the orchestrator end-to-end on 13 Newton/Root-Finding variants drawn from manually curated sources (5 from Mitchell's Bridges 2019 paper, 8 classical Newton-family methods). These 13 entries passed dedup, taxonomy classification, Dart emission, and `forge doctor` — but they deliberately landed at `tier: reference` (not `implemented`) because no GLSL shader was written for them. The decision to admit them as reference-tier was a conscious *proof of pipeline*: the registry can absorb new entries, the Dart emitter produces analyzer-clean modules, and the placeholder thumbnails slot cleanly into the asset bundle. The last mile (ModuleRegistry wiring + real shaders + real thumbnails) is deliberately separated so it can be parallelized as a follow-up swarm job.

## Appendix D — Pipeline test coverage map

| Stage A | Stage B | Stage C/D/E |
|--------|--------|-------------|
| `test_schemas.py` | `test_formula_normalizer.py` | — |
| `test_forge_cli.py` | `test_taxonomy_classifier.py` | — |
| `test_registry.py` | `test_dedup.py` | — |
| `test_retrofit.py` | `test_emit_dart.py` | — |
| `test_doctor.py` | `test_build_batch.py` | — |
| `test_seed_aliases.py` | `test_review_batch.py` | — |
| | `test_thumbnail_render.py` | — |
| | `test_promote_candidate.py` | — |
| | `test_e2e_stage_b.py` | — |

Stages C/D/E will add fresh test files under `tests/research/` when those stages are executed.

## Appendix E — Things the user might reasonably ask next

1. *"Wire the 13 Newton modules into the app and ship real shaders."* — P1. Biggest user-visible win.
2. *"Run Stage C + D overnight and triage the output."* — P2. Produces 10K candidate pipeline with human review queues.
3. *"Consolidate to the 19 canonical categories."* — P4. Needed before the UI grouping/filtering can show the real shape of the catalog.
4. *"Wire maintenance crons."* — P3. Low daily cost, high compounding value.
5. *"Render real GPU thumbnails for all 357 legacy fractals that currently use placeholder tiles."* — Revisit of the thumbnail audit under `test/catalog_thumbnail_audit_test.dart`.
