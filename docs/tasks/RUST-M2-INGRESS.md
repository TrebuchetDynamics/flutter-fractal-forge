# RUST-M2-INGRESS — Inert Number Walls request ownership

## Result and boundary

The inert Rust [Session](../../rust/crates/fractal-core/src/session.rs) now owns
staged Number Walls ingress alongside its existing scalar/effect transactions.
The [request implementation](../../rust/crates/fractal-core/src/session_number_wall.rs)
uses the existing certified [frame job](../../rust/crates/fractal-core/src/number_wall_frame.rs),
not a second validator or replay-supplied certificate. All **68 original stored
state-replay inputs and expected outputs**, events 0–67, compare exactly twice.
This is core parity, **not an app owner switch or full M2 qualification**.

The accepted [frame/session design](RUST-PLAN-05.md#frame-and-session-ownership),
[planned Rust boundary](../engineering/spec.md#planned-rust-engine-boundary) and
[Number Walls ingress boundary](../engineering/spec.md#number-walls-replay-validation-boundary)
are unchanged. Dart controller, app routes, baseline envelopes, generated bridge,
locks, dependencies and persistence schemas are unchanged. The existing
[bridge](../../rust/crates/fractal-bridge/src/api.rs) remains synchronous:
it does not drain frame jobs while holding its mutex.

## Rust-local API

Every operation below validates `session_id` and `expected_revision` first.
Wrong identity and stale revision return typed errors without changing live or
pending state. There is no identity setter, foreign callback or platform executor.

| API | Result and publication |
| --- | --- |
| `begin_number_wall(id, revision, &command, guard, max_trial_divisions)` | `Result<Option<RequestToken>, SessionError>`; deferred ingress stages the complete target and publishes a pending token, not mathematical work. An inactive guard does nothing. An immediate command uses the ordinary batch seam and returns `None`. |
| `advance_number_wall(id, revision, token, work_limit)` | `Result<RequestProgress, SessionError>`; one bounded frame step returns `Pending` or `Finished(status)`. Zero work checks revocation only. Old tokens return `Finished(Cancelled)` without publication. |
| `cancel_number_wall(id, revision, token)` | Cancels only the current matching token. Old tokens cannot clear a successor. Repeated cancellation publishes nothing. |
| `RequestGuard::new(active)`, `revoke()`, `is_active()` | Rust-owned monotonic atomic revocation, shared with that request. Revocation is checked during work and again at publication; no Dart callback is invoked. |
| `Snapshot::number_wall_pending()` | Detached `Option<RequestToken>` metadata, not a mutable job handle. |
| `Snapshot::number_wall_status()` | Optional exact terminal status: verified prime, composite, invalid, unverified or cancelled. Begin clears it. |
| `Snapshot::number_wall_frame()` | Optional immutable `Arc<NumberWallFrame>`; retained across ordinary navigation, independently of active module and status. |

Tokens have private fields and use the accepted begin revision as their monotonic
session-local identity. A token is a one-shot request, not a persistent result
cache. Use a separate guard for each independently owned request. Snapshot clones
cannot mutate the session, other sessions, certified settings or grid storage.
Constructing a session does not run jobs: Number Walls defaults without a frame
are not certified; explicitly begin/drive ingress before consuming a frame.

Supported deferred ingress is `Load`, Number Walls `ApplyPreset`, Number Walls
`SelectModule`, `NumberWallPrime`, mathematical/non-prime edits without reusable
style storage, and Number Walls parameter/session resets. Synchronous
`apply_batch` returns **`SessionError::DeferredOperation`** for these commands,
including mixed batches, atomically. Callers explicitly begin and advance work;
the core does not add an async runtime or silently make batch execution unbounded.

## Source behavior and transactions

The ports follow [FractalController](../../lib/core/controllers/fractal_controller.dart)
and its [Number Walls state tests](../../test/number_walls/number_wall_state_test.dart):

- Successful current work publishes certified frame, settings, module, view and
  transparency together. Rejected prime/grid candidates retain committed state,
  including hidden forced-kaleidoscope restoration state.
- A newer begin supersedes old work. Navigation, resets, ordinary parameter edits,
  camera/rotation edits and changed visual effects cancel pending work. Normalized
  effect/transparency no-ops and unknown parameters do not cancel it.
- Non-prime mathematical edits merge the latest owned candidate but use the
  committed prime. Row edits raise `columnStart` to at least `rows - 1`.
  Prime edits merge that same latest candidate without trusting serialized flags.
- Style edits with a frame cancel pending work and reuse the certified grid.
  The only frame helper added is a crate-private whitelist-based `restyle`;
  it cannot change a mathematical field or supply a new proof. The existing effect
  owner/copy-on-write transaction logic is reused without refactoring it.
- Selecting Number Walls from another module with no overrides exposes defaults
  immediately with no frame while pending. With overrides, the previous module
  stays committed until validation succeeds. Same-module selection preserves the
  current view unless reset was requested. Ordinary navigation retains the last
  wall frame but clears status, as in Dart.

Each accepted nonempty batch increments revision once, including no-ops. Begin
increments once; current standalone terminal completion/cancellation increments
once. Pending steps and stale completions increment nothing. Cancellation by an
accepted edit shares that edit's batch publication. Begin reserves `checked_add(2)`
capacity; pending-preserving batches reserve one terminal revision beyond their
proposed revision. A cancelling edit may consume the final revision. No pending
request can be admitted or preserved at `u64::MAX`. Empty batches retain their
existing identity/revision checks and do not increment.

## Executed offline verification

Setup used pinned Flutter **3.47.9 / Dart 3.13.7**, matching
[`fdroid/flutter.version`](../../fdroid/flutter.version), Rust **1.95.0**, the
existing isolated PUB/CARGO caches and private `TMPDIR`. Provisioned `/usr/bin/python3`
imports (`pytest`, `jinja2`, `markupsafe.soft_str`) passed. Checkout-local package
metadata was regenerated by `flutter pub get --offline --enforce-lockfile`;
`pubspec.lock` remained unchanged.

Passing checks on the implementation:

- `cargo test --manifest-path rust/Cargo.toml -p fractal-core --test session_number_wall --test session_replay --test session_effects --test number_wall_frame --locked --offline`: **16 tests**.
- `scripts/ci/rust-check.sh` under `autowork-run timeout 1200`, pinned Rust/CARGO_HOME:
  formatting, denied-warning workspace clippy and **49 tests including doctests**.
  Includes MAX-2 admission → MAX terminal completion/cancel, refused MAX-1/MAX
  begins, refused pending-preserving no-op and successful final-revision edit.
- `flutter test --no-pub test/number_walls/number_wall_state_test.dart test/modules/number_wall_model_test.dart test/migration/state_replay_test.dart test/core/controllers/fractal_controller_effect_bounds_test.dart`
  under `autowork-run timeout 1200`: **22 Dart oracle tests**.
- The [complete replay test](../../rust/crates/fractal-core/tests/session_replay.rs)
  executes all 68 original inputs twice, comparing result, history, transparency,
  pending/status, exact prime and first cell. Mutated expectations in events 47
  and 67 are rejected. `startLoad` retains a real staged job; awaiting drives bounded
  work or observes ownership cancellation, never substituted expected output.
- [Public request tests](../../rust/crates/fractal-core/tests/session_number_wall.rs)
  use deterministic begin/step/revoke/edit interleavings, not sleeps. They cover
  rollback, supersession, no-op preservation, cross-session/wrong/stale operations,
  latest-candidate merging, committed-prime use, retained storage and selection/reset.

The final preservation/whitespace and scoped documentation readback checks are
recorded in the worker report. The runner owns the separate merged-tree full gate;
no full-gate, device, browser, hardware or installed result is claimed here.

## Remaining proof

Still unported/unqualified: trajectories/RK4; deterministic randomization and undo;
interpolation, animation and timers; physical wheel/pinch/drag/fling/keyboard/
double-tap transforms and rotation-lock interactions; remaining module semantics;
platform executor and exact request/frame transport; native effects/forced-restore
round trips; stale native snapshot/frame rejection; snapshot-only legacy renderer;
editor/preset/history/deep-link app routing and whole-session owner switch.
Physical GPU/performance, browser and production qualification remain separate.

Reuse is limited to existing catalog normalization, atomic candidate snapshots,
effect ownership and certified prime/grid/frame jobs. No new dependencies,
generated outputs, persistence, bridge flags/routes or extra framework were added.
The existing planner continuation, [RUST-PLAN-06](../../tasks/items/RUST-PLAN-06.md),
reconciles this core result with the other building tasks before selecting native
transport/executor proof. This note does not close that task or qualify M2.
