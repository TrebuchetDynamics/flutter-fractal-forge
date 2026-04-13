# Fractal Pipeline — Stage D: Unstructured Discovery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- []`) syntax for tracking.

**Goal:** Implement 4 unstructured-source crawlers + LLM-backed extractors for arXiv PDFs, GitHub GLSL repositories, Fractal Forums posts, and CNKI (Chinese-origin fractals only, English output). Target yield: ~3,000 candidates (arXiv ~1,000, GitHub ~500, Fractal Forums ~1,500, CNKI ~50 Chinese-origin). Unstructured sources require LLM extraction because schema is absent from source.

**Architecture:** Same crawl → extract → canonicalize pattern as Stage C, but the **extract** step uses batched LLM calls (Anthropic Haiku for scale, Sonnet for high-confidence final pass). GROBID Docker service for PDF → XML. Cost discipline: cache by content hash, batch 20 items per prompt, 10/min throughput target at Haiku.

**Tech Stack:** Python 3.11, **NEW**: `anthropic==0.39.0` (LLM SDK), `arxiv==2.1.3` (arXiv API), `PyPDF2==3.0.1` or GROBID via HTTP, `PyGithub==2.4.0` (GitHub API). User must provide `ANTHROPIC_API_KEY` in environment and run GROBID via Docker.

**Prerequisites:** Stage A + B + C complete. `forge admit` works. ~8K-100 candidates admitted from Stage C.

---

## File Structure

### New crawlers

| File | Source | Est. yield | Strategy |
|------|--------|-----------:|----------|
| `scripts/research/crawl/arxiv.py` | arXiv API (q=fractal, classes: nlin.CD, math.DS) | ~1,000 | arXiv library → PDF download |
| `scripts/research/crawl/github_glsl.py` | GitHub code search topic:fractal stars>10 | ~500 | PyGithub, clone repos, scan .glsl/.frag |
| `scripts/research/crawl/fractal_forums.py` | Fractal Forums archives scrape | ~1,500 | Forum scraper, extract posts with code blocks |
| `scripts/research/crawl/cnki.py` | CNKI search: 分形 Chinese-origin fractals | ~50 | Manual seed list + scraped abstract; output English-only |

### New extractors

| File | Strategy |
|------|----------|
| `scripts/research/extract/grobid_pdf.py` | GROBID HTTP client, PDF → TEI XML → XPath queries |
| `scripts/research/extract/llm_extract.py` | Batched Anthropic SDK calls with structured JSON output |
| `scripts/research/extract/arxiv_parser.py` | GROBID XML + LLM for abstract → candidate YAML |
| `scripts/research/extract/github_scanner.py` | Tree-sitter GLSL + LLM for README/docs → candidate |
| `scripts/research/extract/forum_parser.py` | HTML scrape + LLM extraction per post |
| `scripts/research/extract/cnki_parser.py` | PDF + LLM translate-and-extract (CN → EN) |

### LLM infra

| File | Purpose |
|------|---------|
| `scripts/research/lib/llm_client.py` | Anthropic SDK wrapper: batching, caching, retry, structured JSON |
| `scripts/research/lib/content_cache.py` | Disk cache keyed by SHA256(prompt+content) — skips re-extraction |
| `scripts/research/lib/prompts/extract_fractal.txt` | System prompt for structured extraction |
| `scripts/research/lib/prompts/translate_chinese.txt` | System prompt for CN paper title/abstract → EN |

### Config

| File | Purpose |
|------|---------|
| `config/llm.yaml` | Model selection, temperature, cost budgets per task |

### Tests

| File | Coverage |
|------|----------|
| `tests/research/test_grobid_pdf.py` | 3 fixture PDFs against mocked GROBID server |
| `tests/research/test_llm_extract.py` | Mocked Anthropic responses, cache hits, batching |
| `tests/research/test_arxiv_parser.py` | 5 fixture arXiv papers → candidates |
| `tests/research/test_github_scanner.py` | 5 fixture repos with varied GLSL quality |
| `tests/research/test_forum_parser.py` | 5 fixture forum posts |
| `tests/research/test_cnki_parser.py` | 3 fixture Chinese papers, verify EN-only output |

---

## Task 1: LLM client + content cache

- [ ] **Step 1: Add `anthropic==0.39.0` to requirements. Document `ANTHROPIC_API_KEY` in README.**

- [ ] **Step 2: Write `config/llm.yaml`:**
  ```yaml
  default_model: claude-haiku-4-5-20251001
  batch_size: 20
  temperature: 0.1
  max_tokens: 4000
  cache_dir: research/.llm_cache
  budget_usd_per_run: 5.00
  ```

- [ ] **Step 3: Tests for llm_client (mocked), content_cache (tmp_path).**

- [ ] **Step 4: Implement `llm_client.py`:**
  ```python
  async def extract_structured(
      prompts: list[str],
      schema: dict,       # JSON schema of expected output
      model: str = "claude-haiku-4-5-20251001",
      use_cache: bool = True,
  ) -> list[dict]:
      """Batch extraction. Returns one dict per prompt. Cached by content hash."""
  ```

- [ ] **Step 5: Write `content_cache.py` (~50 LOC disk-based, SHA256 keys).**

- [ ] **Step 6: Commit.**

---

## Task 2: GROBID wrapper

- [ ] **Step 1: Document GROBID Docker setup in README.** (Runs on localhost:8070 by default.)

- [ ] **Step 2: Tests: mock HTTP responses.**

- [ ] **Step 3: Implement (~100 LOC):**
  ```python
  async def parse_pdf(pdf_path: Path, grobid_url: str = "http://localhost:8070") -> dict:
      """POST /api/processFulltextDocument → TEI XML → extracted {title, abstract, refs, equations[]}."""
  ```

- [ ] **Step 4: Commit.**

---

## Task 3: System prompt design — `extract_fractal.txt`

The prompt accepts raw text (forum post, paper abstract, README) and returns a candidate YAML structure. Key requirements:

- Strict JSON output (validated against candidate.schema.json on receipt)
- Extract: proposed_name, aliases, formula_latex, formula_ast (best-effort, nullable), params, presets, references
- Never invent citations; if unclear, return `references: []` and set `quality.confidence < 0.7`
- For Chinese content, translate names and descriptions to English; keep CN names in aliases[] ONLY for dedup memory, NOT in output docs

- [ ] **Step 1: Write the prompt (~60 lines).**

- [ ] **Step 2: Run against 10 fixture forum posts and 5 fixture arXiv abstracts. Verify schema-valid output.**

- [ ] **Step 3: Iterate prompt until >=85% of fixtures produce schema-valid candidates without hallucinated citations.**

- [ ] **Step 4: Commit prompt + fixture outputs as golden.**

---

## Task 4: arxiv.py crawler

- [ ] **Step 1: Use `arxiv` library to search for `fractal` in classes `nlin.CD` (Chaotic Dynamics) and `math.DS` (Dynamical Systems).**

- [ ] **Step 2: Download PDFs to `research/raw/arxiv/{date}/{arxiv_id}.pdf`.**

- [ ] **Step 3: Each paper: call GROBID → get abstract + equations → call LLM extract against candidate schema.**

- [ ] **Step 4: Skip papers that are reviews/theoretical without a specific fractal proposed.**

- [ ] **Step 5: Smoke run: `forge crawl arxiv --limit 20` then `forge extract arxiv`. ~12-18 candidates expected (reject rate ~30% is healthy).**

- [ ] **Step 6: Commit.**

---

## Task 5: github_glsl.py crawler

- [ ] **Step 1: PyGithub search `topic:fractal stars:>10`. Limit to repos with `.glsl` or `.frag` files.**

- [ ] **Step 2: Clone shallow; find shader files; tree-sitter GLSL classify; LLM extract against README + shader comments.**

- [ ] **Step 3: License check: only admit candidates whose repo has a permissive license (MIT, Apache, BSD, CC-BY). Record in source.license field.**

- [ ] **Step 4: Smoke run.**

- [ ] **Step 5: Commit.**

---

## Task 6: fractal_forums.py crawler

- [ ] **Step 1: Scrape Fractal Forums archive pages (robots.txt permitting).**

- [ ] **Step 2: Per-post: if contains code block or formula, pass to LLM extract.**

- [ ] **Step 3: Many posts are noise (conversations, no new fractal). Expected reject rate 50%+.**

- [ ] **Step 4: Smoke run: 100 posts → 30-50 candidates.**

- [ ] **Step 5: Commit.**

---

## Task 7: cnki.py — Chinese-origin fractals (EN output)

Focus on harvesting the rare Chinese-originated fractals: Chen attractor 陈氏系统, Lü system 吕系统, Sprott-CNKI variants, 陈关荣-lineage papers.

- [ ] **Step 1: Seed with a hand-curated list of ~80 CNKI paper URLs known to propose new fractals.**

- [ ] **Step 2: Download PDFs (user may need to assist — CNKI requires institutional access for many).**

- [ ] **Step 3: GROBID + LLM with CN-EN translation prompt. Output: English name, English description, CN name in aliases only, no CN docs.**

- [ ] **Step 4: Expected yield: ~30-50 admitted Chinese-origin fractals. Quality > quantity here.**

- [ ] **Step 5: Commit.**

---

## Task 8: LLM cost discipline + budget guard

- [ ] **Step 1: `forge extract <source>` reads `config/llm.yaml.budget_usd_per_run` and halts if projected cost exceeds it.**

- [ ] **Step 2: Report per-run: candidates extracted, tokens used, approximate USD.**

- [ ] **Step 3: Commit.**

---

## Task 9: End-to-end Stage D smoke

- [ ] **Step 1: Run all 4 crawlers at modest limits.**

- [ ] **Step 2: Extract all via LLM (cached).**

- [ ] **Step 3: Batch → Review → Admit. ~200-400 new admissions expected.**

- [ ] **Step 4: Verify `forge doctor` green, registry size ~500+ entries.**

- [ ] **Step 5: Commit.**

---

## Done-Definition for Stage D

- [ ] 4 crawlers operational with fixture tests
- [ ] LLM extraction cached + budget-controlled
- [ ] GROBID integration tested
- [ ] 200+ new candidates admitted through Stage B
- [ ] Chinese-origin discovery produces EN-only output (no `.zh.md` files created)
- [ ] CI tests use mocked LLM responses (no live API calls in CI)

## Risks

| Risk | Mitigation |
|------|-----------|
| LLM cost overruns | Per-run budget guard; batch size 20 to amortize; cache aggressive |
| GROBID misparses equations | Fall back to raw text in LLM prompt; flag low-confidence candidates for human review |
| LLM hallucinates citations | Prompt explicitly forbids invented refs; post-check: validate every URL in output before admission |
| CNKI paywall | Seed with open-access papers only; user assists for institutional-access ones |
| Fractal Forums API/scrape terms | Respect robots.txt; rate limit 0.5 req/sec; attribute correctly in admitted entries |
