+++
schema = 1
id = "ACAD-04"
title = "Backfill academic evidence across every scoped catalog identity in bounded batches.**"
short = "Backfill academic evidence across every scoped catalog identity in bounded batches.**"
status = "open"
goal = "ACAD-001"
section = "Next"
rank = 4000
depends_on = ["ACAD-03"]
touches = ["research/academic/", "TODO.md", "goals.json"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "After the pilot establishes the contract, progress family by family over the generated identity inventory, at most 25 unresolved identities per execution batch. Reuse reviewed family evidence only with effective-formula/parameter relationship checks. Preserve original namespaces and distinguish published identities, parameter variants, reference-only definitions and planned entries. Continue the same task/evidence ledger without inventing one task per paper or resetting consumed run budgets."
acceptance = ["Every scoped current ID is assessed or explicitly remains in the counted unresolved set; union totals reconcile exactly with no silent denominator shrink. Actual source availability, human approvals, formula comparison, numerical and visual evidence are separate. Batches retain reproducible manifests and exact continuation; source gaps/conflicts produce bounded correction/access items, not fabricated citations. Full task/goal completion requires all promised assessments, not merely creating coverage rows; a no-source result never becomes mathematically verified. Newly added modules enter the same inventory without rewriting historic snapshots."]
checks = ["Run the versioned ACAD-01 coverage validator against pinned source manifests and current catalog export; programmatically compare selected/processed/remaining IDs and evidence multiplicity for every batch; repeat import must be byte-stable. Run existing `forge doctor --strict-app-catalog`, manifest and visual inventory validators after attributable metadata changes. Live full-text/review checks require their actual decisions; all backfill is NOT_RUN."]
exclusions = []
+++

- Previous section: Needs decision.
- Sources: [Accepted academic research outcome](PRD.md#academic-research-library), [accepted integration contract](docs/engineering/spec.md#academic-source-to-renderer-evidence), [library rollout/coverage contract](research/academic/README.md), [verification owner](docs/engineering/test-plan.md#academic-evidence-verification), `docs/planning/visual-audit-inventory.json`, `research/fractals-library/data/fractal_manifest.json`.
- Prior ownership: Repository backlog, unassigned; preserve per-subset human review/access gates and existing quality task ownership. No timer, publication or blanket all-papers download.
- Prior next action: Wait for ACAD-03’s approved pilot and actual per-subset human decisions; preparation proceeds independently under ACAD-007-f8. Do not begin broad acquisition/backfill or treat a prepared metadata shortlist as approval.
- Prior owner decision: 2026-10-18 reconciliation of the existing deferral — defer this successor with ACAD-03 until its pilot and human source/acquisition/claim gates are satisfied. Acceptance remains unchanged; this is not completion or approval.
- Held by: EVIDENCE-GATE: qualified ACAD-03 pilot and per-subset human approvals
- Owner decision: 2026-10-25: Delegated by user to assistant. Adopt the existing rollout policy of at most 25 identities per batch with unchanged denominator and namespaces; proceed only after the qualified pilot and per-subset approvals. Decision resolved; remaining input: qualified ACAD-03 pilot and per-subset human approvals. See docs/tasks/DELEGATED-DECISIONS-20261025.md.
- Next action: Complete the authorized preparation separately; retain this hold until qualified ACAD-03 pilot and per-subset human approvals. Use supported release only after exact evidence exists; unchanged acceptance is not waived.
