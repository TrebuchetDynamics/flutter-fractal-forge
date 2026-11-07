# Rust M2 Session overlap review

## Evidence boundary

Reviewed at `b0fc5ba06271db736e62dacf28fa7350d9ac0211` on 2026-11-07.
This is a contract/admission review, not implementation or qualification.

Read both task records, their Sources and the accepted
[migration](../planning/refactor-plan.md#flutter-shell-and-rust-engine-migration)
and [round-7 plan](RUST-PLAN-08.md), including its saved-batch admission policy.
Standing AGENTS.md autonomy/authorization boundaries and the historical
[delegated decisions](DELEGATED-DECISIONS-20261025.md) remain unchanged.

- [RUST-M2-TRAJECTORY-JOBS](../../tasks/items/RUST-M2-TRAJECTORY-JOBS.md)
  consumes RUST-M2-TRAJECTORY-STATE. The accepted
  [trajectory contract](RUST-PLAN-08.md#trajectory-jobs-and-shared-cache)
  adds Session-owned request/generation state, checked publication and cancellation
  hooks. `rust/crates/fractal-core/src/session.rs` owns Session, Snapshot and
  atomic apply_batch publication; its declaration is justified, not incidental.
- [RUST-M2-U64-FIXTURE](../../tasks/items/RUST-M2-U64-FIXTURE.md)
  consumes RUST-M2-BRIDGE and RUST-M2-ASYNC-STEP. The accepted
  [fixture contract](RUST-PLAN-08.md#fixed-successful-high-u64-producer)
  requires a debug-only core snapshot helper that clones validated data and changes
  only two fixed counters. Snapshot's counters are private in `session.rs`;
  declaring that file plus the new helper module is justified. The contract
  explicitly keeps this producer independent of trajectory transport.
- [RUST-M2-PARAM-TIMELINE](../../tasks/items/RUST-M2-PARAM-TIMELINE.md)
  consumes interpolation and Session, not either waiting task. Its accepted
  [timeline contract](RUST-PLAN-08.md#ordered-parameter-timeline) separately
  changes the same transactional owner. Neither waiting task consumes its output.

## Worker and scheduler evidence

Execution records were inspected in place under the absolute Git common directory's
`autowork-execution/`; no reports, patches or runtime files were copied or edited.
Neither waiting task had a slot-data directory or worker report. The timeline's
slot recorded attempt 1 as running, based on the reviewed revision; its matching
worker process PID 3682585 was live. No final report existed at inspection.
The running task's entry and worktree were left untouched.

The supplied release `8ba668ef4d239cb73e252a39e55a53d004c6a1ce` implements
admission in `Src/pi_autowork/engine/parallel_plan.py` (`_files`, `plan`,
`conflict`). Its source is byte-identical to the live worker release
`eb5d551e2c6f9ab282a8691f8695a98d96318b3e` at inspection.
Literal non-test files named by at least three unfinished contracts are hot,
including noncandidates and unlanded slots. Held peers alone reserve no files;
resource/protected-path admission and real prerequisites remain separate.

Four open records name `rust/crates/fractal-core/src/session.rs`: the two waiting
tasks, the running timeline and RUST-M2-RANDOM-STATE in Next. Thus the literal
production file is hot. A read-only invocation of the supplied pure planner over
current contracts, with the timeline as running, reproduced both reported waits
exactly. `tasks why` independently reports both waiting tasks graph-eligible and
explicitly does not evaluate runtime admission. These results are consistent.

## Disposition and verification

Keep both task records unchanged: no new Dependencies, narrowed Touches, split,
merge, reranking, closure or acceptance change is justified. The round-7 plan
already separates independently testable components and explicitly declares shared
writes rather than adding false prerequisite edges. No saved ledger proposal was
supplied for these tasks; `tasks handoff .` reported a clean lifecycle and empty
diff. No patch was applied and no goal status or runtime state was changed.

`tasks validate --worktree .` passed with 163 tasks, 21 goals, no drafts or pending
records. The scheduler reproduction passed for both exact wait reasons. Local
links/anchors and whitespace were checked. No Flutter/Rust suite or live operation
was run for this documentation-only review.

Recompute admission after the timeline lands. Landing removes that live file
reservation, not any real dependency, resource/protected-path gate or remaining
implementation/live proof requirement. No new owner decision is needed.
