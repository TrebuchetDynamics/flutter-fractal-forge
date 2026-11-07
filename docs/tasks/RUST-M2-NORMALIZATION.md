# RUST-M2-NORMALIZATION — Pure scalar normalization

## Scope and status

Implemented locally for coordinator review and integration. This is an inert M2
preparation API, not M2 completion or a live controller/renderer/registry switch.
The [accepted batch](RUST-PLAN-03.md#decided-interfaces-and-error-semantics) and
[normative engine boundary](../engineering/spec.md#planned-rust-engine-boundary)
remain unchanged. RUST-M2-SESSION is the next consumer.

## Public API

[`fractal_core::normalization`](../../rust/crates/fractal-core/src/normalization.rs)
is exported from [`lib.rs`](../../rust/crates/fractal-core/src/lib.rs).
It reuses `Parameter` and `ParameterValue` from the existing
[typed catalog reader](RUST-M3-CATALOG-PARITY.md#api-and-preservation).

- `RawScalar` has `Number(serde_json::Number)`, `Float(f64)`, `Boolean(bool)` and
  `Text(String)` variants. `Float` admits NaN and infinities; `Number` preserves
  JSON integer/float representation. `From<ParameterValue>` retains the original
  scalar kind and text without numeric parsing.
- `normalize_parameter(schema: &Parameter, raw: &RawScalar) -> ParameterValue`
  implements the [Dart generic parameter policy](../../lib/core/controllers/params/fractal_param_value_normalizer.dart).
  Finite numeric inputs clamp to ordered finite schema bounds. Integers round
  half away from zero, then clamp to the integer interior of the bounds; outputs
  are native signed integers. Unusable bounds, wrong types and nonfinite numbers
  use the schema default. Values do not snap to slider steps.
- Enumeration membership uses Dart-compatible numeric equality (`1 == 1.0`),
  without accepting numeric strings or merging adjacent integers above binary64
  precision. Accepted values retain their input representation. Booleans require
  actual boolean inputs and otherwise use the boolean default (or false for a
  malformed nonboolean default).
- Decimal-integer values accept only exact text matching `0|[1-9][0-9]*`.
  Text beyond binary64/u64 remains unchanged. This is syntax validation only:
  accepting `0`, `1` or a composite does not certify primality or capability.
- `ViewInput { zoom: f64, pan: [f64; 2], rotation: [f64; 3] }` accepts raw scalar
  candidates and prior values. `normalize_view(candidate: ViewInput,
  current: ViewInput, module_id: &str) -> FiniteView` returns finite values through
  `zoom() -> f64`, `pan() -> [f64; 2]` and `rotation() -> [f64; 3]`.
  `FiniteView` has no public unchecked constructor.
- Component APIs are `min_zoom_for_module(module_id: &str) -> f64`,
  `normalize_zoom(candidate: f64, current: f64, module_id: &str) -> f64`,
  `normalize_pan_component(candidate: f64, current: f64) -> f64` and
  `normalize_rotation_component(candidate: f64, current: f64) -> f64`.
  They port [FractalViewInputBounds](../../lib/core/controllers/input/fractal_view_input_bounds.dart).
  Public constants are `MAX_ZOOM = 1e12`, `DEFAULT_MIN_ZOOM = 1e-9`,
  `CANTOR_SET_MIN_ZOOM = 0.2`, `MIN_PAN = -3.0` and `MAX_PAN = 3.0`.

View infinities clamp, unlike parameter infinities. View NaNs retain bounded
prior components; a prior NaN uses minimum zoom or zero pan. Nonfinite rotation
retains the finite prior angle, or zero when neither angle is finite. Finite
rotations are not range-limited. Only `cantor_set` uses the higher minimum zoom.

## Checks

Setup used existing Rust 1.95.0, `CARGO_HOME="$AUTOWORK_CACHE/cargo-1.95.0"`
and private `TMPDIR`. Flutter 3.47.9 matched `fdroid/flutter.version`; Dart was
3.13.7. `/usr/bin/python3` 3.12.3 imported pytest 9.0.2, Jinja2 3.1.6 and
`markupsafe.soft_str`. `flutter pub get --offline --enforce-lockfile` regenerated
checkout-local package metadata; `pubspec.lock` retained its SHA-256.

| Check | Result |
|---|---|
| `cargo test --manifest-path rust/Cargo.toml -p fractal-core --test normalization --locked --offline` | Passed: five focused public-seam tests against original descriptors/envelopes. Numeric cases read original replay events 7–13, including defaults for misleadingly labelled infinity events 8/9/12/13. Other cases cover finite bounds, signed zero, half-integer rounding, invalid integer interiors, numeric/text enum distinction, strict booleans and canonical decimal text. |
| `autowork-run scripts/ci/rust-check.sh` with pinned Rust/cache | Passed: format, denied-warning clippy, all 12 workspace tests and doc-test targets. The unchanged `core_and_render_reject_platform_dependencies` guard passes across all features, targets and normal/build/dev edges. |
| `autowork-run flutter test --no-pub test/migration/state_replay_test.dart test/fractal/fractal_controller_clamp_test.dart test/fractal/fractal_controller_boolean_clamp_test.dart` with pinned Flutter/cache | Passed: six tests, including the original Dart state/precision replay and expectation-drift rejection. This is Dart oracle evidence, not a Rust session replay. |
| `git diff --exit-code -- migration/baseline lib/core/controllers lib/core/models && git diff --check` | Passed: original catalog/replay/reference files and Dart owners unchanged; no whitespace errors. Manifests, locks, generated output, app routing and normative spec remain unchanged. |
| Scoped Docs Sync Maintain readback | Passed: note links/anchors, exported API names/signatures, bounds and claims checked against actual source/tests. No role manifest exists; generic Docs Sync checks provide no link coverage here, so local links received a separate check. |

The [Rust tests](../../rust/crates/fractal-core/tests/normalization.rs) compare
18 selected original view events (1/2, 17–24 and 34–41) with recorded prior views,
plus malformed-prior fallback cases. They do not execute a Rust state session or
claim ordered/full-session parity. Baseline files are read, never refreshed.
The merged-tree full offline gate belongs to the runner and was not run here.

## Reuse and remaining gaps

This change reuses `CatalogBaseline`, `Parameter`, `ParameterValue`, original M0
catalog/replay envelopes, the locked Serde graph and the existing dependency guard.
It adds only the normalization module, export, focused tests and this API/check
note. No new dependency, fixture copy, parser, generated glue or bridge is needed.
The scoped Docs Sync Maintain pass updates this designated owner only; shared
history/task records and normative specification remain unchanged.

Adaptive iteration history, gestures/transforms, trajectories, transactional
session state, effects, cancellation, asynchronous Number Walls certification,
precision policy and live/native/browser qualification are outside this API.
`ViewInput` has no trajectory field: callers must handle unsupported trajectories
explicitly, not infer support or silently drop them. The full-session boundary
remains unqualified; the [remaining proof map](RUST-PLAN-03.md#remaining-proof-and-continuation)
still applies. These scalar results authorize no runtime owner switch or
mathematical claim upgrade.
