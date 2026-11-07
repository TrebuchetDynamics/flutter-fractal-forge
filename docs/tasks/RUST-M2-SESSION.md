# RUST-M2-SESSION — Transactional ordinary candidate sessions

## Scope and status

Implemented locally for coordinator review and integration. This is inert M2
preparation, **not M2 completion**, full-session parity or an app owner switch.
The [accepted interfaces](RUST-PLAN-03.md#decided-interfaces-and-error-semantics)
and [migration plan](../planning/refactor-plan.md#flutter-shell-and-rust-engine-migration)
remain authoritative. The specification's [state and persistence](../engineering/spec.md#state-and-persistence),
[planned Rust boundary](../engineering/spec.md#planned-rust-engine-boundary) and
[Number Walls validation boundary](../engineering/spec.md#number-walls-replay-validation-boundary)
are unchanged.

## Public API and supported boundary

[`fractal_core::session`](../../rust/crates/fractal-core/src/session.rs) is exported
from [`lib.rs`](../../rust/crates/fractal-core/src/lib.rs).

- `Session::new(catalog: Arc<CatalogBaseline>, session_id: u64, module_id: &str)`
  returns `Result<Session, SessionError>`. It consumes a shared, read-only
  [validated catalog](RUST-M3-CATALOG-PARITY.md#api-and-preservation), not a runtime
  registry. Callers load the four original `modules`, `parameters`, `presets` and
  `capabilities` envelopes once. Identity allocation belongs to the caller.
- The only supported module IDs are `mandelbrot`, `julia`, `cantor_set` and
  `recursive_sine_sphere`. Construction starts at revision zero, using the selected
  module's normalized default preset and view, with transparency off.
- `Session::snapshot() -> Snapshot` returns a detached copy with private fields.
  Its getters expose `session_id()`, `revision()`, `module_id()`, `params()`,
  `view()`, `transparent_background()` and `last_adaptive_zoom()`.
  Parameters use `ParameterValue`; view uses `FiniteView`.
- `Session::apply_batch(session_id: u64, expected_revision: u64, commands: &[Command])`
  returns `Result<Snapshot, SessionError>`. Commands run in order on a private
  candidate. Success publishes once. Every nonempty success increments the checked
  u64 revision once, including valid no-ops and resets. Empty batches retain the
  revision but still check identity and revision.
- `RawParams` is `BTreeMap<String, RawScalar>`. Parameter and scalar view inputs
  reuse the [normalization API](RUST-M2-NORMALIZATION.md#public-api), including its
  nonfinite/default policy. No callback into Dart or duplicate normalizer is used.
- `CameraInput { view: ViewInput, has_trajectory: bool }` explicitly records
  unsupported trajectory presence. Ingress must set `has_trajectory` for every
  non-null trajectory. Such inputs fail, rather than silently losing trajectory
  state. Catalog default views also receive this check.

| Typed command | Ordinary behavior |
|---|---|
| `Zoom`, `Pan`, `Rotation` | Normalize scalar inputs. Zoom retains incremental adaptive-iteration history; commands are never coalesced. |
| `View { camera, adaptive }` | Normalize the complete scalar view. Adapt only when requested; always synchronize zoom history. |
| `Param { id, value }` | Normalize known parameters. Unknown parameter IDs are valid no-ops, as in Dart. |
| `SelectModule { module_id, reset_view, initial_params }` | On a change, merge schema defaults, module default preset, then explicit overrides. Apply the default preset view. `reset_view` uses the true initial view instead. Selecting the same module is a no-op unless resetting its view; initial overrides are then ignored. |
| `Transparent` | Set transparency; setting the existing value is a valid no-op. |
| `ApplyPreset { module_id, params, camera }` | Match the ordinary Dart API: normalize supplied values against the current module's schema defaults and apply the camera. A supported preset module ID does not itself select another module. Transparency stays unchanged. |
| `Load { module_id, params, camera, transparent }` | Select the explicit target, or retain the current module for `None`. Missing parameters use schema defaults, not default-preset values. Normalize the camera, synchronize history and set transparency. |
| `ResetParams` | Restore normalized module default-preset parameters, preserving the camera and transparency. |
| `ResetView` | Restore zoom 1, zero pan/rotation and synchronized zoom history, preserving parameters and transparency. |
| `ResetSession` | Keep the module, restore default-preset parameters, use the true initial view and clear transparency. Revision increments normally. |
| `Unsupported { operation }` | Reject visibly with `UnsupportedOperation`; never ignore an unported operation. |

Adaptive iteration updates port the actual Dart two-dimensional integer-iteration
policy: zoom-in threshold 1.01, 48 iterations per zoom octave, target snapping to
four, and bounded incremental steps of 8/16/32/64. No adaptive update occurs for
the supported three-dimensional module. Invalid parameter values still normalize;
they do not introduce a new transaction rejection policy.

`WrongSession`, `StaleRevision`, `RevisionOverflow`, `UnsupportedModule`,
`UnsupportedTrajectory`, `UnsupportedOperation` and `InvalidCatalog` reject
without publishing any part of a candidate. `InvalidCatalog` covers missing module
records or unusable default-camera numbers. Unknown module IDs and catalog IDs
such as `core.mandelbrot` are not legacy fallback aliases. Number Walls, effects,
kaleidoscope, randomization, trajectories and physical gesture transforms remain
unsupported. This API owns no history store, serializer or asynchronous validator.

## Replay and negative checks

The [public-seam replay test](../../rust/crates/fractal-core/tests/session_replay.rs)
reads the original [state replay](../../migration/baseline/state-replay.json) and
four original catalog envelopes directly. It builds typed commands from inputs.
History save/restore uses snapshot/load in the harness. The harness also supplies
legacy epoch, ID, nullable name, preset metadata, results and null Number Walls
fields. Expected data never supplies candidate state.

Both runs of events **0–46 inclusive** match every original result, history,
view, parameter, transparency and Number Walls field through strict JSON value
equality, without a numeric tolerance. The test rejects an altered expected zoom.
It asserts 68 total events, event 46's `param`/`animate` operation and event 47's
`load`/`number_wall` operation. It does not report a skipped full replay as parity.
Misleading infinity labels do not override original values: parameter events
8/9/12/13 use schema defaults, not extrema.

All events **47–67 remain unported**, including the ordinary-looking events at the
end because their state retains Number Walls history:

- 47–56: exact decimal ingress, enum/boolean ingress, saved wall history, forged
  certification, composite/oversized/unverified moduli and public prime Apply.
- 57–60: overlapping loads, stale completion and certified history restoration.
- 61–66: navigation/edit cancellation of pending cross-module candidates.
- 67: final ordinary reset while prior Number Walls state remains observable.

| Check | Actual result |
|---|---|
| `cargo test --manifest-path rust/Cargo.toml -p fractal-core --test session_replay --locked --offline` | Passed: three focused tests. Original prefix replay runs twice with strict comparison and expectation-drift rejection. Ordered batches match singleton state and adaptive history, including mixed preset/load/view/reset commands, defaults, overrides and valid no-ops. Wrong identity, stale revision, unsupported module/trajectory/operation and rejected-candidate history leakage are checked atomically. Retained snapshots and other sessions stay unchanged. |
| `autowork-run scripts/ci/rust-check.sh` | Passed: formatting, denied-warning clippy, all 16 workspace tests and doc-test targets. The overflow unit test sets only the private test revision near u64 exhaustion, then exercises public `apply_batch`: last increment succeeds, empty remains unchanged and overflow rejects atomically. Production construction has no revision override. Core/render dependency guards still pass. |
| `autowork-run timeout 600 flutter test --no-pub test/migration/state_replay_test.dart test/fractal/fractal_controller_behavior_test.dart test/fractal/fractal_controller_reset_session_test.dart test/core/controllers/fractal_controller_state_exposure_test.dart` | Passed: all 12 tests. These preserve the working Dart oracle, adaptive behavior, resets and state exposure. They do not route through the candidate API. |
| `git diff --exit-code -- migration/baseline lib test/migration && git diff --check` | Passed. Baseline and Dart bytes are unchanged. Additional readback confirms manifests, locks, generated output and normative spec are unchanged. |
| Scoped Docs Sync Maintain readback | Passed: local note links/anchors and documented API/command/support boundaries checked against source, tests and actual outputs. Docs Sync `stale`/`check` report no role manifest, so they provide no link coverage; a separate scoped link/anchor check covers this note. |

Checks use existing Rust 1.95.0 on `PATH`,
`CARGO_HOME="$AUTOWORK_CACHE/cargo-1.95.0"` and private `TMPDIR`.
Pinned Flutter 3.47.9 matches `fdroid/flutter.version`; Dart is 3.13.7.
System Python 3.12.3 imports pytest 9.0.2, Jinja2 3.1.6 and
`markupsafe.soft_str`. `flutter pub get --offline --enforce-lockfile` regenerated
checkout-local metadata without changing `pubspec.lock`.
The merged-tree full offline gate belongs to the runner and was not run here.

## Reuse and remaining proof

This change adds only the session module/export, its focused tests and this note.
It reuses `CatalogBaseline`, the locked Serde graph, `RawScalar`, `ParameterValue`,
`FiniteView`, normalization functions and the original M0 oracle. It adds no
dependency, copied fixture, generated output or persistence-format change.
Scoped Docs Sync Maintain updates this designated API/check/gap owner only.
Shared task records, history and normative specification remain unchanged.

RUST-M2-BRIDGE is the next consumer. No app session, gesture, controller, registry,
renderer or export path uses this candidate. Full-session replay, exact asynchronous
Number Walls certification/cancellation, effects/kaleidoscope/randomization,
trajectories, installed native state transport, physical-input transforms and
hardware/browser qualification remain missing. The
[remaining proof map](RUST-PLAN-03.md#remaining-proof-and-continuation) still applies.
Rejecting Number Walls is not certification and cannot replace its required proof.
These offline results authorize neither runtime ownership nor M2 qualification.
