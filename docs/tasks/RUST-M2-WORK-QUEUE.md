# RUST-M2-WORK-QUEUE — Pure bounded work policy

## Implemented boundary

[`work_queue`](../../rust/crates/fractal-core/src/work_queue.rs) adds a Rust-local
policy, not an executor. It follows the
[bounded-admission plan](RUST-PLAN-09.md#bounded-admission-and-fair-execution)
and the [planned engine boundary](../engineering/spec.md#planned-rust-engine-boundary).
The proposed internal capacity is **8 total admitted jobs**, including a job
selected for stepping. This is not a worker-thread count or a measured capacity.
There is at most one Number Wall and one trajectory entry per Session ID.

`WorkKey` captures Session ID, request kind and generation. The consumer must use
its existing Session identity and a monotonically increasing request generation.
The policy does not allocate Session identities or own Session state.

- `try_admit` returns a non-cloneable `Permit`, `Busy` at capacity, or
  `AlreadyAdmitted` for an occupied Session/kind. Rejection changes no state and
  creates no waiter, retry list, deduplication entry or mathematical job.
- `replace` validates the exact existing permit, matching Session/kind and a
  strictly newer generation. It reserves a checked ticket before revoking the
  old guard and swapping entries atomically, including at full capacity.
  Ticket exhaustion returns `TicketOverflow` without mutation.
- `next_turn` rotates Sessions, then alternates available kinds within each
  Session. With S continuously runnable Sessions, each receives a selection
  within S selections. A selection neither runs work nor releases capacity.
- `finish` and `revoke` remove the exact entry and revoke its shared guard.
  Foreign permits and stale/double releases fail explicitly. Old selections
  cannot match a replacement, including across independent queues.
- Permit drop (including panic unwind outside the policy lock) releases only its
  own entry. `close(session_id)` revokes that Session's entries. Outstanding
  permits then become stale; dropping them cannot release another entry.

## WORK-BRIDGE consumer obligations

Reuse `RequestKind`, `RequestGuard` and the existing Session bounded jobs.
Pass the permit guard into the corresponding Session begin request. Keep the
permit alive while queued **and** while stepping. On completion, error,
cancellation or stale Session work, call finish/revoke or drop the permit.
Revoking a cloned guard alone does not remove the entry: the consumer must also
release its permit. Close the policy entries when closing a Session.

Use one serialized chunk consumer. Check that a selected `Turn` still matches
its permit before use; Session token/generation checks remain authoritative at
publication. Execute at most one existing bounded wall advance or one trajectory
advance (at most 256 RK4 steps) per turn. Never hold the queue lock during math or
Session mutex acquisition. Queue operations themselves perform no integration,
prime certification, frame construction or drain loop.

The bridge must submit only after admission, to the **existing FRB pool**. It
still owns the single-pump flag, lost-wake protection, panic boundary, ticket
status and Session/token coordination. None of those executor mechanisms is
implemented here. There is no new runtime, dependency, thread, cache policy,
bridge route, app flag or fixture change. The old diagnostic bridge paths are
not bounded by this module. No latency, throughput, native admission, browser,
hardware or full-M2 qualification follows from these tests.

## Offline verification

[`work_queue` tests](../../rust/crates/fractal-core/tests/work_queue.rs) cover
capacity+1, selected-work accounting, atomic replacement, unchanged rejection
order, foreign/stale identities, exact terminal/close/drop/unwind release, and
real wall/trajectory chunk rotation across three Sessions. A private unit case
checks ticket exhaustion without billions of admissions.

Reuse the existing Session trajectory/Number Wall/replay tests for mathematical
errors, revision overflow, supersession, retained last-good frames and isolation;
do not duplicate their fixtures or numerical assertions in the policy tests.

Passed locally with Rust 1.95.0 and Flutter 3.47.9/Dart 3.13.7:

- `cargo test --manifest-path rust/Cargo.toml -p fractal-core --test work_queue --test session_trajectory_jobs --test session_number_wall --test session_replay --locked --offline`
- `scripts/ci/rust-check.sh` (workspace fmt, warning-denying clippy, tests)
- `flutter test --no-pub test/modules/attractor_trajectory_model_test.dart test/number_walls/number_wall_state_test.dart` (15 tests)

The coordinator's merged-tree gate remains separate from these focused checks.
