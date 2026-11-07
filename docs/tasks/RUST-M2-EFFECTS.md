# RUST-M2-EFFECTS — Inert session effects and kaleidoscope restoration

## Scope and API

Implemented locally for coordinator review and integration under RUST-002-07ee2543.
This extends the [ordinary session candidate](RUST-M2-SESSION.md), not the app's
state owner. The [decided implementation seam](RUST-PLAN-04.md#decided-implementation-seams)
and [migration plan](../planning/refactor-plan.md#flutter-shell-and-rust-engine-migration)
remain authoritative. The specification's [planned Rust boundary](../engineering/spec.md#planned-rust-engine-boundary)
and [state and persistence](../engineering/spec.md#state-and-persistence) are unchanged.
This result does not qualify M2, full-session parity or a runtime switch.

[`session.rs`](../../rust/crates/fractal-core/src/session.rs) adds eleven typed
`Command` variants and matching read-only `Snapshot` getters:

| Command | Getter | Default and input policy |
| --- | --- | --- |
| `GlowEnabled(bool)` | `glow_enabled()` | false |
| `GlowSigma(f64)` | `glow_sigma()` | 1.0; clamp to .1–5 |
| `GlowIntensity(f64)` | `glow_intensity()` | .35; clamp to 0–1 |
| `FluidModeEnabled(bool)` | `fluid_mode_enabled()` | false |
| `FluidStrength(f64)` | `fluid_strength()` | 1.0; clamp to 0–2 |
| `RotationLocked(bool)` | `rotation_locked()` | false; gesture policy state only |
| `KaleidoscopeEnabled(bool)` | `kaleidoscope_enabled()` | false; forced modules reject disabling by retaining true |
| `KaleidoscopeSectors(i64)` | `kaleidoscope_sectors()` | 8; clamp to 4–16, then round down to even |
| `KaleidoscopeMirror(bool)` | `kaleidoscope_mirror()` | true |
| `KaleidoscopeRotation(f64)` | `kaleidoscope_rotation()` | 0; finite, unbounded angle; nonfinite input retains the last finite angle |
| `KaleidoscopeMirrorMode(i64)` | `kaleidoscope_mirror_mode()` | 0; clamp to 0–3 |

Bounded effect NaNs retain the last good value. Infinities clamp to the corresponding
bound. The existing Dart-compatible scalar clamp also preserves signed-zero policy.
Direct `Rotation` commands still work while rotation lock is true.
The private child [`session_effects.rs`](../../rust/crates/fractal-core/src/session_effects.rs)
holds effective effects and an optional five-field kaleidoscope restore value.
There is no public restore-state setter or new `lib.rs` export.

The supported IDs are now exactly `mandelbrot`, `julia`, `cantor_set`,
`recursive_sine_sphere`, **`kaleidoscope_basic` and `kaleidoscope_fractal`**.
The two additional IDs consume their complete original catalog descriptors,
parameters and default presets. Catalog IDs such as `core.kaleidoscope_basic`,
unrecognized prefix matches and embedded-kaleidoscope fractals remain unsupported.
Non-null trajectories still reject through `CameraInput` and catalog default-camera
validation. No baseline descriptor is copied or refreshed.

## Module and reset semantics

The current [Dart controller](../../lib/core/controllers/fractal_controller.dart),
[effect bounds](../../lib/core/controllers/input/fractal_effect_input_bounds.dart)
and [kaleidoscope policy](../../lib/core/controllers/state/fractal_kaleidoscope_state.dart)
are the source oracle:

- Construction and a changed `SelectModule` apply module policy. Selecting the same
  module, including a view reset, does not reapply it.
- Entering either supported forced ID saves the current five-field user state once.
  Policy forces enabled=true, sectors=16 and mirror mode=3. Mirror and rotation stay
  unchanged. Forced-to-forced transitions retain the first restore value.
- Setters may change sectors, mirror, angle and mode while forced. They do not alter
  the saved user state. Exiting to an ordinary module restores all five saved fields
  and clears the hidden restore value.
- `Load` applies policy even when the module is omitted or unchanged. It can reapply
  forced defaults after local edits. `ApplyPreset` does not select its supplied
  module ID or reapply policy. Both preserve glow, fluid and rotation lock.
- `ResetParams` and `ResetView` preserve every effect and the lock. `ResetSession`
  resets parameters, view and transparency as before, and clears rotation lock.
  It preserves all other effective effects and hidden restoration state, even
  modified forced-module settings. It does not reapply forced defaults.

Effects and hidden restoration participate in the existing private candidate clone.
Ordered commands publish once per nonempty successful batch. Stale/error batches
publish nothing, including no restore-state changes. Detached snapshots and other
sessions retain their state. No notification, timer or serializer is added.

## Executed offline checks

Setup used existing Rust 1.95.0 with
`CARGO_HOME="$AUTOWORK_CACHE/cargo-1.95.0"` and private `TMPDIR`.
Flutter 3.47.9 matches `fdroid/flutter.version`; Dart is 3.13.7.
System Python 3.12.3 imports pytest 9.0.2, Jinja2 3.1.6 and
`markupsafe.soft_str`. `flutter pub get --offline --enforce-lockfile` regenerated
checkout-local metadata without changing the lockfile.

| Check | Actual result |
| --- | --- |
| `cargo test --manifest-path rust/Cargo.toml -p fractal-core --test session_effects --test session_replay --locked --offline` | Pass: four new public-seam effect tests and three unchanged replay tests. |
| `autowork-run timeout 600 scripts/ci/rust-check.sh` | Pass: formatting, denied-warning clippy, all 26 workspace tests and doc-test targets. |
| `autowork-run timeout 600 flutter test --no-pub test/core/controllers/fractal_effect_input_bounds_test.dart test/core/controllers/fractal_controller_effect_bounds_test.dart test/core/controllers/fractal_kaleidoscope_state_test.dart test/fractal/fractal_controller_reset_session_test.dart test/migration/state_replay_test.dart` | Pass: all 14 tests from the five requested files. These exercise the Dart oracle, not Rust transport. |
| `git diff --exit-code -- migration/baseline lib packages/fractal_engine_bridge rust/crates/fractal-bridge rust/Cargo.lock pubspec.lock && git diff --check` | Pass: protected inputs, app and bridge remain unchanged. |
| Command/snapshot/restore source readback | Pass: compared the final Rust command arms, defaults, getters and policy call sites with the three Dart source owners above and the requested Dart tests. |
| Scoped Docs Sync Maintain readback | Pass: note API, source references, local links/anchors and remaining-proof claims checked against the final source and outputs. Bundled `docs.py stale .` and `docs.py check .` report no role manifest and provide no link coverage; a separate scoped link/anchor check covers this note. |

The [new test seam](../../rust/crates/fractal-core/tests/session_effects.rs) covers
all setters/defaults, finite/nonfinite bounds, forced→forced→ordinary restoration,
construction from original descriptors, reset/preset/load persistence, ordered
batch/singleton equality, one publication, stale/error rollback and snapshot/session
isolation. Test comments identify the current Dart source/assertion owners.
The unchanged strict replay still matches original events **0–46**, twice, and
rejects expectation drift. Events **47–67 remain explicitly unsupported**.
Effects vectors are separate source-matched tests, not an expanded M0 replay claim.
The coordinator owns the merged-tree full offline gate; it was not run here.

## Reuse, omissions and remaining proof

This reuses the existing validated catalog, parameter/view normalization, immutable
snapshot interface and atomic publication. One visibility-only change makes the
existing normalization clamp crate-private for reuse, without exporting it publicly.
There are no new dependencies, manifests, locks, saved schemas or generated outputs.
Scoped Docs Sync Maintain changes only this designated result note. Shared task
records, changelog history and normative specification remain coordinator-owned.

Timers, animation/randomization, trajectories, Number Walls grids/certification and
asynchronous ingress, physical-input transforms and full-session transport proof
remain unported or unqualified. No renderer, app/controller routing or bridge DTO
is changed. The [existing bridge](RUST-M2-BRIDGE.md) does not transport these new
commands/getters. The planned native fixture deliberately consumes only its old
four-module API; it cannot qualify effects transport. Installed full-session
round trips, physical-input and hardware/browser qualification remain separate
proof. Offline tests do not authorize runtime ownership or full M2 qualification.
The next reconciliation owner remains RUST-006-ee74a370 in
[the frontier plan](RUST-PLAN-04.md#next-executable-batch).
