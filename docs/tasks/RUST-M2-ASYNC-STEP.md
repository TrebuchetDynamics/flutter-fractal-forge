# RUST-M2-ASYNC-STEP — Off-UI bounded request transport

## Result and boundary

Implements the [accepted transport slice](RUST-PLAN-07.md#off-ui-bounded-request-transport)
on baseline `54f4605ca5f77b57f3292860a503436d4cde7a2f`. The existing
[Number Walls bridge](RUST-M2-WALL-BRIDGE.md) and synchronous methods remain intact.
The separate [Future fixture](../../integration_test/migration/rust_state_async_smoke_test.dart)
is analyzed and compiled for Linux and Android x86_64. **Its Dart/native assertions
are unexecuted.** No fixture was installed or executed, and no device or browser
was used. Both Web root flag builds pass.

This is dispatch wiring and offline implementation/build evidence, not measured
UI responsiveness, production scheduling, high-u64 round-trip, hardware, full
session or full-M2 qualification. The app, adapter, renderer and flag routing are
unchanged.

## Methods and ownership

[`StateSession`](../../rust/crates/fractal-bridge/src/api.rs) adds five ordinary
Rust functions, without `async fn` or `#[frb(sync)]`:

| Rust method | Generated Dart method/result |
| --- | --- |
| `begin_number_wall_async` | `beginNumberWallAsync`: `Future<StateNumberWallRequest?>` |
| `advance_number_wall_async` | `advanceNumberWallAsync`: `Future<StateNumberWallProgress>` |
| `cancel_number_wall_async` | `cancelNumberWallAsync`: `Future<StateNumberWallProgress>` |
| `snapshot_async` | `snapshotAsync`: `Future<StateSnapshot>` |
| `shutdown_async` | `shutdownAsync`: `Future<void>` |

Each sync/normal pair delegates to one private `*_impl` body. Those bodies preserve
the original mutex, identity/revision checks at execution, closed/poisoned errors,
revocation and core policies. Advance calls core exactly once with the supplied
work limit; zero work still observes revocation. Progress and its detached snapshot
are captured under the same session lock. There is no retry, coalescing or job
draining. Close drops the owned core state, is idempotent, and makes later calls
reject while retained snapshots/frames remain readable.

Generated Rust uses `wrap_normal`/`FfiCallMode::Normal` for all five new methods;
existing sync methods retain `wrap_sync`. Readback of the locked FRB **2.11.1**
`handler/implementation/handler.rs::wrap_normal` and
`executor.rs::execute_normal` confirms dispatch through the existing
`thread_pool.execute`. Session/request/guard borrow decoding occurs in the pool
task closure, before the shared implementation acquires the session mutex. No new
runtime, pool, service or scheduler is introduced. FRB's existing async runtime is
not used by these ordinary functions.

Request, guard and session arguments use generated `Auto_Ref` codecs (`move: false`)
and remain borrowed through the awaited call. Commands and their `StateValue`
payloads use owned codecs and are fresh consumed inputs, including on rejection.
The fixture retains and disposes every returned progress, snapshot, request, guard
and frame; parameter getter values are disposed after readback. It awaits shutdown
before disposing session handles. Guard revocation remains synchronous and lock-free.
Callers must not dispose borrowed handles while their Futures are outstanding.

## Assertion inventory and reuse

The four existing [public Rust cases](../../rust/crates/fractal-bridge/tests/state_number_wall.rs)
now run through both sync and normal entry points. This reuses the original core
oracle and lifecycle assertions rather than duplicating tests. Each bounded step,
canonical exact frame, pending/terminal revision, rejected result, rollback,
inactive/revoked guard, supersession, cancellation, navigation, wrong identity,
stale revision and retained closed state is checked through both variants.

One additional channel-ordered public case captures operands before another call
supersedes the request. The released worker rejects all three stale operations,
then observes the superseded token without changing the successor. A second
channel handoff orders close before later snapshot/begin/advance/cancel calls;
all reject, duplicate close succeeds, and certified retained frames survive.
There are no sleeps. These direct Rust calls prove the imposed order, not FRB
queue fairness or native UI responsiveness.

The Future fixture has two cases, adapted from the unchanged extended fixture:

1. Await staging and zero/one/bounded work for all six sequences; compare settings,
   support, dimensions and every exact decimal grid cell with the existing Dart
   `NumberWallFrame.prepare` oracle. Invalid, composite and budget-zero unverified
   results preserve certified state.
2. Await inactive/revoked guards, supersession, stale/wrong identity and foreign
   requests, cancellation, navigation, immediate begin, snapshot and duplicate
   shutdown. Retain atomic deferred-batch rejection and detached frame reads after
   close, finish an independent session, and clean up owned handles.

The fixture reuses the existing `--extended` launch protocol, hash guard, Dart
frame/model oracle and locked crypto dependency. No catalog is copied, no old
target bytes change, and no core semantics, dependencies, locks, schemas or build
rules change. Eleven-effect parity remains in the separate extended target; this
fixture does not duplicate that unrelated case.

## Input, source and artifact identities

Target: `integration_test/migration/rust_state_async_smoke_test.dart`, SHA-256
`bfecda61999fd34108402537b0122b199a87b6c8a4e2641868be4e40cef69a24`.
Unchanged launcher: `scripts/migration/run_state_session_smoke.py`, SHA-256
`459e5cb13db5b00aace7e4e69214b158432dac6d624c39dce4be034f92cd7154`.
The unchanged extended target retains SHA-256
`073bb9ea74626e65647dab25a4cf301d9d6f81b2115b715bf45467c9fbdd77bc`.

Both native build logs record the same seven-module projection and
**12288/32768 Flutter-encoded bytes**, including `RUST_CORE=true`. Original
provenance, complete records/number lexemes, the inclusive aggregate cap and
fail-closed override/define guards remain as documented in the
[extended producer](RUST-M2-EXTENDED-FIXTURE.md#inputs-and-identities).

| Input | Extended SHA-256 | Bytes |
| --- | --- | ---: |
| modules | `afc6f18acd52dfdf6d11029c5d46a889f4e07393a5a9fa521a9c7e4f719a3c0f` | 3575 |
| parameters | `46ab96397b86b330462671b2f1374257dba15bf25ec81e65630cc960c689923d` | 24679 |
| presets | `d7bb5a2651467e00414c1dbad5fb107ac666b3962e5331be9280df88e739dc87` | 12092 |
| capabilities | `f29b25e6dd11ba3e53f1aea551488d263c3f3a98973fe0bf33be2180c796959c` | 13341 |

These checkout-local artifacts were inspected, not installed:

| Artifact | SHA-256 |
| --- | --- |
| `build/linux/x64/debug/bundle/flutter_fractals` | `5e495f71c85f7d209a780b09c2faa1ffd51431299ca743aff3f262e9b8aaa9cf` |
| `build/linux/x64/debug/bundle/data/flutter_assets/kernel_blob.bin` | `163354759b6a987179214a6e84ad84ea5c6c26a5f2df99aaeec0689ae4d1415c` |
| `build/linux/x64/debug/bundle/lib/libfractal_bridge.so` | `d8b2d90ae90a2a35d69ff1d39991bf470445ce3e0fa10bf26d956bf0843ad5b6` |
| `build/app/outputs/flutter-apk/app-debug.apk` | `e4a89d14e616812780486a7817ea2bcf76441a351f86c23f1cf14559b694460b` |
| APK member `lib/x86_64/libfractal_bridge.so` | `921a078dde03e3ed26087b669463b1e19a61ac74094595b0a346269a42c5da5d` |

The APK's `assets/flutter_assets/kernel_blob.bin` has the same kernel hash as Linux.

## Executed offline checks

Setup: existing Flutter **3.47.9 / Dart 3.13.7**, matching `fdroid/flutter.version`;
Rust **1.95.0**; isolated `PUB_CACHE=$AUTOWORK_CACHE/pub-cache` and
`CARGO_HOME=$AUTOWORK_CACHE/cargo-1.95.0`; provisioned `/usr/bin/python3` pytest,
Jinja2 and callable MarkupSafe `soft_str` imports. Offline lockfile-enforced Pub
resolution passed without changing locks. No installs or profile changes.

Long checks used `autowork-run timeout --kill-after=10s` (900 seconds; 1200 for APK).
Commands below ran from the checkout root with the pinned tools on PATH:

| Command | Final result |
| --- | --- |
| `cargo test --manifest-path rust/Cargo.toml -p fractal-bridge --test state_number_wall --test state_session --test state_effects --locked --offline` | Pass: 12 tests; the four original wall cases cover both entry points. |
| `scripts/ci/rust-check.sh` | Pass: fmt, clippy with denied warnings, 80 tests including the compile-fail doc test. |
| `flutter_rust_bridge_codegen generate --config-file flutter_rust_bridge.yaml`, twice | Pass: FRB 2.11.1/cargo-expand 1.0.127; equal complete five-file inventories below. |
| `flutter analyze --no-pub packages/fractal_engine_bridge/lib integration_test/migration/rust_state_async_smoke_test.dart` | Pass: no issues. |
| `flutter test --no-pub test/migration/rust_engine_adapter_test.dart` | Pass: 3 tests. |
| `/usr/bin/python3 -m pytest -q scripts/migration/tests/test_state_session_smoke.py` | Pass: 8 cases; protocol/provenance/aggregate guards unchanged. |
| `/usr/bin/python3 scripts/migration/run_state_session_smoke.py --extended -- flutter build linux --debug --no-pub --dart-define=RUST_CORE=true -t integration_test/migration/rust_state_async_smoke_test.dart` | Pass: compiled only, native library present. |
| `RUSTC="$AUTOWORK_CACHE/rustup-1.95.0/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin/rustc" /usr/bin/python3 scripts/migration/run_state_session_smoke.py --extended -- flutter build apk --debug --no-pub --target-platform android-x64 --dart-define=RUST_CORE=true -t integration_test/migration/rust_state_async_smoke_test.dart` | Pass: compiled only; x86_64 native library present. Existing Java 8 source/target warnings remain warnings. |
| `flutter build web --debug --no-pub --dart-define=RUST_CORE=false && flutter build web --debug --no-pub --dart-define=RUST_CORE=true` | Pass: both root builds; no browser execution. |
| `git diff --exit-code -- lib migration/baseline scripts integration_test/migration/rust_state_session_smoke_test.dart integration_test/migration/rust_state_extended_smoke_test.dart rust/crates/fractal-core rust/Cargo.lock pubspec.lock flutter_rust_bridge.yaml && git diff --check` | Pass: preserved sources/locks and clean whitespace. |
| Scoped source/artifact/doc readback | Pass: all five normal wrappers, pool dispatch, borrowed/owned codecs, complete inventories, source/artifact/input hashes and this note's links/anchors. |
| Bundled Docs Sync `docs.py stale .` and `docs.py check .` | Pass: no `docs/roles.json`; no repository-wide coverage is claimed. Scoped readback covers this note. |

The Android build uses the already cached target-enabled Rust compiler, not a new
target installation. The runner owns the merged-tree integration gate; this worker
did not run the full offline gate.

### Complete deterministic generated inventory

Both generations produced these SHA-256 values. The `.io.dart` and `.web.dart`
outputs were regenerated but remain byte-identical to baseline.

| Path | SHA-256 |
| --- | --- |
| `rust/crates/fractal-bridge/src/frb_generated.rs` | `fde780430ad5d3f0ea100fdbdf4194199010b64376b4019d85296d2023c771ec` |
| `packages/fractal_engine_bridge/lib/src/rust/api.dart` | `238e70a52f28a3ca839cd4e9e3d4ad45f0d4f34d52b9e63a9c4353ce3c02fbfb` |
| `packages/fractal_engine_bridge/lib/src/rust/frb_generated.dart` | `f921ddff6bb611e8ce8472e2fa3c2c93d1093b76256d316769352ac50873df44` |
| `packages/fractal_engine_bridge/lib/src/rust/frb_generated.io.dart` | `96fa9bfd6044b1048bae8c0c07f27b2b4caadcda2d515d86671c3ca3b58cc6bb` |
| `packages/fractal_engine_bridge/lib/src/rust/frb_generated.web.dart` | `a48b40a5c022d383f707c813172e49a4ca8be4130483b938dfd84354ce2e4588` |

## Scoped documentation maintenance and pending qualification

Docs Sync Maintain creates this component result/test-evidence note only. The
[specification](../engineering/spec.md#opt-in-native-engine-probe),
[migration plan](../planning/refactor-plan.md#flutter-shell-and-rust-engine-migration),
[transport plan](RUST-PLAN-07.md#off-ui-bounded-request-transport) and prior bridge/
producer notes were inspected. Their ownership and qualification boundaries remain
valid; no shared history or task record is changed. A repeat readback leaves this
note byte-stable. The coordinator/docs maintainer owns shared closeout and changelog
integration.

Next qualification belongs to **RUST-M2-LINUX-EXTENDED** and
**RUST-M2-WAYDROID-EXTENDED**: execute both the unchanged extended target and this
Future target with their official driver and designated Waydroid contract,
source/input/artifact/backend identities, terminal results and owned cleanup.
Those runs are pending, not blockers for this compile-only producer. Do not infer
successful high-u64 outputs, fairness, complete scheduling, responsiveness or full
M2 acceptance from compiled assertions or generated dispatch readback.
