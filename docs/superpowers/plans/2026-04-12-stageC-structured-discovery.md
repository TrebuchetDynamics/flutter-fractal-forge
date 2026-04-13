# Fractal Pipeline — Stage C: Structured Discovery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- []`) syntax for tracking.

**Goal:** Implement 4 structured-source crawlers that feed `research/extracted/{candidate_id}.yaml` files through the Stage B admission pipeline. Target yield: ~7,600 candidate fractals across Ultra Fractal DB (~5,000), Shadertoy (~2,000), Wikipedia (~250), and MathWorld/Paul Bourke (~350). Structured sources = deterministic parsers, no LLM needed.

**Architecture:** One crawler per source, each script-independent under `scripts/research/crawl/{source}.py`, writes raw artifacts to `research/raw/{source}/{YYYY-MM-DD}/` with `.meta.json` sidecars. Corresponding extractors under `scripts/research/extract/` parse raw → candidate YAML. `forge crawl <source>` and `forge extract <source>` subcommands orchestrate. Rate limits configurable via `config/crawl.yaml`. HTTP via `httpx` async. No LLM calls in Stage C.

**Tech Stack:** Python 3.11, **NEW**: `httpx[http2]==0.27.2`, `mwparserfromhell==0.6.6` (Wikipedia wikitext), `tree-sitter-glsl==0.1.5` + `tree-sitter==0.22.3` (Shadertoy GLSL AST), `beautifulsoup4==4.12.3` (HTML scraping).

**Prerequisites:** Stage A + B complete. `forge admit` works end-to-end on hand-authored candidates.

---

## File Structure

### New crawlers (one per source)

| File | Source | Est. yield | Strategy |
|------|--------|-----------:|----------|
| `scripts/research/crawl/ultra_fractal.py` | Ultra Fractal public formula DB | ~5,000 | Mirror .ufm files via wget, one raw per formula |
| `scripts/research/crawl/shadertoy.py` | Shadertoy API (tag=fractal) | ~2,000 | REST API, paginated, fetch GLSL + metadata |
| `scripts/research/crawl/wikipedia.py` | Wikipedia EN category:Fractals | ~250 | MediaWiki API, recursive category walk |
| `scripts/research/crawl/mathworld.py` | Wolfram MathWorld fractal pages | ~150 | Scraper, rate-limited 1 req/sec |
| `scripts/research/crawl/paul_bourke.py` | Paul Bourke's fractals pages | ~200 | Static HTML scraper |

### New extractors

| File | Input | Output |
|------|-------|--------|
| `scripts/research/extract/ufm_parser.py` | .ufm files | candidate YAML (escape_time / newton / custom) |
| `scripts/research/extract/shadertoy_parser.py` | Shadertoy JSON + GLSL | candidate YAML (raymarch_3d / escape_time) |
| `scripts/research/extract/wikipedia_parser.py` | Wikipedia wikitext | candidate YAML (varies by page) |
| `scripts/research/extract/mathworld_parser.py` | MathWorld HTML | candidate YAML |
| `scripts/research/extract/bourke_parser.py` | Paul Bourke HTML | candidate YAML |
| `scripts/research/extract/glsl_classifier.py` | Any GLSL fragment | iteration_type detection (escape_time vs raymarch_3d vs other) |

### Config

| File | Purpose |
|------|---------|
| `config/crawl.yaml` | Rate limits, API endpoints, throttling per source |
| `config/credentials.yaml.example` | Template for API keys (Shadertoy, GitHub — user fills local `credentials.yaml`, gitignored) |

### Tests

| File | Coverage |
|------|----------|
| `tests/research/test_ufm_parser.py` | 10 fixture .ufm files, assert formula_ast extraction |
| `tests/research/test_shadertoy_parser.py` | 5 fixture Shadertoy JSONs, assert iteration_type + params |
| `tests/research/test_wikipedia_parser.py` | 5 fixture wikitext pages |
| `tests/research/test_glsl_classifier.py` | 15 GLSL snippets spanning iteration_types |
| `tests/research/test_crawl_rate_limit.py` | Verify rate limit enforcement |

---

## Task 1: httpx + crawl config scaffold

- [ ] **Step 1: Add deps to `scripts/research/requirements.txt`:**
  ```
  httpx[http2]==0.27.2
  mwparserfromhell==0.6.6
  tree-sitter==0.22.3
  tree-sitter-glsl==0.1.5
  beautifulsoup4==4.12.3
  ```

- [ ] **Step 2: Write `config/crawl.yaml`:**
  ```yaml
  defaults:
    rate_limit_per_sec: 1
    timeout_sec: 30
    user_agent: "FractalForgeBot/1.0 (+https://github.com/your/repo)"

  sources:
    ultra_fractal:
      base_url: "https://formulas.ultrafractal.com/"
      rate_limit_per_sec: 0.5
      schedule: quarterly
    shadertoy:
      base_url: "https://www.shadertoy.com/api/v1/"
      rate_limit_per_sec: 1
      schedule: monthly
      requires_key: true
    wikipedia:
      base_url: "https://en.wikipedia.org/w/api.php"
      rate_limit_per_sec: 2
      schedule: on_demand
    mathworld:
      base_url: "https://mathworld.wolfram.com/"
      rate_limit_per_sec: 0.5
      schedule: on_demand
    paul_bourke:
      base_url: "http://paulbourke.net/fractals/"
      rate_limit_per_sec: 1
      schedule: on_demand
  ```

- [ ] **Step 3: `config/credentials.yaml.example`:**
  ```yaml
  shadertoy:
    api_key: "YOUR_SHADERTOY_KEY_HERE"
  github:
    token: "ghp_YOUR_GITHUB_TOKEN_HERE"
  ```

- [ ] **Step 4: Add `config/credentials.yaml` to `.gitignore`. Commit config + deps.**

---

## Task 2: Rate limiter + HTTP client wrapper

**File:** `scripts/research/lib/http_client.py`

Unified async HTTP with rate limiting, retries, and caching by URL.

- [ ] **Step 1: Tests: rate limit enforced (fire 10 reqs, wall clock ≥ expected), retry on 5xx.**

- [ ] **Step 2: Implement (~80 LOC) using `httpx.AsyncClient` + `asyncio.Semaphore`.**

- [ ] **Step 3: Commit.**

---

## Task 3: ultra_fractal.py crawler + ufm_parser extractor

Ultra Fractal `.ufm` files have a formula definition block. Parser extracts: name, init expression, update expression, params with defaults, references.

- [ ] **Step 1: Write the crawler. Start with a small test mirror (10 formulas).**

```python
# scripts/research/crawl/ultra_fractal.py
async def crawl(output_dir: Path, limit: int | None = None) -> int:
    """Mirror .ufm files from Ultra Fractal's public DB."""
```

- [ ] **Step 2: Write the parser.**

```python
# scripts/research/extract/ufm_parser.py
def parse(ufm_content: str, source_url: str) -> dict:
    """Return candidate dict. Raises on unparseable."""
```

Parser handles these .ufm constructs:
- `FractalName {`
- `init: z = ...`
- `loop: z = ...`
- `bailout: |z| > ...`
- `default: param name = value`

- [ ] **Step 3: Hand-collect 10 fixture .ufm files of varying complexity. Test parser on each.**

- [ ] **Step 4: Wire `forge crawl ultra_fractal` and `forge extract ultra_fractal` subcommands.**

- [ ] **Step 5: Smoke run: `forge crawl ultra_fractal --limit 10` then `forge extract ultra_fractal`. Assert 10 candidates in `research/extracted/`.**

- [ ] **Step 6: Commit.**

---

## Task 4: shadertoy.py crawler + shadertoy_parser extractor

- [ ] **Step 1: Shadertoy API requires key. Document setup in config/credentials.yaml.example.**

- [ ] **Step 2: Crawler fetches tag-filtered list, then per-id fetches full JSON.**

- [ ] **Step 3: Parser extracts GLSL from `renderpass[0].code`, runs glsl_classifier to detect iteration_type.**

- [ ] **Step 4: glsl_classifier (tree-sitter): detects escape-time pattern (for loop over `z = z*z + c` + bailout check) vs raymarch (sphere tracing + signed distance).**

- [ ] **Step 5: Tests with 5 fixture JSONs.**

- [ ] **Step 6: Wire CLI. Commit.**

---

## Task 5: wikipedia.py crawler + parser

- [ ] **Step 1: Crawler uses MediaWiki API `action=query&list=categorymembers&cmtitle=Category:Fractals&cmlimit=max&cmtype=page`.**

- [ ] **Step 2: For each page: fetch wikitext via `action=parse&prop=wikitext`. mwparserfromhell → sections, infoboxes, LaTeX (`<math>` blocks).**

- [ ] **Step 3: Parser extracts: page title, first paragraph as description_en, `<math>` blocks as formula_latex, category tree parents. No formula_ast (LaTeX → AST is hard; leave as null, let manual review fill it).**

- [ ] **Step 4: 5 fixture pages (Mandelbrot, Julia, Sierpinski, Koch, Strange_attractor). Test parser assertions.**

- [ ] **Step 5: Wire CLI. Commit.**

---

## Task 6: mathworld.py + paul_bourke.py

- [ ] **Step 1: Both are HTML scrapers. Use BeautifulSoup + rate limit.**

- [ ] **Step 2: MathWorld: extract title, description, associated Wolfram formula when shown.**

- [ ] **Step 3: Paul Bourke: extract fractal name, algorithm description, sample images (kept as reference URLs only — don't download).**

- [ ] **Step 4: 10 fixture HTML snapshots per source. Test parsers.**

- [ ] **Step 5: Wire CLI. Commit.**

---

## Task 7: glsl_classifier.py

Tree-sitter GLSL parse → detect iteration pattern. Rules:

| Pattern in source | Classification |
|-------------------|----------------|
| `for (int i=0; i<N; i++) { z = z*z + c; if (length(z) > 2.0) break; }` | escape_time |
| Sphere tracing: `float t = 0; for(...) { vec3 p = ro + t*rd; float d = sdf(p); ... }` | raymarch_3d |
| RK4 / ODE integration over state | strange_attractor |
| L-System string replacement on CPU (rare in GLSL) | l_system (unlikely; flag as "other") |

- [ ] **Step 1: 15 fixture GLSL snippets covering all patterns.**

- [ ] **Step 2: Tree-sitter parse + detection rules (~150 LOC).**

- [ ] **Step 3: Tests per snippet.**

- [ ] **Step 4: Commit.**

---

## Task 8: End-to-end Stage C smoke run

- [ ] **Step 1: Run all 5 crawlers with `--limit 20` each. Verify `research/raw/*/{today}/` populated.**

- [ ] **Step 2: Run all 5 extractors. Verify `research/extracted/` has 80-100 candidate YAMLs.**

- [ ] **Step 3: Run `forge batch` → `forge review --auto-approve-new` → `forge admit`. Verify registry gains ~50-80 new entries (some will dedup-merge with the retrofitted 357) and Dart files appear.**

- [ ] **Step 4: `forge doctor -v` still green. `flutter analyze` still green.**

- [ ] **Step 5: Commit.**

---

## Done-Definition for Stage C

- [ ] 5 crawlers operational, each with fixture tests
- [ ] 5 extractors producing schema-valid candidate YAMLs
- [ ] glsl_classifier correctly classifies 15 test cases
- [ ] End-to-end smoke: 100 real candidates flow from crawl → extract → admit with Dart emission
- [ ] `forge doctor` green after Stage C admission
- [ ] CI workflow extended to test crawlers offline (mocked HTTP) — real network reserved for scheduled cron

## Risks

| Risk | Mitigation |
|------|-----------|
| Ultra Fractal DB license restrictions | Per-formula license field in extracted YAML; admission gate filters on license |
| Shadertoy API key required but user may not have one | Skip Shadertoy in offline CI; document setup in README |
| Wikipedia LaTeX is often informal / malformed | Store `formula_latex` as-is; leave `formula_ast` null; rely on manual review or Stage B's sympy parser |
| MathWorld robots.txt / terms-of-service | Respect robots.txt, hold rate at 0.5 req/sec, only use content for reference links (not reproduction) |
