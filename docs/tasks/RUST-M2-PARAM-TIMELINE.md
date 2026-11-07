# RUST-M2-PARAM-TIMELINE — Ordered parameter timeline

## Scope and API

Implemented for coordinator review and integration under the
[ordered timeline plan](RUST-PLAN-08.md#ordered-parameter-timeline).
This extends the inert [Session owner](RUST-M2-SESSION.md), not the application
route or the [planned engine boundary](../engineering/spec.md#planned-rust-engine-boundary).

[`session::Session`](../../rust/crates/fractal-core/src/session.rs) exposes three
identity/revision-checked methods implemented in
[`session_param_timeline.rs`](../../rust/crates/fractal-core/src/session_param_timeline.rs):

- `start_param_timeline(session_id, expected_revision, target)` accepts an owned
  `BTreeMap<String, ParameterValue>` and returns an opaque `ParamTimelineToken`.
  Start and replacement capture the current live params as step zero. They publish
  one revision without changing visible params. The start revision identifies the
  generation; Session identity allocation remains the caller's responsibility.
- `tick_param_timeline(session_id, expected_revision, token)` returns a detached
  `Snapshot`. Each active call publishes exactly one revision and consumes one
  logical step, through step 36. No elapsed time or intermediate map is accepted.
- `cancel_param_timeline(session_id, expected_revision, token)` returns a detached
  `Snapshot`. Active cancellation publishes one revision without changing params.
  Repeated cancellation and ticks for stopped/completed/replaced generations are
  no-ops. Old cancellation cannot stop a replacement. Foreign tokens return
  `WrongSession`; incorrect owner/revision checks still fail on no-op calls.

The complete target must contain exactly the current module's schema keys and
already-normalized typed values. Missing/unknown keys, invalid types and values
outside the schema return `InvalidParameterTarget` without replacing live work.
Number Walls targets return `UnsupportedOperation`: its certified frame/settings
must continue through its existing ingress owner. Synthetic schemas stay in the
pure kernel tests, not Session's supported-module list.

The hidden from/target/step/token record belongs to Session, not Snapshot, Dart or
an external timer. Ticks reuse the existing
[`interpolate_parameters`](RUST-M2-INTERPOLATION.md#scope-and-api) kernel. Steps
1–35 use its cubic easing, integer rounding, normalization and discrete-value
retention. Step 36 assigns the complete validated target unchanged and stops.
Replacement starts from the current partial map, not the first generation's from
map. Each operation checks revision addition before any visible or hidden mutation;
future revision capacity is not reserved for the remaining callbacks.

## Cancellation and transactions

The cancellation hooks follow
[`FractalController`](../../lib/core/controllers/fractal_controller.dart), including
its `resetView` exception:

- Known `Param` edits, preset/load/module selection (even same-module selection),
  `ResetParams` and `ResetSession` stop the parameter timeline.
- Scalar camera changes, adaptive iteration changes, `ResetView`, effects and
  transparency alone do not stop it. Unknown parameter edits do not stop it.
- `apply_batch` plans cancellation against each ordered candidate state and commits
  it only after the entire batch succeeds. Unsupported or deferred mixed batches
  preserve both live params and the hidden next step/generation.
- Successful deferred Number Walls admission also stops the timeline. Starting an
  ordinary timeline cancels a pending wall request before it can publish a stale
  target. Rejected admission/start leaves the previous work intact.

Retained snapshots remain detached and immutable. Session creates no timer, thread
or callback resource, so dropping it leaves no external scheduling resource behind.

## Executed offline checks

Setup used the existing isolated Flutter 3.47.9/Dart 3.13.7 SDK and PUB_CACHE;
Flutter matched `fdroid/flutter.version`. `/usr/bin/python3` 3.12.3 imported
pytest 9.0.2, Jinja2 3.1.6 and callable `markupsafe.soft_str`.
`flutter pub get --offline --enforce-lockfile` passed. Rust used 1.95.0 and
`CARGO_HOME="$AUTOWORK_CACHE/cargo-1.95.0"`. Scratch output stayed in the private
worker TMPDIR; no installation or lock change was needed.

| Check | Result |
|---|---|
| `cargo test --manifest-path rust/Cargo.toml -p fractal-core --test session_param_timeline --test param_interpolation --test session_replay --locked --offline` | Passed: eight tests. The new public Session cases compare actual-module oracle steps 0–36 and partial-state replacement, floats within 1e-12 and other values exactly; cancellation, stale tokens, invalid targets and mixed-batch rollback are covered. The two pure kernel tests remain unchanged, including synthetic coverage. Original replay still matches all 68 outputs. |
| `cargo test --manifest-path rust/Cargo.toml -p fractal-core --lib session::tests::revision_exhaustion_rejects_at_the_transaction_seam --locked --offline` | Passed: the extended existing overflow test checks public start/tick/cancel/batch operations, visible state and the hidden record, with white-box counter setup only. |
| `autowork-run scripts/ci/rust-check.sh` with pinned Rust/cache | Passed: workspace formatting, denied-warning clippy, unit/integration tests and doc-tests. |
| `autowork-run flutter test --no-pub test/migration/param_interpolation_oracle_test.dart test/fractal/fractal_controller_behavior_test.dart` | Passed: seven unchanged Dart tests, including the twice-executed fake-time oracle with source/nested-expectation drift rejection and the real-time behavior regression. |
| `git diff --exit-code -- lib migration packages rust/crates/fractal-bridge rust/Cargo.lock pubspec.lock && git diff --check` | Passed: production Dart, all migration fixtures, bridge/generated paths and locks unchanged; no whitespace errors. |
| Scoped Docs Sync Maintain readback | Passed: component-note links/anchors, API names, cancellation/rollback claims and check results checked against final source/tests; repeat readback was byte-stable. `autowork tasks prepare --check .` and task validation passed without task writes. Bundled `docs.py stale .` and `docs.py check .` report no role manifest and provide no content coverage here. |

The worker did not run the merged-tree full offline gate; the runner owns that gate.

## Reuse and remaining proof

This change reuses the Session identity/revision checks, ordered transaction owner,
Number Walls cancellation owner, catalog types, normalizer, interpolation kernel
and immutable oracle. The small Number Walls helper change connects successful
admission/cancellation to the new owner; it adds no mathematical algorithm.
Scoped Docs Sync Maintain updates this designated component note only. Shared
history and task records remain coordinator-owned.

No RNG, dependency, production Dart, bridge, generated output, fixture, lock or app
flag changed. There is no wall-clock catch-up, clock, timer transport, scheduler,
morph, celebration/haptic or physical-animation owner here.
**36 scheduled 16-ms callbacks are not a measured 600-ms timing guarantee.**
The unchanged Dart fake-time checks and explicit Rust ticks prove functional steps,
not hardware timing or full animation ownership. App/event transport, morph,
physical animation, full-session ownership and native/browser/hardware/live
qualification remain pending under the
[remaining proof plan](RUST-PLAN-08.md#remaining-proof-and-continuation).
