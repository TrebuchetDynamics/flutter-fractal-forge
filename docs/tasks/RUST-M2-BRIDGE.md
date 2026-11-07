# RUST-M2-BRIDGE — Inert typed state-session transport

## Scope and implementation

This result implements the bridge slice from
[RUST-PLAN-03](RUST-PLAN-03.md#decided-interfaces-and-error-semantics).
It consumes the existing [core session](RUST-M2-SESSION.md) and preserves the
[opt-in probe](../engineering/spec.md#opt-in-native-engine-probe).
The base is `c7bcd89446ee57f351bd3294e95a6718b6f7a2ea`.
This is offline implementation/build evidence, not installed transport proof or
full M2/M3 qualification.

[`api.rs`](../../rust/crates/fractal-bridge/src/api.rs) adds a separate opaque
`StateSession`. Explicit construction accepts the original four envelope strings
and a supported module ID. Core validates the catalog and module. A checked atomic
counter allocates process-local `u64` identities and never reuses them, including
after shutdown. Failed construction may consume an identity. Exhaustion rejects
instead of wrapping.

A single mutex guards the core session for `snapshot()`,
`apply_batch(session_id, expected_revision, commands)` and `shutdown()`.
The bridge delegates ordered batches, normalization, revision checks and atomic
publication to `fractal-core::session::Session`. Shutdown drops the owned state
and catalog. Duplicate shutdown succeeds; subsequent operations reject with
`Rust state session is closed`. Core errors retain their existing display text.
A poisoned mutex rejects rather than exposing state.

`StateCommand` has typed constructors for zoom, pan, rotation, view, parameter
edits, module selection, transparency, preset/load, all three resets and explicit
unsupported operations. `StateValue` distinguishes raw floats, exact numeric
representations, booleans and text. Nonfinite floats reach core normalization.
Exact numbers use validated JSON-number strings, not binary64 conversion. Exact
text uses a separate constructor and is never parsed numerically.
`StateCamera` preserves the trajectory-presence marker so core rejects unsupported
trajectories rather than dropping them. `StateView` has six named scalar fields.

Read-only opaque `StateSnapshot` handles own detached core copies. Their getters
expose identity, revision, module, parameters, scalar view, transparency and
adaptive-zoom history. Parameter collections and views returned by getters are
further detached copies, not a mutable mathematical owner in Dart.

### Reuse and deliberate omissions

- Reuse core transactions and normalization without changing core or adding math
  to the bridge. Reuse the existing private core revision-exhaustion test.
- Use the standard atomic counter and mutex. Add no dependencies, manifests,
  lockfiles, build rules or schema.
- Use typed opaque value/command handles with named constructors. FRB 2.11.1
  otherwise emits data-carrying enums through Freezed, which this package does
  not declare. Scalar view fields also avoid generated fixed-array wrappers that
  require an undeclared `collection` dependency. No hand-edited generated glue.
- Preserve `Engine`, rendering=false, root package exports, the app adapter,
  startup, controller, renderer and all baseline bytes. No app owner switch,
  Number Walls support, WASM loading, device installation or native execution.

## Executed offline checks

Setup used Flutter 3.47.9/Dart 3.13.7, the existing shared Pub cache, Rust 1.95.0,
`CARGO_HOME=$AUTOWORK_CACHE/cargo-1.95.0`, FRB 2.11.1 and cargo-expand 1.0.127.
The SDK version matches `fdroid/flutter.version`. Provisioned `/usr/bin/python3`
imports for pytest, Jinja2 and MarkupSafe succeeded. Offline, lockfile-enforced
Pub resolution regenerated only checkout-local metadata.

| Check | Result |
| --- | --- |
| `cargo test --manifest-path rust/Cargo.toml -p fractal-bridge --test state_session --locked --offline` | Pass: four public seam tests. |
| `autowork-run scripts/ci/rust-check.sh` | Pass: fmt, clippy with denied warnings, 22 workspace tests and doc-test targets. |
| `flutter_rust_bridge_codegen generate --config-file flutter_rust_bridge.yaml`, twice | Pass: equal complete five-file SHA-256 inventories below. |
| `flutter analyze --no-pub packages/fractal_engine_bridge/lib lib/core/services/engine` | Pass: no issues. |
| `flutter test --no-pub test/migration/rust_engine_adapter_test.dart` | Pass: three tests. |
| `autowork-run timeout --kill-after=10s 900 flutter build linux --debug --no-pub --dart-define=RUST_CORE=true -t integration_test/migration/rust_engine_smoke_test.dart` | Pass: native smoke fixture compiled, not executed. |
| `autowork-run timeout --kill-after=10s 1200 flutter build apk --debug --no-pub --target-platform android-x64 --dart-define=RUST_CORE=true -t integration_test/migration/rust_engine_smoke_test.dart` | Pass: Android x86_64 smoke fixture compiled, not installed. |
| `autowork-run timeout --kill-after=10s 900 flutter build web --debug --no-pub --dart-define=RUST_CORE=false` | Pass. |
| Same Web command with `--dart-define=RUST_CORE=true` | Pass; app still excludes native loading. |
| `git diff --exit-code -- migration/baseline pubspec.lock rust/Cargo.lock lib` and `git diff --check` | Pass: preserved inputs/app routing and clean whitespace. |

The home Rust toolchain has no Android standard library. The successful APK build
selected the existing target-enabled Rust 1.95.0 compiler with
`RUSTC=$AUTOWORK_CACHE/rustup-1.95.0/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin/rustc`.
No target was installed or upgraded. Existing Gradle/AGP/Kotlin and Java-version
warnings remained visible; no validation flag was disabled.
The coordinator's merged-tree full gate is separate and was not run here.

### Test and codec evidence limits

The [public Rust seam tests](../../rust/crates/fractal-bridge/tests/state_session.rs)
read original baseline files and compare typed bridge results with equivalent
direct-core operations. They cover ordered batches, nonfinite input, exact scalar
representations/text, independent identities, stale identity/revision rejection,
atomic failed batches, empty/no-op batches, retained snapshot copies, duplicate
shutdown and post-close errors. Concurrent public calls verify a single winning
revision and a legal transaction/shutdown order.

Private bridge tests use controlled setup for identity exhaustion under contention
and an identity above `2^53`. The generated Rust `u64` encoder preserves exact bytes
for `9007199254740993`, `u64::MAX - 1` and `u64::MAX`. Core's existing private test
covers actual revision exhaustion without a public revision setter.
Generated-code readback confirms:

- Dart snapshot identity/revision and both batch operands are `BigInt`.
- Dart SSE uses `getBigUint64`/`putBigUint64`; Rust SSE uses unsigned native-endian
  `read_u64`/`write_u64`. Neither path converts these fields through `double`.
- Values use distinct float, boolean and string codecs. Exact number/text strings
  remain separate typed Rust variants. Batches decode as `Vec<StateCommand>`.
- `StateSnapshot` has no mutation method. All core mutations go through the
  session lock. Opaque command/value arguments use FRB owned-handle transport;
  callers must not reuse handles after passing ownership.

These are Rust boundary tests and generated-source inspection, not executed
Dart/native state-session codec proof. The native smoke fixture still exercises
only the existing probe. Installed Linux/Waydroid state-session tests, large-value
round trips, native lifecycle/race evidence and the full session frontier remain
for RUST-PLAN-04. Full replay, Number Walls certification/cancellation, remaining
state fields and M3 runtime authority are not qualified by this result.

### Deterministic generated inventory

Each complete generation produced exactly these files and SHA-256 values:

| Path | SHA-256 |
| --- | --- |
| `rust/crates/fractal-bridge/src/frb_generated.rs` | `1b82b2fb8a8b0a9eb90474929fbb6c217000dc4eedd00dbcef12bd2e9464246e` |
| `packages/fractal_engine_bridge/lib/src/rust/api.dart` | `61a666be03b119e605e4059bede42fa2627e2d80d46514acf5356979085c1a9c` |
| `packages/fractal_engine_bridge/lib/src/rust/frb_generated.dart` | `39eefb30624dd8dc61000aaa84a8a4ed0a883bf8bcca02d99ce9fc8eb50d7544` |
| `packages/fractal_engine_bridge/lib/src/rust/frb_generated.io.dart` | `427d9a828be15d1e3f706be06b6b9ecb95f113cfadab5504c561faca00ab61e1` |
| `packages/fractal_engine_bridge/lib/src/rust/frb_generated.web.dart` | `b675899aaed3376add1b6d59d5bb4348781d81aeff535e7b2637bdb9d44937ea` |

## Scoped documentation maintenance

Docs Sync Maintain updates only this result note and current-status/API prose in
[the specification](../engineering/spec.md#isolated-rust-workspace-foundation).
Ownership policy and Number Walls boundaries remain unchanged. Readback checks
cover local links in this note and the two affected spec sections, API/codec
statements and the complete generated inventory. Bundled `docs.py stale .` and
`docs.py check .` both exit 0 with `no manifest at docs/roles.json`; they provide
no repository-wide link coverage. No role manifest or task ledger is changed.
The coordinator owns changelog integration and the closeout Docs Sync pass.
