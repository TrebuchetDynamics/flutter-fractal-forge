# RUST-M2-PHYSICAL-STATE — Instantaneous raw physical transactions

## Boundary

This implements the inert core slice of the
[raw physical transaction design](RUST-PLAN-09.md#raw-physical-transactions).
It does not switch an app owner or enable a bridge route. The
[planned engine boundary](../engineering/spec.md#planned-rust-engine-boundary),
[ADR 0005](../adr/0005-rust-owns-all-mathematical-domain-logic.md) and
[target-specific qualification limits](../adr/0006-native-demonstration-performance-is-target-specific.md)
remain unchanged.

The production source owners remain
[`gesture_handler.dart`](../../lib/features/renderer/widgets/renderer/input/gesture_handler.dart)
and [`viewer_interactions.dart`](../../lib/features/viewer/navigation/viewer_interactions.dart).
Flutter still owns its gesture arena, focus dispatch, nested widgets and HUD routing.

## Public API and transaction rules

[`physical_events`](../../rust/crates/fractal-core/src/physical_events.rs) exports
`PhysicalState::reduce(context, event)`. Inputs are typed down/move/up/cancel,
wheel, key/focus and wall time records. Each event carries a strictly increasing
sequence, optional source microseconds and a shell-consumed routing bit. Context
supplies the current view, dimension/orbit convention, lock, shell viewer-key
routing enablement and optional `[width, height]` layout. Coordinates are local pixels; rotations are radians.
No input carries a resolved camera delta or ScaleDetails.

The cloneable opaque state carries insertion-ordered pointers, source/wall time,
layout, recognition and pinch anchors, rotation activation and last-five pointer
samples. A rejected reduction does not consume them or its sequence. Initial
recognition and pointer-count reconfiguration follow the pinned Flutter scale
recognizer; no competing gesture arena is implemented.

[`Session::apply_physical`](../../rust/crates/fractal-core/src/session_physical_events.rs)
checks identity/revision and evaluates an ordered batch on private visible and
hidden candidates. It uses existing camera commands, adaptive iteration policy,
normalization, trajectory invalidation and terminal revision reservations, then
publishes once. Empty batches check identity/revision without publishing.
Nonempty accepted batches publish one revision, including no-ops. Wrong identity,
stale revision, invalid geometry/pointer sequence and revision overflow publish
nothing. Camera transactions retain the parameter timeline and retain trajectory settings
except on an explicit view reset.
Known parameter edits still use the existing cancellation policy.

The detached result contains a Snapshot and ordered raw camera updates,
interaction signals and key dispositions. Wheel emits correction; recognized
starts emit start. End/tap/momentum completion is not claimed by this slice.
Pure consumers must normalize each raw candidate before the next event; Session
does this internally. Reset candidates use the existing unit/zero camera reset.

## Numerical and routing coverage

The reducer reuses [`physical_view`](RUST-M2-PHYSICAL.md#api-and-numerical-contract).
It preserves shortest-side 2D drag with screen rotation ignored, height-scaled 3D
pinch targets, module orbit signs, tilt limits and rotation lock. Initial accepted
one-pointer movement recovers the raw down distance. Pinch-to-pan reconfiguration
reanchors the remaining pointer and preserves source restart order. Intentional
2D twist activates only above `.12` radians. Missing layout leaves pinch pan
unchanged and retains only the source unlocked 3D incremental twist fallback.

Focused viewer keys use `.08` rotated pan, `1.2` zoom and R reset; repeats/up are
ignored. Nested control keys have precedence, and Gaussian walk keys remain
ignored at the pure seam. The shell supplies consumed pointer routing; the reducer
does not implement control value changes or infer widget hit regions.

[`session_physical_events`](../../rust/crates/fractal-core/tests/session_physical_events.rs)
reads the unchanged `physical-events.json` inputs and checks 191 instantaneous
outputs from 33 scenarios. These include all wheel checkpoints and the pre-pump
drag, bounded-drag, pinched, handoff, resumed and twisted checkpoints. View values
match within `1e-8`; supported Session module/parameter/effect values, key
handling and interaction order match exactly. Supported modules go through Session.
Mandelbulb and quaternion geometry go only through the pure reducer. Gaussian key
precedence is also pure-only because Gaussian is not an admitted Session module.
No module admission is added.

A focused absent-layout case covers 2D/3D and lock states. Rejected mixed pointer,
wheel and invalid-input transactions retain the visible/adaptive and hidden
first-delta state, detached snapshots and the parameter callback owner. The existing
Session exhaustion case also checks physical transaction overflow rollback.
The unchanged replay and parameter timeline tests retain all 68 replay outputs
and existing interpolation/cancellation rules.

## Verification and omissions

This retry revalidated the reused task-scoped implementation on the current baseline;
no earlier bridge/generated changes were imported. Focused Rust tests passed with
the pinned Rust 1.95.0 offline cache. Flutter
3.47.9/Dart 3.13.7 matched `fdroid/flutter.version`; `/usr/bin/python3` imported
pytest/Jinja2 and callable `markupsafe.soft_str`. Offline lock-enforced pub get
regenerated checkout-local metadata without lockfile changes.

| Check | Result |
|---|---|
| `cargo test --manifest-path rust/Cargo.toml -p fractal-core --test session_physical_events --test physical_view --test session_replay --test session_param_timeline --locked --offline` | Passed: 20 tests, including 191 instantaneous oracle outputs and all 68 replay outputs. |
| `autowork-run scripts/ci/rust-check.sh` | Passed: formatting, denied-warning clippy, 121 workspace tests/doc tests, including physical overflow rollback. |
| `autowork-run timeout 1700 flutter test --no-pub test/migration/physical_events_oracle_test.dart test/fractal/fractal_renderer_gesture_test.dart test/fractal/fractal_viewer_screen_widget_test.dart` | Passed: 241 unchanged Dart tests. |
| `git diff --exit-code -- lib migration packages rust/crates/fractal-bridge rust/Cargo.lock pubspec.lock && git diff --check` | Passed: production/reference/bridge/lock bytes unchanged; no whitespace errors. |
| Scoped Docs Sync Maintain readback, local links/anchors and repeat byte-stability check | Passed: API, coverage and exclusions match source/tests; all ten links/anchors resolve. |

The merged-tree full check belongs to the runner, not this worker. Scoped Docs
Sync Maintain updates only this designated component note; shared task records and
release history belong to the coordinator. There is no `docs/roles.json`; generic
`docs.py stale` and `docs.py check` report no manifest, so scoped links were checked
separately. The spec and ADRs remain valid for this inert core-only change.

This reuses the existing domain types, camera kernels, normalizer, Session commands
and frozen oracle. There are no new dependencies, generated/native artifacts,
fixture refreshes, production Dart changes, bridge changes or manifest/lock edits.
Timed recognition/completion, velocity admission, momentum, tap animations and
elapsed pumps remain the PHYSICAL-TIME successor's work on this hidden owner.
Instantaneous unit checks establish no unsupported-module Session, app/native,
browser/device, hardware-GPU, performance or full-M2 qualification.
