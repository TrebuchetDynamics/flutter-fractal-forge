+++
schema = 1
id = "RUST-PLAN-02"
title = "Plan the next Rust migration batch from baseline and bridge evidence"
short = "Continue round 1 of 10 without losing the complete migration scope."
status = "open"
goal = "RUST-ENGINE-001"
section = "Next"
rank = 3000
depends_on = ["RUST-M0-CONTRACTS", "RUST-M0-REPLAY", "RUST-M0-IMAGES", "RUST-M1-WORKSPACE", "RUST-CORE-BOOTSTRAP", "RUST-CORE-PRECISION", "RUST-CORE-01"]
touches = ["docs/planning/refactor-plan.md", "docs/engineering/spec.md", "docs/engineering/test-plan.md"]
resources = []
kind = "plan"
ownership = "coordinator"
scope = "For RUST-ENGINE-001 read source-bound baseline/workspace/bridge/precision and RUST-CORE-01 aggregate results. Close out only the owner's two-crate/precision-first bootstrap, exact pins, snapshots/revisions and unchanged Flutter renderer; preserve all remaining roadmap obligations and unchecked evidence. Return existing execution/transport/integration failures to the same coordinator without replacement tasks/interviews. Explicit owner boundary: create no camera/registry/CPU/wgpu task or automatic next-round batch under this request. Save completion/gaps and stop; later progression requires later direction. Preserve historical Plan round1of10 and add no successor."
acceptance = ["Given actual constituent reports/source, saved closeout distinguishes completed offline bootstrap from pending platform proof and accounts for every RUST-CORE-01 criterion without status-only closure or evidence repinning.", "Given final readback/task validation, no beyond-milestone task, implementation, worker or publication is created; existing independent baseline work and admitted workspace contract remain unchanged."]
checks = ["autowork tasks show RUST-M0-CONTRACTS --worktree; autowork tasks show RUST-M0-REPLAY --worktree; autowork tasks show RUST-M0-IMAGES --worktree; autowork tasks show RUST-M1-WORKSPACE --worktree; autowork tasks show RUST-M1-BRIDGE --worktree; read actual reports and changed source, not status alone.", "autowork tasks validate --worktree .; read back all affected records and document links; after planning commit run autowork tasks why on the first new ready task."]
exclusions = ["No implementation, services, workers, installation, publication or acceptance waivers; task records are coordinator-owned through autowork tasks, not worker touches."]
+++
- Sources: docs/planning/refactor-plan.md#flutter-shell-and-rust-engine-migration
- Plan round: 1 of 10
- Consumes: all five first-round contracts, artifacts and actual finished reports; unresolved or failed checks remain failures. Shared resources for later platform tasks must reflect observed target ownership.
- Repo obligations triggered: spec.md Planned Rust engine boundary and test-plan.md Common offline gate/platform separation; preserve existing acceptance and task IDs. No generated outputs/production/CI/manifests in this planning task.
- Next action: inspect source-bound results, especially missing real native qualification; no repeat product interview. Move this card to Needs decision to stop the chain.
- Owner clarification (Grill With Docs round 1, accepted via LGTM): final Rust scope includes all mathematical domain algorithms, including Fourier/analysis, trajectories and exact/special visualizations; Flutter retains presentation/platform logic. Preserve the first five building contracts. Native demonstration targets 60 Hz on a defined hardware/scenario pair; 120 Hz is additional on compatible hardware, not universal. Carry this inventory and a predeclared hardware measurement protocol into later rounds. Waydroid functional evidence cannot certify physical GPU timing. See docs/adr/0005-rust-owns-all-mathematical-domain-logic.md, docs/adr/0006-native-demonstration-performance-is-target-specific.md and docs/engineering/GLOSSARY.md. ADR 0002 remains a prototype/oracle decision; no implementation or benchmark was performed by this clarification.

- Sources: docs/planning/refactor-plan.md#rust-core-01-bootstrap-refinement
- Owner boundary update: stop at RUST-CORE-01; no automatic camera/registry/CPU/GPU successor. This is a scoped progression limit, not a blanket task hold or instruction to interrupt a worker. Reuse existing coordinator candidates/receipts; branch-local metadata is not runner delivery.
- Held by: OWNER-STOP-REVIEW

- Owner STOP / REVIEW: explicit latest instruction prohibits automatic next-milestone work after a green RUST-CORE-01. Retain OWNER-STOP-REVIEW until the owner reviews the aggregate evidence and gives later direction; neither green tests nor an empty eligible queue releases it.
