+++
schema = 1
id = "RUST-PLAN-02"
title = "Plan the next Rust migration batch from baseline and bridge evidence"
short = "Continue round 1 of 10 without losing the complete migration scope."
status = "done"
goal = "RUST-ENGINE-001"
section = "Next"
rank = 3000
depends_on = ["RUST-M0-CONTRACTS", "RUST-M0-REPLAY", "RUST-M0-IMAGES", "RUST-M1-WORKSPACE", "RUST-M1-BRIDGE"]
touches = ["docs/planning/refactor-plan.md", "docs/engineering/spec.md", "docs/engineering/test-plan.md"]
resources = []
kind = "plan"
ownership = "coordinator"
scope = "For RUST-ENGINE-001 read all five finished reports, actual source/fixtures/toolchain results and remaining M0/M1 platform proof. Reconcile the accepted complete outcome map, especially native Linux/Waydroid M1 qualification, sole-owner state migration, registry decimal/provenance parity and later Android/Linux texture proof. Save only the next evidence-backed batch with closed design choices and exact checks, retaining all phases through Web and final Dart retirement. Do not implement, redispatch or replace failed existing candidates; return continuation failures to same coordinator. If work remains and new building tasks exist, save one closing plan task marked Plan round: 2 of 10."
acceptance = ["Given merged first-round implementation evidence, saved plan/tasks explicitly mark M0/M1 proven or still pending, preserve every remaining requested outcome and record the next executable frontier with sources, touches, checks and true dependencies.", "Given the final saved next batch, readback and task validation succeed with no unintended drafts; only genuine external inputs remain scoped pending, and no implementation/publication occurs in planning."]
checks = ["autowork tasks show RUST-M0-CONTRACTS --worktree; autowork tasks show RUST-M0-REPLAY --worktree; autowork tasks show RUST-M0-IMAGES --worktree; autowork tasks show RUST-M1-WORKSPACE --worktree; autowork tasks show RUST-M1-BRIDGE --worktree; read actual reports and changed source, not status alone.", "autowork tasks validate --worktree .; read back all affected records and document links; after planning commit run autowork tasks why on the first new ready task."]
exclusions = ["No implementation, services, workers, installation, publication or acceptance waivers; task records are coordinator-owned through autowork tasks, not worker touches."]
closure = "manual"
closure_actor = "DOCS-MAINTAINER"
closure_timestamp = "2026-11-07T08:10:12.970874+00:00"
closure_reason = "Completed source-bound round 1 planning: saved missing native M1 checks and independent typed catalog parity with one round-2 successor; preserved all remaining gates and the unmet goal. Manual planning closure, not implementation qualification."
closure_evidence = "docs/tasks/RUST-PLAN-02.md"
+++
- Sources: docs/planning/refactor-plan.md#flutter-shell-and-rust-engine-migration
- Plan round: 1 of 10
- Consumes: all five first-round contracts, artifacts and actual finished reports; unresolved or failed checks remain failures. Shared resources for later platform tasks must reflect observed target ownership.
- Repo obligations triggered: spec.md Planned Rust engine boundary and test-plan.md Common offline gate/platform separation; preserve existing acceptance and task IDs. No generated outputs/production/CI/manifests in this planning task.
- Next action: inspect source-bound results, especially missing real native qualification; no repeat product interview. Move this card to Needs decision to stop the chain.
- Owner clarification (Grill With Docs round 1, accepted via LGTM): final Rust scope includes all mathematical domain algorithms, including Fourier/analysis, trajectories and exact/special visualizations; Flutter retains presentation/platform logic. Preserve the first five building contracts. Native demonstration targets 60 Hz on a defined hardware/scenario pair; 120 Hz is additional on compatible hardware, not universal. Carry this inventory and a predeclared hardware measurement protocol into later rounds. Waydroid functional evidence cannot certify physical GPU timing. See docs/adr/0005-rust-owns-all-mathematical-domain-logic.md, docs/adr/0006-native-demonstration-performance-is-target-specific.md and docs/engineering/GLOSSARY.md. ADR 0002 remains a prototype/oracle decision; no implementation or benchmark was performed by this clarification.
- Planning outcome: Completed Plan round: 1 of 10 in docs/tasks/RUST-PLAN-02.md. Read the five finished reports and current source; M0 offline baseline delivered, M1 installed Linux/Waydroid proof still pending. Saved RUST-M1-LINUX, RUST-M1-WAYDROID and RUST-M3-CATALOG-PARITY plus exactly one successor RUST-PLAN-03, Plan round: 2 of 10, depending on all three. Fresh read-only builder review found nothing important left. No implementation or goal qualification; first-round closures preserved.

## Later owner boundary (not covered by the historical closure)

The original round-1 contract and closure above remain historical evidence.
The later RUST-CORE-01 closeout is not established by that closure. Its bootstrap,
precision and aggregate tasks retain their own unmet acceptance criteria; the
latest owner boundary below governs further progression without undoing existing
work, receipts or task history.

- Sources: docs/planning/refactor-plan.md#rust-core-01-bootstrap-refinement
- Owner boundary update: stop at RUST-CORE-01; no automatic camera/registry/CPU/GPU successor. This is a scoped progression limit, not a blanket task hold or instruction to interrupt a worker. Reuse existing coordinator candidates/receipts; branch-local metadata is not runner delivery.
- Held by: OWNER-STOP-REVIEW

- Owner STOP / REVIEW: explicit latest instruction prohibits automatic next-milestone work after a green RUST-CORE-01. Retain OWNER-STOP-REVIEW until the owner reviews the aggregate evidence and gives later direction; neither green tests nor an empty eligible queue releases it.
