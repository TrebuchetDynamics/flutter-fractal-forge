# RUST-M2-PHYSICAL-TIME — Explicit physical timing and completion

## Boundary

This extends the existing [raw physical owner](RUST-M2-PHYSICAL-STATE.md), following
[the raw transaction design](RUST-PLAN-09.md#raw-physical-transactions). It is an
inert core implementation, not an app ownership switch. The
[planned engine boundary](../engineering/spec.md#planned-rust-engine-boundary),
[ADR 0005](../adr/0005-rust-owns-all-mathematical-domain-logic.md) and
[target-specific qualification limits](../adr/0006-native-demonstration-performance-is-target-specific.md)
remain unchanged. Flutter retains arena, focus, nested control and platform routing.

## API and clocks

[`PhysicalState::reduce`](../../rust/crates/fractal-core/src/physical_events.rs)
now accepts `Pump { generation, delta_us }` and `Dispose`, in addition to the
existing raw events and explicit `Wall(us)` input. `generation()` and
`Session::physical_generation()` expose the current callback owner, not mutable
camera state. A stale generation produces no updates or completion. Sequence
validation and normal transaction revision publication still apply to stale pumps.
A negative pump delta is invalid. Checked clock/generation arithmetic rejects overflow.

The hidden [`physical_event_time`](../../rust/crates/fractal-core/src/physical_event_time.rs)
state keeps three clocks separate:

- Pointer source timestamps take precedence over wall time for the last five pan
  samples; sample milliseconds are truncated before velocity calculation.
- Explicit wall time classifies raw taps. Two-finger candidates use at most 220 ms
  and 18 px movement; raw double taps use at most 280 ms and 28 px separation.
  Requests less than 120 ms after the last double trigger are suppressed.
- Pump deltas advance animations only. The first pump anchors a newly started
  ticker without advancing it, matching Flutter's first ticker callback. Later
  zero-delta pumps do not reset that anchor. Momentum is capped at 2 seconds;
  taps use 200 ms. The cumulative pump clock is checked independently of these caps.

Recognized gesture starts replace the animation generation, clear previous pending
completion and reset velocity admission. Raw pointer down alone does not stop an
animation before the source recognizer accepts the replacement gesture. Module-ID
changes in ordinary Session command batches invalidate the physical owner on the
private candidate; disposal invalidates it and ignores subsequent raw events.
Pointer cancellation follows the source scale-end path, which can still admit a
fling. Completion is not an external timer or a substituted Flutter callback.

Pan admission is strictly greater than 5 px per 16000-us reference frame. Zoom
admission is strictly greater than .01 log2 zoom levels/ms. The implementation
reuses `physical_view::advance_pan` and `advance_zoom`: .95/.92 decay, .1/.0001
cutoffs and fractional reference frames. Pan uses existing 2D/3D transforms and
bounds, with .5 velocity damping at a 2D boundary. Momentum zoom adapts iterations;
3D momentum changes distance without focal pan. Zoom is processed before pan, as
in source ticker registration order. A pending end waits until both owners stop
and is emitted once.

Tap animations reuse focal/bounds math. Double tap computes its target once and
interpolates pan by `t * targetZoom / currentZoom`; two-finger zoom uses incremental
focal zoom. Easing matches Flutter `Curves.easeOutCubic`, including its cubic
control points and .001 binary-search tolerance, rather than a polynomial fit.
Source raw-tap versus scale-recognizer ordering is preserved, including a scale
start that cancels the two-finger tap animation during pointer removal.

`Session::apply_physical` retains its single atomic publication. Rejected batches,
wrong identity, stale revision and overflow preserve visible/adaptive state,
pointer anchors, generation and hidden elapsed time. Outputs remain logical camera
updates, lifecycle signals and key dispositions. No Rust platform haptic/menu call
or bridge transport is added.

## Coverage and verification

[`session_physical_time`](../../rust/crates/fractal-core/tests/session_physical_time.rs)
replays the unchanged raw inputs of all 67 `physical-events.json` scenarios and
checks all 382 checkpoints, including every timed checkpoint. Cameras match within
`1e-8`; lifecycle order, key dispositions and supported Session module, parameter
and effect state match exactly. This includes the 8333/16667/33333/100000-us pump
cadences, velocity/tap thresholds, bounds, handoff, cancellation, replacement,
module changes, disposal and repeated completion attempts. A separate public-seam
case checks active-animation batch rollback, clock overflow, wrong identity/stale
revision and an abandoned generation attempting to finish a replacement gesture.

Supported modules compose through Session. Mandelbulb and quaternion results are
**pure reducer only**: they are not admitted Session modules. Gaussian walk-key
routing is also pure-only. Shell-owned nested-control values are not Rust state.
These results do not qualify full module, typed bridge, app, browser, device,
hardware-GPU or performance ownership. Those follow-up gates remain pending under
the migration plan; no fixture refresh, native/source artifact refresh or platform
claim follows from these offline checks.

| Check | Result |
| --- | --- |
| Pinned setup, offline lock-enforced pub get | Passed: Flutter 3.47.9 matches `fdroid/flutter.version`, Dart 3.13.7; `/usr/bin/python3` imports pytest/Jinja2 and callable `markupsafe.soft_str`. |
| `cargo test --manifest-path rust/Cargo.toml -p fractal-core --test session_physical_time --test session_physical_events --test physical_view --test session_replay --test session_param_timeline --locked --offline` | Passed: 22 tests, including all 382 raw checkpoints, 191 existing instantaneous outputs and the unchanged 68-output replay. |
| `autowork-run scripts/ci/rust-check.sh` | Passed: formatting, denied-warning clippy and 123 workspace tests/doc tests. |
| `autowork-run timeout 1700 flutter test --no-pub test/migration/physical_events_oracle_test.dart test/fractal/fractal_renderer_gesture_test.dart test/features/renderer/widgets/renderer/input/gesture_tap_classification_test.dart test/renderer/pan_momentum_test.dart test/renderer/zoom_momentum_test.dart` | Passed: 47 unchanged Dart tests. |
| Protected-path diff and `git diff --check` | Passed: Dart/reference/bridge/lock bytes unchanged; no whitespace errors. |
| Scoped Docs Sync Maintain | Passed: component API/source/test readback, local links/anchors and repeat byte-stability check. |

The runner owns the merged-tree full check. This scoped Maintain changes only this
component note; shared task records, pruning and release history remain coordinator
owned. Existing spec/ADRs remain valid for this inert change. Reuse is limited to
the existing physical owner, camera kernels, normalizer, Session commands and frozen
oracle. This retry reuses the six task-scoped files from the earlier candidate,
reviewed against the current baseline, and reruns every named offline check;
earlier check claims are not used as this retry's evidence. No dependencies,
manifests, locks, generated/native code, new module admission, production Dart
changes or owner-switch flags were needed.
