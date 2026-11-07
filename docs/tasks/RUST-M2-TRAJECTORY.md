# RUST-M2-TRAJECTORY — Bounded trajectory kernel

## Result and boundary

The inert Rust core now exports a pure [trajectory module](../../rust/crates/fractal-core/src/trajectory.rs).
It ports the validated [Dart settings](../../lib/core/models/attractor_trajectory_settings.dart)
and [RK4 model](../../lib/core/modules/attractor_trajectory.dart) for `thomas`,
`fourWing` and `lorenz2d`. The [public tests](../../rust/crates/fractal-core/tests/trajectory.rs)
use the unchanged Dart short-horizon and projection fixtures.

This is a kernel result, not Session support or full M2 qualification.
[Session](../../rust/crates/fractal-core/src/session.rs) still rejects non-null
trajectory metadata with `UnsupportedTrajectory`. Its existing rejection tests,
source guards, Dart code, saved formats, baseline envelopes, bridge, dependencies
and locks are unchanged. The [planned Rust boundary](../engineering/spec.md#planned-rust-engine-boundary),
[ADR 0005](../adr/0005-rust-owns-all-mathematical-domain-logic.md) and accepted
[trajectory design](RUST-PLAN-06.md#trajectory-kernel) remain unchanged.

## Rust-local API

| API | Contract |
| --- | --- |
| `OrbitTrajectorySettings::new(system, seed, step_size, burn_in_steps, retained_steps, projection)` | Returns validated version-1/rk4 settings or `TrajectoryError::InvalidSettings`. Fields are private. Getters return scalar copies. |
| `OrbitTrajectorySettings::defaults_for(module_id)` | Returns defaults only for `thomas_attractor`, `four_wing` and `lorenz_2d`; otherwise `None`. |
| `settings.is_compatible_with(module_id)` | Compares the approved system and projection only. The legacy `f0057_thomas_attractor` alias is not compatible. |
| serde settings serialization/deserialization | Preserves the version-1 JSON keys, array seed and enum spellings. Deserialization also passes validation. Equality is numeric, not Dart cache-key string equality. |
| `decode_orbit_trajectory_settings(&Value)` | JSON null means legacy absence. Malformed non-null input returns an error. |
| `integrate(system, initial, dt, steps)` | Independent RK4 integration with finite initial state, finite positive `dt` and unsigned steps. A non-finite resulting state returns `NonFiniteIntegration`. |
| `project(point, projection)` | Returns the source `xz` or orthonormal `thomasOblique` projection. |
| `TrajectoryJob::new(settings)` | Owns validated settings, pending samples, state and incremental bounds. It exposes no partial trajectory. |
| `job.advance(&AtomicBool)` | Returns `None` while pending, or a shared reference to the terminal `Result<AttractorTrajectory, TrajectoryError>`. Each call performs at most 256 integration steps. |
| `job.steps_completed()`, `job.result()` | Read-only integration progress and optional terminal result. |
| `generate(settings)` | Drives the same job kernel synchronously and returns its owned terminal result. |
| `trajectory.settings()`, `trajectory.points()`, `trajectory.bounds()` | Shared settings/sample views and a bounds copy. No mutable sample storage escapes. Cloned results own independent storage. |

Settings require a finite seed, `0 < stepSize <= 0.1`, positive retained count,
retained count at most 20000, and total burn-in plus retained work at most 25000.
Unsigned counts reject negative JSON values. Checked addition rejects overflow.
Version and integrator are fixed in public construction and checked on decode.
All JSON fields are required. Unknown extra fields remain ignored, as in Dart.

All defaults use `stepSize=0.01`, `burnInSteps=5000` and `retainedSteps=20000`.
Thomas uses seed `[0.1,0.2,0.3]` and `thomasOblique`. Four-wing uses `[1,1,1]`
and `xz`. Lorenz uses `[0.1,0.2,0.3]` and `xz`.

## Work, cancellation and numeric limits

Generation uses the source derivatives and RK4 operation order. It burns in,
then retains the state **after** each subsequent integration step. It checks
finite state and the absolute-coordinate limit of `1e12` after every step,
including burn-in. Failure returns `SafetyBounds` with the source divergence
message. Independent `integrate` intentionally has neither that coordinate limit
nor the generation settings' step-size/work caps.

Each advance counts both burn-in and retained steps against the fixed 256-step
limit. Projected bounds update once per retained point. Final publication moves
the owned vector without scanning or copying samples. An exact 256-step chunk
boundary yields, including when all integration is done. The next advance can
therefore observe cancellation before publishing a completed trajectory.

The caller supplies a Rust-local atomic cancellation flag. The job checks it
before each step and immediately before publication. Cancellation discards
pending samples and returns terminal `Cancelled`, never a partial trajectory.
Repeated advances retain the same terminal success or error, even if the flag
later changes. The deterministic tests cover cancellation before work, during
burn-in, during retention and after the final integration chunk. They do not
claim exhaustive cross-thread race qualification.

One-step comparisons use `1e-12` per coordinate. Standard and half-step RK4
results differ by less than `1e-4` over the existing one-unit short horizon.
Projection fixtures keep the source `1e-15` tolerance. No long chaotic-orbit
bit identity, global tolerance or Dart cache-key string equivalence is claimed.

## Executed offline verification

Setup used pinned Flutter **3.47.9 / Dart 3.13.7**, matching
[`fdroid/flutter.version`](../../fdroid/flutter.version), Rust **1.95.0**, existing
isolated PUB/CARGO caches and private `TMPDIR`. Provisioned `/usr/bin/python3`
imports of `pytest`, `jinja2` and callable `markupsafe.soft_str` passed.
`flutter pub get --offline --enforce-lockfile` regenerated local package metadata
without changing locks.

Passing checks:

- `cargo test --manifest-path rust/Cargo.toml -p fractal-core --test trajectory --locked --offline`:
  **9 public cases** cover settings/schema validation, defaults/compatibility,
  one-step fixtures, convergence, projections, burn-in/bounds, distinct divergence
  guards, bounded synchronous/stepped parity, immutable retained results and cancellation.
- `autowork-run timeout 1200 scripts/ci/rust-check.sh`, with pinned Rust and isolated
  `CARGO_HOME`: formatting, denied-warning workspace clippy and **58 tests including
  doctests** passed. Existing Session unsupported-trajectory coverage passed unchanged.
- `flutter test --no-pub test/modules/attractor_trajectory_model_test.dart test/fractal/attractor_trajectory_compatibility_test.dart`:
  **13 unchanged Dart oracle tests** passed.

Final preservation, whitespace and scoped documentation/source readback results
are recorded in the worker report. The runner owns the separate merged-tree
full gate. No installed app, native/browser/device, GPU or production result is
claimed by these offline checks.

## Remaining ownership and reuse

Session trajectory ingress, snapshots, compatibility transactions and cancellation
ownership are still unported. So are LRU/cache policy, bridge/native request and
result transport, platform execution, renderer/app routing and the full M2 owner
switch. Later consumers must provide those boundaries before replacing Dart.
Hardware performance and live qualification remain separate migration gates.

This port reuses the Dart equations, schema, defaults and fixtures, the existing
serde/serde_json dependencies, standard owned vectors and the core's atomic-flag
job pattern. It adds no dependency, async runtime, cache framework, generated
output, persistence format or Session/bridge admission. Scoped Docs Sync Maintain
updates this component note only; the coordinator owns task/history closeout.
