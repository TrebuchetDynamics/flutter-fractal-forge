+++
schema = 1
id = "CAT-QUALITY-03"
title = "Decide curated discovery with the complete catalog still accessible.**"
short = "Decide curated discovery with the complete catalog still accessible.**"
status = "superseded"
goal = "CAT-QUALITY-001"
section = "Needs decision"
rank = 20000
depends_on = ["CAT-QUALITY-02"]
touches = ["**"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Proposed: small curated collection using existing cards/filters and source-reviewed family/group metadata; full catalog/search/favorites remain accessible. Record adopt/revise/defer before product UI work. No destructive deduplication, renaming, certification badge or remote ranking service."
acceptance = ["Owner records the discovery/promotion decision. If adopted, bind exact representative IDs and honest qualifications to pilot evidence, preserve full supported ID availability and state, EN/ES, keyboard/screen-reader access and restored search/filter behavior. Proposed layout is not counted as implemented."]
checks = ["Decision record plus planned catalog search/math-navigation/a11y/ID regression and named 320px/768px layouts at text scale 2; these checks are NOT_RUN until an approved UI change is implemented."]
exclusions = []
+++

- Sources: [Quality plan](docs/planning/visual-fidelity-audit-next.md#quality-without-losing-variety), [accepted outcome](PRD.md#catalog-quality-and-variety), `docs/planning/visual-audit-inventory.json`, `lib/features/catalog/data/catalog_repository.dart`, `lib/core/modules/fractal_mathematics.dart`.
- Graph evidence: Fresh partial 38-file code-only Graphify scan: CatalogRepository (`catalog_repository.dart:15,20,57`), CatalogEntry (`catalog_entry.dart:12,30`), FractalMathematics (`fractal_mathematics.dart:11,45`) and LaunchVisualMetrics (`launch_visual_metrics.dart:9`). Extracted nodes are source-corroborated; five self-loops/duplicate-label warnings and truncated queries remain. Shaders/viewer/export/docs semantics are not indexed. See the quality plan for queries and receipt path.
- Prior ownership: Product owner decision; proposed UI remains Needs decision. No implementation or schedule is authorized.
- Prior owner decision: 2026-10-16 — Keep curated discovery undecided until the quality pilot provides concrete examples. Retain Needs decision, CAT-QUALITY-02 dependency and current complete-catalog access; no curated UI implementation is accepted by this answer.
- Prior next action: Bring concrete pilot results and representative catalog examples before requesting the adopt/revise/defer decision.
- Touches: none before conversion; ** stands for the whole repository
- Owner decision: 2026-10-25: Delegated by user to assistant. Do not adopt curated discovery in this roadmap. Preserve complete catalog, search, favorites, IDs and state; no new collection, ranking, badge, renaming or deduplication. Superseded proposal, not implementation. See docs/tasks/DELEGATED-DECISIONS-20261025.md.
- Superseded by: QUAL-EVIDENCE-01; Do not adopt curated discovery in this roadmap. Preserve complete catalog, search, favorites, IDs and state; no new collection, ranking, badge, renaming or deduplication. Superseded proposal, not implementation.
