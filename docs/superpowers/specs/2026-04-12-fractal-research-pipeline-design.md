# Fractal Research & Maintenance Pipeline — Design Spec

**Date:** 2026-04-12
**Owner:** Sidon (xel)
**Status:** Approved (design); awaiting user review of written spec
**Implementation mode:** subagent-driven development

---

## 0. Context & Relationship to Existing Specs

This spec defines the **research and maintenance pipeline** that feeds the 10K fractal catalog described in `2026-04-11-fractal-catalog-design.md`. It **supersedes** the following aspects of the earlier spec (per session direction 2026-04-12):

- ❌ EN+CN bilingual docs → ✅ **EN-only output**
- ❌ `{id}.zh.md` files dropped entirely
- ✅ Keeps: 19 categories, two-tier system (Implemented / Reference), `fractal_registry.yaml` as single source of truth, implementation checklist
- ✅ Adds: end-to-end pipeline (discovery → extraction → canonicalization → admission → maintenance), `research/` tree, CI gates, cron-driven maintenance

Deferred items (runtime shader compilation, user uploads, marketplace, web backend, automated formula generation) live in `FUTURE-PLAN.md` — they are not in scope but are not rejected.

---

## 1. Vision

Build **the world's largest fractal catalog** — 10,000+ entries — with a mechanical pipeline that sustains quality, performance, and reproducibility as it scales from 370 to 10K. Research English sources primarily; use Chinese sources only to discover rare Chinese-origin fractals, output all documentation in English.

---

## 2. Architecture Overview

Three stages + one registry. Every fractal flows through the same pipeline; the registry is the single source of truth.

```
┌─────────────┐   ┌─────────────┐   ┌──────────────┐   ┌──────────────────┐
│  DISCOVERY  │──▶│ EXTRACTION  │──▶│ CANONICAL-   │──▶│ fractal_registry │
│  (crawl)    │   │ (parse)     │   │ IZATION      │   │     .yaml        │
│             │   │             │   │ (dedup+name) │   │ (source of truth)│
└─────────────┘   └─────────────┘   └──────────────┘   └──────────────────┘
      │                 │                  │                    │
      ▼                 ▼                  ▼                    ▼
  research/raw/    research/       research/          docs/catalog/{id}/
  {source}/        extracted/      candidates/        (docs + shader + metadata)
  {date}/          {id}.yaml       {id}.yaml                  │
                                        │                     ▼
                                        ▼              MAINTENANCE (cron)
                                   Human review        • link health
                                   gate (batch PR)     • taxonomy audit
                                                       • dedup re-scan
                                                       • shader regression
```

### Invariants

- Nothing enters `fractal_registry.yaml` without **citation + canonical EN name + category + formula hash**
- Raw artifacts are kept forever under `research/raw/` (provenance)
- `candidates/` is the human-review staging area; merging = promotion to registry + creation of `docs/catalog/{id}/`
- The registry is the *only* source of truth; `docs/catalog/` is derived and reconstructable

---

## 3. Discovery Layer

Sources split into three tiers by structure. Each tier gets a different crawl strategy.

### Tier 1 — Structured sources (deterministic parsers, no LLM)

| Source | Type | Est. entries | How to crawl |
|--------|------|-------------:|--------------|
| Ultra Fractal public formula DB (`.ufm`/`.upr`) | EN | ~5,000 | Mirror + Python `.ufm` parser |
| Shadertoy API (tag: fractal) | EN | ~2,000 | REST API + GLSL scan |
| Wikipedia EN category: "Fractals" | EN | ~250 | MediaWiki API, recursive |
| Wikipedia 中文 分类:分形 | CN (discovery) | ~20 | MediaWiki API |
| MathWorld (Wolfram) | EN | ~150 | Scraper with rate limit |
| arXiv (q=fractal, nlin.CD, math.DS) | EN | ~1,000 | arXiv API → PDF → GROBID |
| GitHub (topic:fractal, stars>10) | EN | ~500 | GitHub search API + GLSL scan |
| Paul Bourke's fractals pages | EN | ~200 | Static HTML scraper |

### Tier 2 — Semi-structured (parser + LLM extraction)

| Source | Type | Strategy |
|--------|------|----------|
| Fractal Forums archives (18K posts) | EN | Scrape + batched LLM extraction |
| Mu-Ency (mrob.com) | EN | HTML scraper + LLM prose cleanup |
| CNKI 知网 (search: 分形) | CN (discovery only) | Manual PDF download → GROBID + LLM extraction, EN output |
| 百度学术 / 知乎 math threads | CN (discovery only) | Manual seed list + LLM extraction, EN output |

### Tier 3 — Seed lists (manual, high-quality)

- Books: Mandelbrot *Fractal Geometry of Nature*, Peitgen *Beauty of Fractals*, 陈关荣 complex networks work
- Hand-curated alias seed: `research/seeds/canonical_aliases.seed.yaml`

### Crawl orchestration

- One script per source under `scripts/research/crawl/`
- Output to `research/raw/{source}/{YYYY-MM-DD}/` with `.meta.json` sidecar `{source, url, fetched_at, license}`
- Scheduled via cron: Ultra Fractal DB quarterly, Shadertoy monthly, arXiv weekly, Wikipedia on-demand
- Rate limits in `config/crawl.yaml`, default 1 req/sec

### CN strategy (reality)

Native Chinese fractal corpus is small (~50 papers + ~20 Wikipedia pages). CN contribution:

1. Discovery of Chinese-origin fractals (Chen attractor 陈氏系统, Lü system 吕系统, Sprott-CNKI variants) — expected yield 30–80 unique entries
2. Alias harvesting for dedup memory (CN names kept in `aliases` list for future dedup, **not** in output docs)

**All output is English.** No CN docs produced.

---

## 4. Extraction Layer

Every raw artifact becomes one `research/extracted/{candidate_id}.yaml`. Deterministic parsers preferred; LLM only where structure is absent.

### Parser matrix

| Source format | Parser | LLM involved? |
|---------------|--------|---------------|
| Ultra Fractal `.ufm` | Python AST parser → formula + params | No |
| Shadertoy JSON + GLSL | Field mapping + AST scan of `mainImage` | No |
| Wikipedia wikitext | `mwparserfromhell` → sections + infobox + LaTeX | No |
| arXiv PDF | GROBID → XML → XPath for equations + abstract | No |
| GLSL files (GitHub) | Tree-sitter GLSL → detect iteration loops | Light (name/description) |
| Forum posts / Mu-Ency prose | LLM extraction against fixed schema | Yes |
| CNKI PDFs | GROBID → LLM extracts formula + EN-translates name | Yes |

### Extraction schema (enforced via JSON Schema)

```yaml
candidate_id: ct_20260412_a4f9    # timestamp + content hash
source:
  type: ultra_fractal | shadertoy | wikipedia | arxiv | github | forum | cnki | manual
  url: https://...
  fetched_at: 2026-04-12T14:22:11Z
  license: CC-BY-SA-3.0 | MIT | ...

canonical:                         # filled by canonicalization stage
  id: null                         # f001_mandelbrot_set once assigned
  name_en: null
  category: null

proposed_name: "Tricorn"
aliases: ["Mandelbar", "z -> conj(z)^2 + c"]
formula_latex: "z_{n+1} = \\overline{z_n}^2 + c"
formula_ast:
  iteration_type: escape_time
  variables: [z, c]
  update: "z = conj(z)^2 + c"
  init: "z = 0"
params:
  iterations: {default: 500, range: [1, 10000]}
  bailout:    {default: 2.0, range: [1.0, 10.0]}
  power:      {default: 2.0, range: [1.0, 12.0]}
presets: []
variants: []
description_en: "The tricorn, also known as the mandelbar..."
references: [{author: "Crowe", year: 1989, url: "..."}]

quality:
  formula_hash: sha256:<normalized_formula_ast>
  has_citation: true
  has_working_shader_candidate: false
  extraction_confidence: 0.92
  flags: []
```

### Quality gates (extraction exit)

Candidate rejected (moved to `research/rejects/` with reason) if:

- Missing formula OR citation OR `proposed_name`
- `extraction_confidence < 0.7`
- `formula_ast` fails normalizer (unparseable)
- Forbidden license (e.g., GPL contamination for a shippable shader)

### Performance targets

| Stage | Target throughput |
|-------|------------------|
| Ultra Fractal `.ufm` parse | 5,000 files < 60s |
| arXiv PDF → candidate | ~20/min (GROBID-bound) |
| GLSL tree-sitter scan | 500 files/min |
| LLM extraction (forum post) | 10/min @ Haiku, 2/min @ Sonnet |

LLM calls batched (20 posts per prompt, structured JSON output). Cache by content hash — re-running against the same raw file is free.

---

## 5. Canonicalization & Deduplication

The hardest stage. At 10K scale, "Mandelbrot," "z² + c," "Multibrot d=2," and a random Shadertoy point at the same object. Without mechanical dedup you end up with 3K near-duplicates.

### Canonical ID contract

Every accepted fractal gets exactly one `id` of the form `f{NNNN}_{snake_name}` — immutable once assigned. `NNNN` is a monotonic counter owned by `fractal_registry.yaml`.

### Dedup pipeline (runs on every candidate)

**1. Formula hash match (exact)**

- Normalize `formula_ast`: alpha-rename variables, sort commutative ops, strip whitespace, canonical LaTeX-free form
- SHA256 the normalized string
- Hash collision → **auto-merge** (add as alias + citation, no new ID)
- Expected catch rate: ~40% of duplicates

**2. Name/alias fuzzy match**

- Normalize: lowercase, strip punctuation, drop filler words ("set", "fractal", "attractor")
- Compare against `canonical_aliases.yaml`
- Levenshtein ≤ 2 OR token-set ratio ≥ 0.85 → **flag for review** with suggested merge
- Expected catch rate: ~25% of duplicates

**3. Family classifier (structural)**

- Rule-based over `formula_ast`: "z = z^d + c with d parameterized" → Multibrot family; "z = conj(z)^d + c" → Tricorn family; etc.
- Family match + only numeric params differ → **variant**, not a new entry
- Emits variant-or-sibling suggestion for reviewer

### Canonical name registry

`research/canonical/canonical_aliases.yaml` — single source of truth for alias → id mapping:

```yaml
f001_mandelbrot_set:
  canonical_name: "Mandelbrot Set"
  aliases:
    - "Mandelbrot"
    - "M-set"
    - "z^2 + c set"
    - "Fractal de Mandelbrot"
    - "曼德勃罗集合"           # kept for discovery-time dedup, NOT for output
  family: mandelbrot
  parent: null
  variants: [f002_multibrot, f003_tricorn, f004_burning_ship]
```

Aliases are **never deleted** — deleting an alias loses dedup history.

### Taxonomy assignment

- Deterministic classifier from `formula_ast.iteration_type` → one of the 19 categories
- Uncertainty (score < 0.8) → flag `category: uncertain` for human
- Drift alarm: if > 20% of one category's entries, run split-suggestion job (category IDs never renumber; splits add new Roman numerals)

### Human review gate

Candidates land in `research/candidates/` grouped by weekly batch. Reviewer sees a terminal diff:

- **New** entries (no match)
- **Auto-merged** (formula hash hit) — vetoable
- **Suggested merges** (fuzzy/family hit) — approve/reject
- **Uncertain category** — pick from dropdown

Tool: `scripts/research/review/review_batch.py` — colored terminal UI, writes verdicts to `research/decisions/{batch}.yaml`.

### Performance

- Dedup over 500 candidates vs 10K registry: **< 30s** (in-memory hash table + sorted alias trie)
- No LLM in dedup hot path — LLM only for reviewer explanation text

---

## 6. Quality Gates & Two-Tier Admission

### Tier definitions

| Tier | Files | Shown in app? | Registry flag |
|------|-------|---------------|---------------|
| **Reference** | `{id}.md` + `metadata.yaml` | No | `tier: reference` |
| **Implemented** | + `{id}.glsl` + `thumbnails/default.png` + shader registered in `ModuleRegistry` | Yes | `tier: implemented` |

Promotion Reference → Implemented only after shader verification. Demotion keeps registry entry but drops app visibility.

### Admission gate: Reference tier

- [x] Canonical `id` assigned
- [x] `canonical.name_en` present
- [x] `formula_ast` parses, `formula_hash` unique OR aliased
- [x] `category` assigned (one of 19, not `uncertain`)
- [x] ≥ 1 citation with URL returning HTTP 200 at admission time
- [x] Description 80–600 words
- [x] Passed dedup pipeline
- [x] Human reviewer approved batch

Rejected candidates recorded in `research/rejects/{candidate_id}.yaml` — never deleted (future retry possible).

### Admission gate: Implemented tier

All Reference gates, plus:

- [x] `{id}.glsl` compiles on **both SkSL and GLSL** backends (CI via headless Flutter compile)
- [x] Thumbnail renders without artifacts (entropy threshold check — rejects all-black / all-noise)
- [x] `metadata.yaml` params round-trip through the shader (render → pixel-hash vs baseline)
- [x] `flutter analyze` zero errors, zero warnings
- [x] First render < 50ms on reference device profile (Pixel 7)

### CI-enforced gates

`.github/workflows/catalog-ci.yml` on every PR touching `fractal_registry.yaml` or `docs/catalog/`:

1. **Schema lint** against `scripts/research/schemas/`
2. **Link check** — HEAD every citation, Wayback fallback
3. **Dedup replay** — re-run dedup, fail on collision with existing entry
4. **Shader compile** (implemented tier) — SkSL + GLSL
5. **Thumbnail entropy** (implemented tier) — variance threshold
6. **Taxonomy balance** — warn (not fail) if any category > 25%

### Quality signals in registry

```yaml
quality:
  formula_hash: sha256:...
  citation_health: {last_checked: 2026-04-12, status: ok}
  shader_compile: {sksl: ok, glsl: ok, checked: 2026-04-12}
  thumbnail: {entropy: 7.82, checked: 2026-04-12}
  review: {approved_by: xel, batch: b_2026_04_w15}
  confidence: 0.94
```

### Performance

- Admission of 500-candidate batch end-to-end: **< 5 min**
- CI on 10-entry PR: **< 2 min** (content-addressed cache, untouched entries skipped)

---

## 7. Maintenance Operations

A 10K catalog rots without active maintenance. URLs die, taxonomies drift, shaders break under Flutter upgrades.

### Scheduled jobs

| Job | Cadence | What it does | Output |
|-----|---------|-------------|--------|
| `link-health` | Nightly | HEAD every citation; on 4xx/5xx, fetch Wayback snapshot, rewrite to `archived_url` | Auto-PR if > 10 fixes |
| `dedup-rescan` | Weekly | Re-hash every `formula_ast`, re-check aliases against full registry | `reports/dedup-{date}.md` |
| `taxonomy-audit` | Weekly | Count per category; > 25% or < 5 → suggest split/merge | `reports/taxonomy-{date}.md` |
| `shader-regression` | On Flutter SDK bump | Recompile all implemented `.glsl`, diff thumbnails vs baseline | Auto-PR with failures |
| `citation-refresh` | Quarterly | Re-fetch arXiv / Wikipedia / Ultra Fractal for entries > 1yr old | Batch candidate file |
| `thumbnail-reseed` | On demand | Re-render all thumbnails with current shader + params | Overwrites `thumbnails/default.png` |

All jobs idempotent, scripted in `scripts/research/maintenance/`, log to `reports/`, open PRs rather than committing directly.

### Dashboard

`scripts/research/maintenance/dashboard.py` emits static `reports/dashboard.html`:

- Total entries per tier, per category
- Citation health (% green / yellow / red)
- Shader compile status distribution
- Top-10 stale entries
- Category balance histogram
- Growth chart (entries admitted per week)

Regenerated by every maintenance job. No server.

### Drift handling

- **Taxonomy drift** (category > 25%): auto-suggest subfamilies from `formula_ast.family`; split = batch PR; category IDs never renumber
- **Name drift**: add to `aliases`, never change `canonical.name_en` once set (exception: documented rename PR)
- **Formula drift** (source paper corrects formula): bump `formula_version`, keep old `formula_hash` in `formula_history[]`

### Ingestion throttle

Hard cap: **500 new entries per week** admitted to the registry. Above that, review quality collapses. Discovery can run faster; the bottleneck is intentional at the review gate.

### Backup / recovery

- `fractal_registry.yaml` is the single source of truth; everything else derives
- Git history is the backup
- `scripts/research/admit/rebuild_catalog.py` reconstructs `docs/catalog/` byte-identical from registry + shaders

### Performance

- `link-health` over 10K URLs: ~15 min (50 parallel HEADs, 1s timeout)
- `dedup-rescan` over 10K entries: < 2 min
- `taxonomy-audit`: < 5s
- `shader-regression` over 3K shaders: ~20 min

---

## 8. Directory Layout, Schemas & Tooling

### Repository layout

```
flutter-fractal-forge/
├── docs/
│   ├── catalog/
│   │   ├── fractal_registry.yaml         # SINGLE SOURCE OF TRUTH
│   │   ├── I_escape_time/{id}/
│   │   │   ├── {id}.md                   # EN only (no .zh.md)
│   │   │   ├── {id}.glsl                 # implemented tier only
│   │   │   ├── metadata.yaml
│   │   │   └── thumbnails/default.png
│   │   └── ...19 categories
│   └── superpowers/specs/
│
├── research/
│   ├── raw/{source}/{YYYY-MM-DD}/        # immutable + .meta.json sidecars
│   ├── extracted/{candidate_id}.yaml
│   ├── candidates/{batch_id}/
│   ├── decisions/{batch_id}.yaml
│   ├── rejects/{candidate_id}.yaml       # never deleted
│   ├── canonical/canonical_aliases.yaml
│   └── seeds/canonical_aliases.seed.yaml
│
├── scripts/research/
│   ├── crawl/                            # one file per source
│   │   ├── ultra_fractal.py
│   │   ├── shadertoy.py
│   │   ├── arxiv.py
│   │   ├── wikipedia.py
│   │   ├── github_glsl.py
│   │   ├── mathworld.py
│   │   ├── paul_bourke.py
│   │   ├── fractal_forums.py
│   │   └── cnki.py
│   ├── extract/
│   │   ├── ufm_parser.py
│   │   ├── glsl_classifier.py
│   │   ├── grobid_pdf.py
│   │   └── llm_extract.py
│   ├── canonicalize/
│   │   ├── formula_normalizer.py
│   │   ├── dedup.py
│   │   └── taxonomy_classifier.py
│   ├── review/
│   │   ├── build_batch.py
│   │   └── review_batch.py
│   ├── admit/
│   │   ├── promote_candidate.py
│   │   ├── thumbnail_render.py
│   │   └── rebuild_catalog.py
│   ├── maintenance/
│   │   ├── link_health.py
│   │   ├── dedup_rescan.py
│   │   ├── taxonomy_audit.py
│   │   ├── shader_regression.py
│   │   ├── citation_refresh.py
│   │   └── dashboard.py
│   ├── schemas/
│   │   ├── candidate.schema.json
│   │   ├── metadata.schema.json
│   │   └── registry_entry.schema.json
│   └── forge.py                          # single CLI entry point
│
├── .github/workflows/
│   └── catalog-ci.yml
│
└── reports/
    ├── dashboard.html
    ├── dedup-{date}.md
    ├── taxonomy-{date}.md
    └── logs/
```

### Authoritative schemas

Three JSON Schemas with shared `$ref` sub-schemas (`formula_ast`, `params`, `citation`):

1. `candidate.schema.json` — `research/extracted/*.yaml` shape
2. `registry_entry.schema.json` — entries in `fractal_registry.yaml`
3. `metadata.schema.json` — per-fractal `docs/catalog/{id}/metadata.yaml`

All schemas linted in CI and in every pipeline stage.

### CLI surface

Single `forge` entry point, subcommands are idempotent, all log to `reports/logs/`:

```bash
./forge crawl <source>              # runs crawl/{source}.py
./forge extract <source> [--date]   # extract all raw from source
./forge canonicalize                # dedup + taxonomy pass on extracted/
./forge batch                       # build next candidates/ batch
./forge review <batch_id>           # interactive review UI
./forge admit <batch_id>            # promote approved candidates
./forge maintain <job>              # run a maintenance job on demand
./forge dashboard                   # regenerate reports/dashboard.html
./forge doctor                      # verify repo invariants
```

### Tech stack (minimal)

- Python 3.11 for all scripts — one `requirements.txt`
- `ruamel.yaml` (round-trip YAML preserving registry comments/order)
- `jsonschema` for schema lint
- `tree-sitter-glsl` for GLSL parsing
- GROBID (Docker) for PDF extraction
- `httpx` async for parallel crawls & link health
- Anthropic SDK (Haiku batched extraction, Sonnet for edge cases)
- **No database** — YAML + git is the backend
- Flutter test driver for thumbnail rendering (reuses app shader pipeline)

---

## 9. Phased Rollout & Integration

### Supersedes list (explicit changes to 2026-04-11 spec)

- ❌ EN+CN bilingual docs → ✅ EN-only
- ❌ `{id}.zh.md` files dropped
- ✅ Keeps: 19 categories, two-tier system, registry as source of truth, implementation checklist
- ✅ Adds: this pipeline, `research/` tree, CI gates, maintenance cron

### Rollout stages

**Stage A — Foundation (blocks everything else)**

1. Three JSON Schemas
2. `forge doctor` — invariant checker over current registry
3. Retrofit existing 370 registry entries with `formula_hash`, `quality` block, `tier`
4. Seed `research/canonical/canonical_aliases.yaml` from existing registry

**Stage B — Dedup + admission gates**

5. `formula_normalizer.py` + `dedup.py` + taxonomy classifier
6. `catalog-ci.yml` with schema lint + link check + dedup replay
7. `promote_candidate.py` + thumbnail render pipeline
8. `review_batch.py` terminal UI

Exit: any human can hand-write a candidate YAML and ship it through the gate. Pipeline functional without any crawler.

**Stage C — Structured discovery (highest-yield sources)**

9. `ultra_fractal.py` crawl + `ufm_parser.py` (~5,000 candidates)
10. `shadertoy.py` + `glsl_classifier.py` (~2,000 candidates)
11. `wikipedia.py` (~250 candidates)
12. `mathworld.py` + `paul_bourke.py` (~350 candidates)

Exit: first discovery → review cycle run end-to-end.

**Stage D — Unstructured discovery**

13. `arxiv.py` + GROBID
14. `github_glsl.py`
15. `fractal_forums.py` + `llm_extract.py` batched
16. `cnki.py` (Chinese-origin discovery, EN output)

**Stage E — Maintenance**

17. `link_health.py` + Wayback fallback
18. `dedup_rescan.py` + `taxonomy_audit.py`
19. `shader_regression.py` wired to Flutter SDK bump
20. `citation_refresh.py`
21. `dashboard.py`

### Milestones

| Milestone | Gate | Target |
|-----------|------|--------|
| Stage A done | `forge doctor` passes on retrofitted 370 | Before any new admission |
| Stage B done | 10 hand-written candidates admitted | Before crawlers run |
| Phase 0 done | 370 entries all pass CI (EN-only) | 370 green |
| Phase 1 done | +630 admitted from Stages C/D | 1,000 entries |
| Phase 2 done | +2,000 admitted, maintenance running | 3,000 entries |
| Phase 3+ | Sustained throttle + automated discovery | 10,000+ |

---

## 10. Out of Scope (see FUTURE-PLAN.md)

- ❌ Chinese-language output (EN-only)
- ❌ Runtime shader compilation → FUTURE-PLAN.md §1
- ❌ User-generated formula uploads → FUTURE-PLAN.md §2
- ❌ Web dashboard backend → FUTURE-PLAN.md §3
- ❌ Community marketplace / voting → FUTURE-PLAN.md §4
- ❌ Automated formula generation → FUTURE-PLAN.md §5

---

## 11. Performance & Quality Commitments (pinned)

| Measure | Target |
|---------|--------|
| Discovery → admission sustainable rate | ~500 entries/week |
| 500-candidate batch end-to-end | < 30 min |
| CI on 10-entry PR | < 2 min |
| Link-health nightly over 10K | < 15 min |
| Shader regression over 3K shaders | < 20 min |
| Dedup over 500 vs 10K | < 30 s |
| Rejection rate (health signal) | 15–35% of candidates |

---

## 12. Success Criteria

| Criterion | How verified |
|-----------|--------------|
| Registry is single source of truth | `rebuild_catalog.py` reconstructs `docs/catalog/` byte-identical |
| No duplicate fractals | `dedup-rescan` weekly report clean |
| Citations stay live | `link-health` < 2% red at any time |
| Implemented tier always works | `shader-regression` green on every SDK bump |
| Throughput sustained | ≥ 500 admitted/week across Phases 1–2, review backlog ≤ 1 week |
| Quality stays high | Rejection rate in 15–35% band |

---

## 13. Open Risks

| Risk | Mitigation |
|------|-----------|
| Ultra Fractal DB license restrictions per-formula | Per-entry license field; filter on admission |
| LLM hallucinates formulas in prose extraction | `formula_ast` normalizer rejects malformed; extraction confidence ≥ 0.7; human review gate |
| GROBID misparses equations | Fall back to LLM extraction; flag low confidence |
| 10K entries outgrow single YAML registry | Shard only when file > 50MB; keep single file as long as feasible |
| Flutter shader pipeline changes break existing entries | `shader-regression` cron catches; migration scripts per SDK bump |
| Review gate becomes bottleneck | 500/week throttle is intentional; reviewer-assist tooling can lift if quality holds |
