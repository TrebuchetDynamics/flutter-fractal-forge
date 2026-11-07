# RUST-M2-INTERPOLATION — Pure parameter interpolation

## Scope and API

Implemented locally for coordinator review and integration under the
[accepted kernel plan](RUST-PLAN-07.md#parameter-interpolation-kernel).
This is an inert preparation API, not an app route or full M2 qualification.

[`fractal_core::param_interpolation::interpolate_parameters`](../../rust/crates/fractal-core/src/param_interpolation.rs)
accepts `schema: &[Parameter]`, `from` and `target` as
`&BTreeMap<String, ParameterValue>`, and `step: u32`; it returns a new map.
It reuses the [catalog types and scalar normalizer](RUST-M2-NORMALIZATION.md#public-api).

- Step 0 clones the entire `from` map, including unknown keys and missing fields.
- Steps 1–35 use `1 - (1 - step/36)^3`. Each schema parameter uses its default
  for an absent from/target value. Interim maps contain only schema keys.
- `colorScheme`, `colorCycleSpeed`, booleans and enumerations retain their from
  values (or defaults). Other nonnumeric pairs also retain from; exact decimal
  text is never parsed or converted through binary64.
- Numeric pairs interpolate, then reuse `normalize_parameter`. Integers round
  ties away from zero **before** normalization, matching the controller. Slider
  step snapping is not part of interpolation.
- Step >=36 clones the **complete target**, without filling missing schema keys,
  retaining old keys or normalizing values. Discrete changes happen here.

No caller is switched. There is no clock, thread, timer, Session, morph, event,
rendering, scheduler or cancellation owner in this kernel. Those concerns remain
with existing production Dart and future whole-session work.

## Source-derived oracle

The [focused Dart test](../../test/migration/param_interpolation_oracle_test.dart)
executes unchanged public `FractalController.randomizeParams` under `testWidgets`
fake time. It records every step 0–36 by pumping 16 ms, including requested ticks
1, 18, 35 and 36. The complete target comes from another controller with identical
initial state and `Random(1)`, using `animate: false`; no duplicated interpolation
formula supplies the expectations.

[`migration/oracles/param-interpolation.json`](../../migration/oracles/param-interpolation.json)
keeps schema/from/target/expected values together. It binds the production source
graph, oracle test, Dart lock/version inputs and pinned VM RNG sources by SHA-256, with
Flutter 3.47.9/Dart 3.13.7 runtime metadata. The two cases cover Mandelbrot and a
test-only synthetic schema with fractional, integer, boolean, numeric/text enum,
palette and exact decimal-text values. A mutable synthetic parameter list exposes
missing-from and missing-both inputs through public APIs: one field is added after
initialization, another after target capture. This is test scaffolding only, not
an app/catalog mutation. Interim defaults for the latter field disappear at step 36.

The synthetic case retains `true`, enum `1`/`second` and decimal text
`9007199254740993` through tick 35, then assigns `false`, enum `2.5`/`first` and
`900719925474099312345678901234567890` at tick 36. The positive integer reaches
4.5 before rounding at tick 18 and becomes 5. Rust-only boundary inputs also check
negative -4.5 -> -5, missing-target defaults, changed palettes, nonnumeric retention,
normalization/clamping, unknown keys and complete terminal assignment.

Replacement starts after tick 5 from the actual partially interpolated state,
with a separately captured seeded target. Immediate replacement, module change,
resetParams, resetSession and dispose cancel the old timer. The fixture records
these actions; fake-time assertions require 36 notifications only for an animated
replacement and zero subsequent notifications for every cancellation action.

The test builds the full document twice and requires exact agreement. Normal
comparison never writes the fixture and rejects changed source hashes and a nested
changed expectation. Explicit scratch export is available with
`--dart-define=MIGRATION_INTERPOLATION_OUT="$TMPDIR/empty-directory"`; output must
be an empty absolute directory outside the checkout. Promotion is a separate,
reviewable file copy, never normal test behavior. Existing M0 baselines and the
[real-time behavior regression](../../test/fractal/fractal_controller_behavior_test.dart)
remain unchanged; that wall-clock regression is not a numeric oracle.

## Executed checks

Setup selected the existing isolated SDK/cache: Flutter 3.47.9 matched
`fdroid/flutter.version`, Dart was 3.13.7, and `/usr/bin/python3` 3.12.3 imported
pytest 9.0.2, Jinja2 3.1.6 and callable `markupsafe.soft_str`.
`flutter pub get --offline --enforce-lockfile` passed; both locks retained their
SHA-256. Rust used 1.95.0 and `CARGO_HOME="$AUTOWORK_CACHE/cargo-1.95.0"`.
Temporary output used the worker's private `TMPDIR`; no installation was needed.

| Check | Result |
|---|---|
| `cargo test --manifest-path rust/Cargo.toml -p fractal-core --test param_interpolation --test normalization --locked --offline` | Passed: two new public-kernel tests and five existing normalization tests. Full fixture outputs at all 37 steps, plus replacement samples, compare to Rust; ordinary floats use absolute 1e-12 and other values match exactly. |
| `autowork-run scripts/ci/rust-check.sh` with pinned Rust/cache | Passed: workspace formatting, denied-warning clippy and 75 tests including one doc-test. |
| `flutter test --no-pub test/migration/param_interpolation_oracle_test.dart test/fractal/fractal_controller_behavior_test.dart` | Passed: seven tests including the unchanged real-time regression and the twice-executed fake-time oracle with drift rejection. |
| `dart analyze test/migration/param_interpolation_oracle_test.dart` | Passed: no issues. |
| `git diff --exit-code -- lib migration/baseline packages rust/crates/fractal-bridge rust/Cargo.lock pubspec.lock && git diff --check` | Passed: protected production/baseline/bridge/lock paths unchanged; no whitespace errors. |
| Scoped Docs Sync Maintain readback | Passed: this component note's links/anchors, API and fixture/tick/discrete claims checked against source and actual outputs; repeat readback was byte-stable. Bundled `docs.py stale .` and `docs.py check .` passed with no role manifest, so they provide no content coverage here. |

The initial Dart comparison failed on the missing fixture and the initial Rust
public tests failed on the missing module before the numerical port. Subsequent
scratch generation and normal comparison passed. The runner owns the merged-tree
full offline gate; it was not run by this worker.

## Reuse and remaining proof

The smallest complete change reuses existing catalog types, normalization, the
locked Serde graph, public controller APIs, seeded Dart Random, fake widget time,
and replay source-binding/canonical-JSON helpers. No dependency, bridge, app flag,
production Dart, baseline refresh or new runtime owner is added. Scoped Docs Sync
Maintain updates this designated component owner only; shared history and task
records remain coordinator-owned.

**36 scheduled 16-ms ticks are not a measured 600-ms guarantee.** Fake-time
functional equivalence does not establish wall-clock latency, responsiveness,
race exhaustion or hardware performance. A single ordered Session time/event owner,
full-session animation and cancellation integration, native/browser/hardware/live
qualification and the [remaining M2 proof](RUST-PLAN-07.md#remaining-proof-and-continuation)
remain pending. This local kernel does not qualify the full migration or authorize
an owner switch.
