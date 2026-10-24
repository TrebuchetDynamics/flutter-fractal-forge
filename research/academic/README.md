# Academic fractal research library — implementation plan

Status: Accepted; ACAD-01 offline index/import/coverage adapter implemented. Research acquisition and formula dossiers remain planned. This is the shared academic evidence home for Fractal Forge. The academic goal and task contracts live in [`../../tasks/`](../../tasks/), including the ACAD-007-f8 preparation and ACAD-03 human review gates; do not create a competing task queue here. No live search, PDF acquisition, shader rewrite, publication or recurring job is part of ACAD-01.

## Outcome and current evidence

Every catalog identity should be traceable through **source → exact mathematics → effective implementation → numerical check → rendered/exported evidence**, with honest gaps at each stage. Finding a title or compiling a shader proves neither the source claim nor mathematical fidelity. Aim for relevant authoritative evidence across all existing families, not an impossible promise to collect every article ever written about fractals.

Inspection baseline: `docs/catalog/fractal_registry.yaml` has 1,619 unique rows; 376 have `implemented: true`, and only 6 of those have nonempty `references`. Those fields can contain demo/code URLs; they are not 6 academically certified formulas. The separate live Explore inventory and 200-item `research/fractals-library/data/fractal_manifest.json` have different scopes. Never use the registry's implemented flag as the live catalog denominator. Existing `research/` contains 37 tracked provenance.json files, 24 manifest.json files and no tracked PDFs; this does not prove there are no ignored/private PDFs. Several inspected research reports explicitly use metadata/abstracts only. The strict app catalog doctor passes 1,619 registry rows, 0 errors and 0 warnings, but checks structural/admission invariants, not equation-to-shader correctness.

## Tool decision

**Planner call: ResearchForge is the primary collection/provenance tool.** Its research-directory workflow retains queries, normalized/deduplicated records, failures and checkpoints; its project workflow adds attributable review gates.[2] Installed executable: `/home/xel/.local/bin/rforge`, observed version `v0.1.20-2-g679bc9d (679bc9d, 2026-09-04T04:02:51Z)`. This identifies the inspected installation, not a version pin for future runs. Record the actual executable/version/help fingerprint each run.

**Planner call: Feynman is optional analysis assistance, not a second authoritative library.** The likely project meant by “fine man” is Companion-Inc/Feynman. Its published workflows include literature review, deep research, citation verification and paper/public-code audit.[1] Its generated statements remain proposed notes until checked against the actual cited source and our effective renderer. No installation, provider credentials, paid inference, replication or automatic experiments are authorized by this plan. The first useful delivery must work without Feynman. Reuse approved existing outputs or import a later explicitly authorized run; preserve prompt, model/tool versions, source list and verification results.

`rforge` is NOT `python3 scripts/research/forge.py`: the former discovers literature; the latter is this app's existing catalog review/admission/emission tool. Neither an rforge record nor a Feynman summary may automatically call app `admit`, generate modules, promote formulas or set review confidence.

Verified compatibility caveats: this installed binary returns text for `rforge help --json`; use **`rforge --json help`** for its machine-readable catalog. The newer local ResearchForge source checkout is not the installed build, so source-level PaperRecord/provenance schemas and newer synthesis commands need fixture/runtime compatibility checks before use. Feynman is not present on the inspected PATH; its documentation describes persisted auth/session/workbench state and usage telemetry.[3][4] Any future adoption must separately verify a coherent pinned release, disable unwanted telemetry and obtain approval for provider cost and document disclosure; telemetry opt-out alone does not make model/search calls local.

## Proposed folder ownership

```text
research/academic/
  README.md                  this plan and operational entry point
  papers.jsonl               shared deduplicated source identities, aliases and rights
  families/<family>.md       readable synthesis, disagreements and search gaps
  mappings/<group-id>.json   paper/equation ↔ effective formula ↔ module IDs
  coverage.json              generated union coverage with explicit source scopes
  runs/<run-id>/             immutable ResearchForge/native tool output packages
  reviews/<review-id>.json   attributable human decisions and source-span verification
  pdfs/<paper-id>/<hash>.pdf approved legal copies; ignored from Git by default
  text/<paper-id>/<hash>.txt extracted text/OCR; same rights/privacy restrictions
```

Keep existing `research/<topic>/` packages and `research/fractals-library/` in place. Import by stable identifier plus provenance back-links; no mass move, deletion or rewrite of historical reports. `papers.jsonl` is the canonical shared metadata index; run results remain immutable input snapshots, not rival editable bibliographies. Coverage and title-collision review suggestions are generated, not manually curated second indexes. No new hosted service, vector database, UI framework or dependency is required for the first slice. A future Obsidian/wiki view can be derived, not another source of truth.

## Offline schema/import/coverage adapter (ACAD-01)

Version 1 schemas live beside the data: `papers.schema.json`, `mapping.schema.json`, `coverage.schema.json`, and `identity-aliases.schema.json`. `papers.jsonl` is deterministically imported from existing `research/**/results*.jsonl` records by `forge academic-check`; those original run packages are never edited. DOI aliases normalize case and DOI URLs; arXiv aliases discard version suffixes. Records with DOI deduplicate only against the same DOI; arXiv-only records deduplicate against arXiv-only records. DOI/published and arXiv/preprint records remain separately traceable rather than being implicitly merged. Title-only matches are preserved as separate records and emitted in `identity-review.json` for human review.

`identity-aliases.json` is the only input for reviewed identity-to-paper mappings; do not map by title or name similarity. `coverage.json` is generated from the app Explore IDs in the visual-audit inventory, all registry IDs, all reference-manifest IDs and the accepted planned `core.number_wall` identity. Unmapped identities are explicit `gap` rows. The metadata/content and source/implementation/numerical claim states stay distinct. The offline validator checks source references, claim spans, content rights, source hashes, implementation hash bindings and public file restrictions.

Run the scoped offline adapter (it rewrites only generated academic outputs):

```sh
PYTHONDONTWRITEBYTECODE=1 python3 scripts/research/forge.py academic-check
```

### Source record

Use stable `paper_id`, DOI/arXiv/ISBN/canonical URL aliases, title, authors, year, publication/preprint version, source kind, retrieval date, license/rights, source URLs, referring run/path and content hash where content was actually acquired. Link preprint and published versions without silently merging changed equations; preserve DOI/arXiv provenance. Exact DOI normalization and title-collision review are explicit. Title-only matches remain uncertain, never automatic merges. One paper can support many modules; do not duplicate its PDF per fractal. A book or authoritative mathematical reference is valid evidence where appropriate; demo/code/video links are labeled supplementary, not relabeled as papers. Retractions/corrections and conflicting definitions remain visible.

Separate discoverability, screening, content availability, extraction review and implementation qualification. Minimal source states: `discovered`, `screening_pending`, `included`, `excluded`, `uncertain`; content states: `metadata_only`, `access_pending`, `full_text_available`, `unavailable`; claim states: `unreviewed`, `source_checked`, `implementation_compared`, `numerically_checked`, `contradicted`. Each state transition needs its actual actor/decision/evidence. Missing approval or unavailable text is not exclusion and not a passing review.

### Formula-to-implementation dossier

A mapping names exact source IDs/versions and page/section/equation spans; reviewed mathematical statement; recurrence/transform/rule/ODE; algebra, domain, initialization, parameters, termination/bailout, coordinate convention and numerical method. Record the effective Dart parameter defaults/clamps and shader rounding/bindings, not only names/comments. Bind builder/shader/CPU implementation paths plus content hashes, tested parameter range, independent oracle/fixture and observed result. Record rendering approximations, unsupported parameter regions and fidelity separately from visual quality.

Reuse stable module/catalog IDs and the existing `FractalMathematics` reviewed family/group relationships, but corroborate group inheritance in source. A shared shader, palette, name or formula_hash does not independently establish equivalent mathematics. Keep GPU compile, image health, source review and numerical validation as distinct axes. Unsupported/inspired entries remain available with honest qualifications; this plan does not silently remove them or waive their existing gates.

## Acquisition and review workflow

1. **Account for all identities first.** Derive a coverage union from the current app-facing catalog/ModuleRegistry export, registry YAML, 200-definition manifest and accepted planned IDs. Preserve each namespace and scope; reconcile aliases/variants by reviewed group. Record unmapped/reference-only/diagnostic/planned distinctions and input hashes. Every existing ID gets a coverage row before claiming “all fractals covered”; a row with a gap is not a researched/certified formula.
2. **Reuse and screen legacy evidence.** Index existing manifests, JSONL, reports and equation notes, keeping metadata-only and failed retrievals explicit. Deduplicate by stable identifiers; quarantine unresolved identities and unsupported historical completion claims rather than silently upgrade them.
3. **Retrieve in bounded family batches with ResearchForge.** Prefer mathematics/graphics-relevant OpenAlex, arXiv and Crossref, with Semantic Scholar when available. Record exact query variants, provider/version, filters, limit, seed references, citation expansions, raw outputs, failures and observed counts. Retry failed work by native checkpoints; unchanged imports are byte-stable. Start with a 20-query pilot distributed across six mathematical families, capped at 25 records per query/source; these are planner workload limits, not claims of exhaustive retrieval. Broaden only for demonstrated gaps. Don't use citation count as correctness or create relevance from an LLM summary.
4. **Honor human gates before deep acquisition.** ResearchForge's documented policy retains human approval for inclusion/exclusion, full-text acquisition, accepted extraction, final claims and review export.[2] Queue decisions; never have an autonomous researcher sign as the owner or use web tools to bypass the same gate. Explicitly authorized legal OA subsets can proceed; paywalls, access-denied sources and unknown rights remain missing-input records. This planning request does not supply those approvals.
   **Do not assume standalone `oa fetch` enforces that policy.** The inspected local `internal/cli/source_commands.go:768–863` reads every record in the target `results.jsonl` without consulting screening decisions and can return exit zero despite individual download failures. This is source-level evidence, not a runtime acquisition test of the installed binary. Use an acquisition-only staging directory whose `results.jsonl` contains exactly the explicitly approved source IDs; retain the decision IDs, originating run and input digest, and assert that the selected-ID set equals the approved set before invoking any fetch. Never run it against the whole discovery corpus. Read `fetch-report.txt`, `fetch-failures.jsonl`, actual files and hashes afterward; classify absent OA and download failure separately. The immutable discovery run remains untouched.
5. **Read the supporting source, not just the abstract.** Store only legally permitted content, with license/access URL, retrieval time, version and SHA256. Missing PDFs may use an approved author manuscript, authoritative HTML or library/book access; record the actual medium. OCR/extraction failures and equations missing from extracted text are review gaps. Do not vendor publisher PDFs or unrestricted abstract/raw-response dumps into a public Git repository merely because a URL is reachable; local ignored copies and redistributable metadata/brief lawful excerpts have separate policies. No bulk copyrighted download, paywall bypass, secrets or private session paths in public corpus records.
6. **Extract and verify mathematics.** Draft notes can use Feynman or Hermes, but each load-bearing equation/claim requires the actual source span and a reviewer. Compare source definitions with both Dart uniform bindings and implemented GPU/CPU algorithms. Add reference numerical tests before proposing a repair. Contradictions produce bounded correction tasks under existing IDs, not direct shader rewrites from research output.
7. **Publish a scoped evidence report, not a blanket certificate.** Separate source discovery coverage, accessible/read/reviewed full text, implementation matches, contradictions, numerical checks, unqualified renders and unresolved access. A complete inventory or green schema check cannot be reported as all mathematics verified. Reuse CAT-QUALITY-01's selected pilot/evidence when available; this plan does not duplicate its visual task.

Installed-command baseline (run only during separately authorized execution; inspect current help before using flags):

```sh
rforge version
rforge search batch --out research/academic/runs/RUN_ID --queries QUERIES_FILE --sources openalex,arxiv,crossref --limit 25 --continue-on-error --stats
rforge search stats --dir research/academic/runs/RUN_ID
rforge screen queue --dir research/academic/runs/RUN_ID --out REVIEW_QUEUE.csv
# Stop for actual inclusion/acquisition approval before any oa fetch.
```

`RUN_ID`, `QUERIES_FILE` and `REVIEW_QUEUE.csv` are explicit planned execution values, not paths that already exist. Native manifests/failures preserve actual outcomes. `rforge citations build` may cover only acquired-PDF records in the inspected version: do not use its bibliography count as complete metadata-library coverage. Newer source README/skill commands are not assumed installed; an unsupported optional synthesis command falls back to file-based reviewed notes, not fabricated output. No install/update of ResearchForge/Feynman or changes to another repository/profile are part of this plan.

## Bounded rollout and acceptance

- **ACAD-01:** offline library schema/import/coverage and validators, preserving old packages.
- **ACAD-02:** actual ResearchForge metadata pilot, gap report and human review queue; no unapproved full text.
- **ACAD-03:** owner-gated source-to-formula pilot with reviewed source spans and exact implementation comparisons.
- **ACAD-04:** family-by-family backfill across the full identity inventory after the pilot, with bounded continuation and explicit unresolved gaps.
- **ACAD-05:** connect reviewed evidence to existing catalog metadata/math descriptions and new-admission checks, without turning source discovery into automatic mathematical approval.

Planner pilot: use CAT-QUALITY-01's existing diverse selection when available; otherwise select at most 12 real IDs covering complex dynamics, root finding, IFS/geometric, attractors, 3D/hypercomplex and discrete/number-theoretic systems. Include Number Walls as a separate accepted-planned dossier, not a currently implemented renderer. Do not choose additional duplicate presets just to fill a count.

Done means the library is usable and reproducible; all current identities are accounted for; the pilot's source-backed claims can be traced and tested; later batches continue without duplicate papers or invented passes. Full-catalog review remains open until every required assessment is actually made. Source absence can be an honest terminal search outcome but never a mathematically verified result. No article-count target substitutes for research quality.

Verify offline imports and invalid/duplicate/retracted/mismatched/source-missing fixtures, idempotent retry/import, formula-sign/domain/parameter-clamp mismatches, binding freshness, namespace coverage, rights boundaries and unchanged source/package preservation. Keep existing `forge doctor --strict-app-catalog`, manifest and visual inventory guards; add an academic evidence validator, not a replacement registry. Existing app-visible data remains compatible. Live/provider-backed retrieval, legal content approval, reviewed extraction, numerical execution, app display and release/device acceptance are separate results.

## Sources

[1] https://github.com/Companion-Inc/feynman
[2] https://github.com/TrebuchetDynamics/research-forge
[3] https://raw.githubusercontent.com/Companion-Inc/feynman/main/README.md
[4] https://www.feynman.is/docs/getting-started/configuration

## Decision-ready owner package

The raw ACAD-02 pilot queue remains discovery evidence, not an approval brief. The bounded metadata-only preparation package is [`reviews/ACAD-02-pilot-approval.md`](reviews/ACAD-02-pilot-approval.md) with machine-readable companion [`reviews/ACAD-02-pilot-approval.json`](reviews/ACAD-02-pilot-approval.json). It reuses the existing CAT-QUALITY-01 12-identity pilot, binds six selected records to retained ACAD-02 result rows, and distinguishes proposed-unreviewed identity mappings from six explicit gaps. The empty reviewed-alias file and original run/queues are preserved; all screening, identity approval, acquisition and claim decisions remain pending. Bibliographic/rights metadata checks do not verify equations, grant reuse permission, or authorize content acquisition.

Validate membership, mapping status, decision fields and original-input hashes offline with `python3 -m scripts.research.academic.review_package --repo-root .`; focused regression coverage is in `test/research/test_academic_review_package.py`. The original pilot/run/queue and reviewed-alias files remain byte-hash-bound. The live inventory check fingerprints the complete pilot section and selected identity rows only, excluding unrelated catalog additions and totals; historical full-inventory receipts are retained in the companion. ACAD-03 remains human-gated after this preparation.
