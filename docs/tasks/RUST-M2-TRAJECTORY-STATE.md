# RUST-M2-TRAJECTORY-STATE — Inert Session trajectory metadata

## Result and boundary

The inert Rust [Session](../../rust/crates/fractal-core/src/session.rs) now owns
optional validated trajectory settings in detached snapshots. The
[camera helper](../../rust/crates/fractal-core/src/session_trajectory.rs) reuses the
[landed settings type and decoder](RUST-M2-TRAJECTORY.md#rust-local-api).
This implements the accepted [trajectory session state](RUST-PLAN-07.md#trajectory-session-state)
without executing RK4 work in `apply_batch`.

The three newly admitted module IDs are `thomas_attractor`, `four_wing` and
`lorenz_2d`. Their original complete catalog envelopes provide the default
version-1/rk4 settings. The seven existing module IDs remain supported.
The legacy `f0057_thomas_attractor` alias and other unsupported modules still
reject. Catalog admission is not a runtime registry or rendering certificate.

This note supersedes the unsupported-trajectory boundary recorded at the earlier
[Session](RUST-M2-SESSION.md) and [kernel](RUST-M2-TRAJECTORY.md) milestones.
Those receipts describe their own tested scope. This result is **not full M2**
and does not switch any production Dart owner or feature flag.

## Core ingress and snapshot contract

`CameraInput` retains `view: ViewInput` and `has_trajectory: bool`, and adds
`trajectory: Option<OrbitTrajectorySettings>`. Typed settings already satisfy the
landed validation rules. `Snapshot::trajectory()` returns an optional settings
copy. No mutable settings, sample storage or trajectory job escapes a snapshot.

Ingress without typed settings must mark every non-null trajectory using
`has_trajectory`. A true marker with no typed settings returns
`SessionError::UnsupportedTrajectory`. It never fabricates defaults or silently
drops unrepresented input. Typed settings are checked for compatibility with the
destination module, whether or not the presence marker is set.

Catalog default metadata uses the landed decoder. Missing or JSON null means a
legacy portrait. Non-null metadata must be an object, not a positional array or
other JSON value. Malformed settings return `UnsupportedTrajectory` before
publication. Valid settings for an incompatible system or projection clear to
`None`, as in the unchanged Dart controller.

| Operation | Metadata behavior |
| --- | --- |
| Construction or selection of a different module | Decode its original default preset, then keep only compatible settings. |
| Selection of the current module | Preserve the current view, unless `reset_view` is true. Initial overrides remain ignored. |
| Scalar zoom, pan, rotation, parameter edit or parameter reset | Preserve the current settings copy. |
| Full `View` | Replace metadata with the supplied compatible settings, or clear it for absence/incompatibility. |
| Ordinary preset | Apply its view against the current module, without switching modules. |
| Load | Apply supplied metadata against the destination module, not its default settings. This also applies to staged Number Walls loads. |
| `ResetView`, `ResetSession` or selection with `reset_view` | Clear metadata with the true initial view. |

The existing private-candidate transaction and Number Walls lifecycle are reused.
A failed batch cannot change metadata, effects, pending work, revision or retained
frame identity. Successful navigation retains the established cancellation rules.
There is no new request type or second transaction owner.

## Bridge boundary

The [private `StateCamera::into_core` mapping](../../rust/crates/fractal-bridge/src/api.rs)
sets `trajectory: None` and preserves the public presence marker. Therefore a bare
public `hasTrajectory=true` still rejects. Public Dart APIs, generated bridge
bytes, baseline envelopes, dependency manifests and locks are unchanged.
There is no public Dart trajectory ingress or snapshot transport in this result.

## Executed offline checks

Setup used Rust **1.95.0**, Flutter **3.47.9 / Dart 3.13.7**, existing isolated
CARGO/PUB caches and private `TMPDIR`. Flutter matched
[`fdroid/flutter.version`](../../fdroid/flutter.version). Provisioned
`/usr/bin/python3` imports of pytest, Jinja2 and callable `markupsafe.soft_str`
passed. `flutter pub get --offline --enforce-lockfile` changed no lockfile.

- Focused core command: `cargo test --manifest-path rust/Cargo.toml -p fractal-core --test session_trajectory --test session_replay --test session_effects --test session_number_wall --locked --offline`.
  **17 cases passed**, including four new public trajectory cases. They cover
  original defaults, missing/null metadata, incompatible settings, malformed
  metadata, custom settings retention, select/load/preset/full-view semantics,
  reset clearing, atomic rollback and retained Number Walls frame identity.
  All **68 original replay outputs** remain unchanged.
- `autowork-run timeout 1200 scripts/ci/rust-check.sh`, with pinned Rust and isolated
  `CARGO_HOME`: formatting, denied-warning workspace clippy and **77 tests including
  doctests passed**. Existing core and public bridge marker-rejection tests passed.
- `flutter test --no-pub test/fractal/attractor_trajectory_compatibility_test.dart test/modules/attractor_trajectory_model_test.dart test/migration/state_replay_test.dart`:
  **15 unchanged Dart tests passed**.

The worker report records preservation, whitespace, readback and scoped Docs Sync
checks. The runner owns the separate merged-tree full gate. No installed native,
device, browser, hardware, renderer or production qualification is claimed.

## Remaining proof and reuse

A generated trajectory bridge, trajectory job admission/execution, cancellation
transport, cache policy, app/persistence/render consumers and the whole-session
owner switch remain pending. Native/device/browser and hardware performance proof
remain separate. Core metadata ownership alone does not qualify those boundaries.

This change reuses the landed validated settings, decoder and compatibility check,
original catalog records, scalar normalizer, detached snapshots and transaction
owner. It adds no dependency, generated output, cache, executor or app route.
Scoped Docs Sync Maintain updates this component note only. Shared planning,
task/history closeout and the closeout Docs Sync pass remain coordinator-owned.
