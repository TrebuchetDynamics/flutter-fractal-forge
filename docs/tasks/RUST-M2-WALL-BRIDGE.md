# RUST-M2-WALL-BRIDGE — Bounded exact Number Walls transport

## Delivered boundary

The inert [bridge API](../../rust/crates/fractal-bridge/src/api.rs) now exposes the
existing core Number Walls request lifecycle. It does not change mathematical,
certification, revision, or publication policy. It reuses the existing session
mutex, core request guard/token/job, immutable certified frame, and FRB transport.
No dependency, saved format, app adapter, renderer, flag, or build rule changed.

This implements the transport cut in
[RUST-PLAN-06](RUST-PLAN-06.md#bounded-number-walls-transport). The
[planned Rust ownership boundary](../engineering/spec.md#planned-rust-engine-boundary)
and [Number Walls replay boundary](../engineering/spec.md#number-walls-replay-validation-boundary)
remain unchanged. This is not a production off-UI executor or full M2 qualification.

## Public API and ownership

Rust names below generate the corresponding camelCase Dart methods in
[`api.dart`](../../packages/fractal_engine_bridge/lib/src/rust/api.dart).

| API | Contract |
| --- | --- |
| `StateCommand::number_wall_prime(value)` | Fresh typed prime-edit command. Generic `param("prime", ...)` is not the core prime-edit path. Pass this command through begin to certify it. |
| `StateNumberWallGuard::new(active)`, `is_active()`, `revoke()` | Separate opaque guard. Revocation is monotonic, delegates to the core atomic, and takes no session lock. Begin borrows the guard and clones its core ownership. |
| `StateSession::begin_number_wall(session_id, expected_revision, command, request_guard, max_trial_divisions)` | Consumes one fresh command and returns an optional owned opaque `StateNumberWallRequest`. Inactive/revoked guards do nothing. Immediate commands use core's ordinary transaction and return no request. Deferred commands stage complete ingress without publishing an uncertified frame. |
| `advance_number_wall(session_id, expected_revision, request, work_limit)` | Borrows a repeatable request. Delegates exactly once to the existing bounded core step. Zero work still observes revocation. No drain loop, callback, sleep, thread, or async runtime. |
| `cancel_number_wall(session_id, expected_revision, request)` | Borrows the request. Old requests cannot cancel a successor. |
| `StateNumberWallProgress::is_pending()`, `status()`, `snapshot()` | Owned opaque result. Progress and detached snapshot are captured under the same session lock. Each snapshot getter returns another detached handle. |
| `StateSnapshot::number_wall_pending()`, `number_wall_status()`, `number_wall_frame()` | Pending presence, optional typed terminal status, and optional owned read-only retained frame. |
| `StateNumberWallFrame` getters | Detached params, typed sequence, decimal modulus, row/column counts, column origin, inclusive support endpoints, and complete nested decimal-string `values()`. No per-cell FFI. |

`StateNumberWallStatus` has `VerifiedPrime`, `Composite`, `Invalid`, `Unverified`,
and `Cancelled`. Pending progress has no terminal status. An old request can
report `Cancelled` while its same-lock snapshot still contains a pending successor.
Callers must not confuse that request result with the current snapshot's status.

`StateNumberWallSequence` maps all six core sequences: `SignedPagoda`, `Rook`,
`ThueMorse`, `RudinShapiro`, `Fibonacci`, and `Squares`.

Session identity and expected revision stay `u64` / Dart `BigInt`, with unsigned
64-bit SSE codecs. Trial budget and work limit are `u32` / Dart `int`, with a checked
conversion of work limit to core `usize`. Core still limits grid advances to 1024
scalar units and prime advances to one bounded chunk. Indivisible bigint operations
are not a wall-clock time guarantee. Dimensions use checked `u32` conversions of
bounded certified core grids. Origin/support retain signed 64-bit transport.
Modulus and every cell remain strings, never `f64` / Dart `double`.

Only a retained certified core frame can create a frame handle. Requests have no
public constructor. Neither frames nor requests expose token, certificate,
identity, revision, or grid setters. Existing command constructors and methods are
preserved. Generated bindings borrow guard/request arguments and consume ordinary
commands, including failed calls. Never reuse a consumed command or value handle.
Retain request handles across steps, then dispose unneeded owned opaque handles
through FRB's existing lifecycle. Disposing a handle is not session shutdown.

Shutdown drops pending work and remains idempotent. Session operations after close
reject. Previously returned progress, snapshots, frames, and detached collections
remain readable after navigation or shutdown. Invalid/composite/unverified work
retains last-good settings and frame. Mixed synchronous deferred batches still
reject atomically.

## Executed offline checks

Setup selected the existing isolated Flutter 3.47.9 / Dart 3.13.7, Rust 1.95.0,
FRB 2.11.1, cargo-expand 1.0.127, `PUB_CACHE=$AUTOWORK_CACHE/pub-cache`, and
`CARGO_HOME=$AUTOWORK_CACHE/cargo-1.95.0`. Flutter matches `fdroid/flutter.version`.
Provisioned `/usr/bin/python3` imported pytest, Jinja2, and callable
`markupsafe.soft_str`. `flutter pub get --offline --enforce-lockfile` regenerated
checkout-local metadata without lock changes. No installation or ambient-cache
fallback was needed. APK compilation used the existing target-enabled compiler:
`RUSTC=$AUTOWORK_CACHE/rustup-1.95.0/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin/rustc`.

| Command / check | Result |
| --- | --- |
| `cargo test --manifest-path rust/Cargo.toml -p fractal-bridge --test state_number_wall --test state_effects --test state_session --locked --offline` | Pass: 4 new boundary tests and 7 existing regression tests. |
| `autowork-run timeout --kill-after=10s 900 scripts/ci/rust-check.sh` | Pass: fmt, clippy with denied warnings, 52 workspace tests and 1 compile-fail doc test. |
| `flutter_rust_bridge_codegen generate --config-file flutter_rust_bridge.yaml`, twice; compare complete inventories | Pass: identical five-file SHA-256 inventories below. |
| `flutter analyze --no-pub packages/fractal_engine_bridge/lib` | Pass: no issues. |
| `flutter test --no-pub test/migration/rust_engine_adapter_test.dart` | Pass: 3 tests. |
| `autowork-run timeout --kill-after=10s 900 /usr/bin/python3 scripts/migration/run_state_session_smoke.py -- flutter build linux --debug --no-pub --dart-define=RUST_CORE=true -t integration_test/migration/rust_state_session_smoke_test.dart` | Pass: existing scalar fixture compiled, not executed. |
| `autowork-run timeout --kill-after=10s 1200 /usr/bin/python3 scripts/migration/run_state_session_smoke.py -- flutter build apk --debug --no-pub --target-platform android-x64 --dart-define=RUST_CORE=true -t integration_test/migration/rust_state_session_smoke_test.dart` | Pass with the target-enabled `RUSTC` above: compiled, not installed. Existing Java/Gradle warnings did not disable validation. |
| `autowork-run timeout --kill-after=10s 900 flutter build web --debug --no-pub --dart-define=RUST_CORE=false` | Pass. |
| Same Web command with `--dart-define=RUST_CORE=true` | Pass. Neither is browser execution or Rust/WASM qualification. |
| `git diff --exit-code -- lib migration/baseline integration_test scripts rust/crates/fractal-core flutter_rust_bridge.yaml rust/Cargo.lock pubspec.lock` and `git diff --check` | Pass: excluded owners and locks unchanged, no whitespace errors. |
| Scoped API/generated inventory, one-step delegation, ownership/codec, local-link/anchor and result-note readback | Pass. |
| Bundled `docs.py stale .` and `docs.py check .` | Pass with `no manifest at docs/roles.json`; no repository-wide semantic coverage claimed. |

The [public tests](../../rust/crates/fractal-bridge/tests/state_number_wall.rs) were
added first and failed because the transport methods did not exist. They now
compare each bounded advance with direct core using the original four envelopes,
including full-grid, dimensions, support and canonical prime publication. They
also cover failed certification retention, detached collections, inactive/revoked
guards, supersession, edit/navigation/cancel, wrong/stale operands, cross-session
requests, mixed-batch rollback, duplicate shutdown, and retained post-close reads.
These are Rust public-boundary tests, not executed Dart/native assertions.
The coordinator's merged-tree full integration gate is separate and was not run here.

### Complete generated inventory

`flutter_rust_bridge.yaml` remains the authority for all five outputs, including Web.
Both generations produced these SHA-256 values:

| Path | SHA-256 |
| --- | --- |
| `rust/crates/fractal-bridge/src/frb_generated.rs` | `f538102c32c8639a575eef9e4f6d52047dbdb0060f77698ff0177a5905125f0a` |
| `packages/fractal_engine_bridge/lib/src/rust/api.dart` | `68e6c6283e4528d2b111fc61d0a44484523c335c79c826a453b924f45aa5d2b3` |
| `packages/fractal_engine_bridge/lib/src/rust/frb_generated.dart` | `737dbaf4925470f49d5cb93e4bd7f643d8ca0bfec464e81a0279bf595a86c862` |
| `packages/fractal_engine_bridge/lib/src/rust/frb_generated.io.dart` | `96fa9bfd6044b1048bae8c0c07f27b2b4caadcda2d515d86671c3ca3b58cc6bb` |
| `packages/fractal_engine_bridge/lib/src/rust/frb_generated.web.dart` | `a48b40a5c022d383f707c813172e49a4ca8be4130483b938dfd84354ce2e4588` |

## Remaining proof and scoped Docs Sync Maintain

Maintain updates only this designated component result/API/gap note. The shared
specification's ownership and replay requirements were inspected and preserved.
No README, PRD, architecture decision, saved-format contract, or runbook behavior
changes are needed for this inert package seam. The CHANGELOG proposal is returned
to the coordinator rather than editing shared history. Scoped readback checks the
links, anchors, APIs, five hashes, ownership codecs, and one-step delegation.

[RUST-M2-EXTENDED-FIXTURE](RUST-PLAN-06.md#extended-native-fixture-producer) can now
consume this API. Production off-UI execution, installed new-method Linux/Waydroid
round trips, reachable successful high-u64 outputs, full-session/M2 acceptance,
actual browser execution, and hardware/rendering/performance qualification remain
separate. The old scalar Linux/APK fixture never calls the new methods. Its builds
prove regression linkage only. No installed execution, speedup, flag enablement,
publication, or migration-goal completion is claimed.
