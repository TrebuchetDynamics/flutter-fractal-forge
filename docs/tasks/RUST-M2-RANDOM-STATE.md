# RUST-M2-RANDOM-STATE — Seeded Session randomization and wall undo

## Result and boundary

The inert [Session](../../rust/crates/fractal-core/src/session.rs) owns immediate
seeded ordinary randomization and staged Number Walls randomization with one undo.
This is a core implementation for coordinator integration, not an app owner switch
or full M2 qualification. The [accepted design](RUST-PLAN-08.md#staged-session-randomization-and-undo),
[planned engine boundary](../engineering/spec.md#planned-rust-engine-boundary) and
[exact ingress boundary](../engineering/spec.md#number-walls-replay-validation-boundary)
remain unchanged.

## Rust-local API and publication

The [randomization owner](../../rust/crates/fractal-core/src/session_randomization.rs)
adds these identity/revision-checked seams:

- `randomize_params(id, revision, seed)` returns `Result<Snapshot, SessionError>`.
  Ordinary modules commit the complete seeded target in one revision, retaining
  camera, transparency and effects. This cancels pending wall work and the parameter
  timeline. Number Walls returns `DeferredOperation` instead of bypassing validation.
- `begin_number_wall_randomization(id, revision, seed, guard, max_trial_divisions)`
  returns `Result<Option<RequestToken>, SessionError>`. A non-wall module, missing
  committed frame or inactive guard returns `None` without publication.
  Accepted work uses the existing [begin/advance/cancel lifecycle](RUST-M2-INGRESS.md#rust-local-api).
  It captures the committed frame, not a pending target, and stages normalized
  seeded params with the current camera and transparency. No job is drained at begin.
- `undo_number_wall_randomization(id, revision)` returns `Result<bool, SessionError>`.
  One successful undo cancels pending work and restores the exact previous params
  and certified frame atomically. Current camera and transparency remain unchanged.
  Status becomes verified prime. Undo consumes one revision. Without an available
  wall undo, it returns false without publication, including on the second call.
- `Snapshot::can_undo_number_wall_randomization()` reports availability without
  exposing the private stored frame or pending provenance.

The [pure target helpers](RUST-M2-SEEDED-RANDOM.md#public-api-and-source) still serve
independent callers, including the parameter timeline. They retain schema draw
order, palette preservation, wall seed masking and explicit modulus opt-in.
Target errors return `SessionError::Randomization` before any live state changes.
Synthetic schemas remain pure-helper test inputs, never admitted Session modules.

The [wall request owner](../../rust/crates/fractal-core/src/session_number_wall.rs)
keeps randomization provenance private to each pending request. Only that request's
successful certified-frame publication installs its captured frame as undo.
Ordinary loads cannot gain randomization provenance from matching parameters.
Rejected, cancelled, revoked and superseded requests cannot replace prior undo.

Undo is part of the private cloned candidate state. Failed ordered batches preserve
both undo and the live request, including its provenance. Revision overflow and
wrong/stale ownership reject before mutation. Existing admission and terminal
revision reservations remain in force. Undo can cancel pending work in the final
available revision without leaving a request unable to terminate.

Source behavior follows [FractalController](../../lib/core/controllers/fractal_controller.dart),
not a blanket clearing policy. Wall loads, presets, resets, parameter edits and
same-module selection retain undo. Navigation to an ordinary module by selection
or load clears undo, while retaining the last wall frame independently.
Returning to Number Walls cannot revive the cleared undo.

## Executed offline verification

Setup used Rust 1.95.0 and isolated CARGO_HOME, Flutter 3.47.9 / Dart 3.13.7 matching
[the pin](../../fdroid/flutter.version), isolated PUB_CACHE and private TMPDIR.
Provisioned `/usr/bin/python3` imports passed for pytest, jinja2 and
`markupsafe.soft_str`. `flutter pub get --offline --enforce-lockfile` regenerated
checkout-local metadata without changing the lockfile.

- The [public randomization tests](../../rust/crates/fractal-core/tests/session_randomization.rs)
  consume all 12 applicable ordinary cases, all 15 wall cases and all 18 ordered
  unsuccessful actions from the unchanged [oracle](../../migration/oracles/randomization.json).
  They compare typed params, status, exact cells/support and current-view undo.
  Additional continuations cover failed-batch provenance, successful replacement,
  revoked work, undo while pending, inactive admission and source retention/clearing.
- `cargo test --manifest-path rust/Cargo.toml -p fractal-core --test session_randomization --test session_replay --test session_number_wall --locked --offline`:
  13 tests passed. The unchanged replay assertions compare all 68 original outputs
  twice, including last-good state and expectation-drift rejection.
- `autowork-run timeout 1200 scripts/ci/rust-check.sh`, with pinned Rust/CARGO_HOME:
  formatting, denied-warning workspace clippy and 101 tests including doctests passed.
  The existing overflow test also checks randomization admission, final-revision
  pending undo and preservation of undo after overflow rejection.
- `autowork-run timeout 1200 flutter test --no-pub test/migration/randomization_oracle_test.dart test/number_walls/number_wall_state_test.dart`:
  all 8 Dart tests passed. Original source bindings and fixtures remain unchanged.

## Reuse, documentation and remaining proof

This scoped Docs Sync Maintain pass adds only this component note. Existing shared
specification, planning records and release history remain with their owners.
The worker report records preservation, documentation readback and link checks.
The coordinator owns final documentation reconciliation and the merged-tree gate.

Implementation reuses typed targets, shared normalization, cloned transactions,
immutable certified frames and bounded frame jobs. No dependencies, manifests,
locks, fixtures, production Dart, bridge code or flags changed.
No entropy service, animation scheduler, generated/app route or executor was added.
The independent parameter timeline remains separate from this immediate commit seam.
Native/browser transport, installed-app behavior, hardware performance and full-M2
qualification remain separate work. No live or production acceptance is claimed.
