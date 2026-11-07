+++
schema = 1
id = "RUST-PLAN-02"
title = "Plan the next Rust migration batch from baseline and bridge evidence"
short = "Continue round 1 of 10 without losing the complete migration scope."
status = "open"
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
+++
- Sources: docs/planning/refactor-plan.md#flutter-shell-and-rust-engine-migration
- Plan round: 1 of 10
- Consumes: all five first-round contracts, artifacts and actual finished reports; unresolved or failed checks remain failures. Shared resources for later platform tasks must reflect observed target ownership.
- Repo obligations triggered: spec.md Planned Rust engine boundary and test-plan.md Common offline gate/platform separation; preserve existing acceptance and task IDs. No generated outputs/production/CI/manifests in this planning task.
- Next action: inspect source-bound results, especially missing real native qualification; no repeat product interview. Move this card to Needs decision to stop the chain.