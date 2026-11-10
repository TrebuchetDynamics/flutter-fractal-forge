# RUST-M2-U64-FIXTURE — Fixed debug high-u64 snapshot producer

## Boundary and implementation

This implements the [fixed successful producer decision](RUST-PLAN-08.md#fixed-successful-high-u64-producer)
under the [planned Rust boundary](../engineering/spec.md#planned-rust-engine-boundary).
The source baseline is `b43c2f34f57faf1e52688d6542e13db151f7d85d`.
This is offline producer/build evidence, **not installed Dart/native high-u64 output
qualification**, browser execution, hardware evidence or full M2 acceptance.

[`StateSnapshot::debug_u64_fixtures`](../../rust/crates/fractal-bridge/src/api.rs)
returns `Result<Vec<StateSnapshot>, String>` in every profile. Debug builds clone
an existing validated snapshot into exactly these detached pairs:

| session_id | revision |
| --- | --- |
| 9007199254740993 | 18446744073709551614 |
| 18446744073709551614 | 18446744073709551615 |

The private [core fixture module](../../rust/crates/fractal-core/src/session_codec_fixture.rs)
is included only under `cfg(debug_assertions)`. Struct-update cloning changes only
`session_id` and `revision`; all other state, including retained frame references,
remains copied from the real snapshot. No caller counters, allocator mutation,
mutable high-counter Session, app call site or separate codec is introduced.
Release builds explicitly return `High-u64 snapshot fixtures require debug assertions`.
This fixed instrumentation is not a security boundary or a production identity source.

Reuse: the real catalog validator, detached Snapshot owner, StateSnapshot getters,
production FRB SSE transport and existing `--extended` launcher/provenance/aggregate
protocol. The generated method borrows its source and returns owned snapshot handles.
Existing `snapshot_async` and Number Walls normal wrappers remain normal-mode pool
calls; command/value ownership and borrowed guard/request arguments are unchanged.
Generated Dart identity/revision getters remain `BigInt`; SSE uses `getBigUint64` /
`putBigUint64` and Rust uses native-endian unsigned `read_u64` / `write_u64`.
There is no float or decimal-string output stand-in.

The [focused Rust test](../../rust/crates/fractal-bridge/tests/state_codec_fixture.rs)
first failed with the missing method, then passed in debug and release. It constructs
a validated Session, edits its source snapshot through ordinary commands, closes the
Session, and checks fixed detached outputs in debug or explicit refusal in release.
The [new native target](../../integration_test/migration/rust_state_u64_smoke_test.dart)
has one test body. It asserts both exact BigInt pairs after source Session shutdown,
compares non-counter getters/parameters with the source, checks source counters stay
unchanged, and disposes retained snapshots, parameter handles, Session and adapter.
These Dart assertions were analyzed and compiled, **not executed** in this task.

## Source and input identity

Tools: Flutter 3.47.9 / Dart 3.13.7 (matching `fdroid/flutter.version`), Rust 1.95.0,
FRB codegen/runtime 2.11.1, cargo-expand 1.0.127, provisioned `/usr/bin/python3`
3.12.3 with pytest 9.0.2, Jinja2 3.1.6 and callable MarkupSafe `soft_str`.
Setup reused `$AUTOWORK_CACHE/flutter-3.47.9`, `pub-cache`, `cargo-1.95.0`,
`flutter-rust-bridge-2.11.1` and `cargo-expand-1.0.127`; no installs or dependency
changes. APK compilation selected the existing target-enabled
`$AUTOWORK_CACHE/rustup-1.95.0/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin/rustc`.

| Source path | SHA-256 |
| --- | --- |
| `rust/crates/fractal-core/src/session_codec_fixture.rs` | `d5cf93d811f10719d34bc04ccd0120d0621bab89a9e38bdec27326f7c98c627e` |
| `rust/crates/fractal-bridge/src/api.rs` | `4750df413592e6e42a88d6d03d7ceb72c53d67ee9e5a9b4a2c6eca29d498bd4c` |
| `integration_test/migration/rust_state_u64_smoke_test.dart` | `5fa42b31ae3797a92f36d8e52d2798362f9e821d5b142a6b97d70286724da72d` |
| `scripts/migration/run_state_session_smoke.py` (unchanged) | `459e5cb13db5b00aace7e4e69214b158432dac6d624c39dce4be034f92cd7154` |

Both native builds used the unchanged launcher with `--extended`, which validates
original envelopes before projecting its existing supported-module subset. The new
target validates these projected hashes before native construction. No copied catalog
or trajectory transport is needed. Encoded aggregate: **12288 / 32768 bytes**.

| Envelope | Original SHA-256 | Projected SHA-256 |
| --- | --- | --- |
| modules | `571fb9c2c6ae14572485574c4ca382de2a55eeb6a32e5958869a671d2fbd62d3` | `afc6f18acd52dfdf6d11029c5d46a889f4e07393a5a9fa521a9c7e4f719a3c0f` |
| parameters | `5c8dff3eef955aed9d46f203136dea42b0b070d9bda2966fa4938fac1a6d9517` | `46ab96397b86b330462671b2f1374257dba15bf25ec81e65630cc960c689923d` |
| presets | `318a6c336b2f4310d4fef0d5b7ae09f8a2bff5597471eac742757b088c6b381e` | `d7bb5a2651467e00414c1dbad5fb107ac666b3962e5331be9280df88e739dc87` |
| capabilities | `5f6e0c69a46faf5ebfa627757a9fc29b7124624b038ada4ca21241fe240261aa` | `f29b25e6dd11ba3e53f1aea551488d263c3f3a98973fe0bf33be2180c796959c` |

## Executed offline checks

All commands use the pinned setup above. Long checks/builds ran through
`autowork-run` with bounded timeouts; the merged-tree full gate belongs to the runner.

| Check | Result |
| --- | --- |
| `flutter pub get --offline --enforce-lockfile` | Pass; lockfiles preserved. |
| `cargo test --manifest-path rust/Cargo.toml -p fractal-bridge --test state_codec_fixture --test state_session --locked --offline` | Pass: five tests. |
| `cargo test --manifest-path rust/Cargo.toml -p fractal-bridge --test state_codec_fixture --release --locked --offline` | Pass: explicit release refusal. |
| `scripts/ci/rust-check.sh` | Pass: fmt, clippy with denied warnings, 102 workspace/doc tests; existing exhaustion/rejection/lifecycle guards intact. |
| `flutter_rust_bridge_codegen generate --config-file flutter_rust_bridge.yaml`, twice | Pass: complete inventories match below. |
| `cargo expand --manifest-path rust/Cargo.toml -p fractal-core --lib --release` and equivalent `fractal-bridge` expansion | Pass: core helper/module absent, stable bridge method contains explicit refusal; generated wrapper remains present. |
| `flutter analyze --no-pub packages/fractal_engine_bridge/lib integration_test/migration/rust_state_u64_smoke_test.dart` | Pass: no issues. |
| `flutter test --no-pub test/migration/rust_engine_adapter_test.dart` | Pass: three tests. |
| `/usr/bin/python3 -m pytest -q scripts/migration/tests/test_state_session_smoke.py` | Pass: eight tests. |
| `/usr/bin/python3 scripts/migration/run_state_session_smoke.py --extended -- flutter build linux --debug --no-pub --dart-define=RUST_CORE=true -t integration_test/migration/rust_state_u64_smoke_test.dart` | Pass: compiled only. |
| Same launcher/target with `flutter build apk --debug --no-pub --target-platform android-x64 --dart-define=RUST_CORE=true` | Pass: compiled only; existing Gradle/Java warnings retained. |
| `flutter build web --debug --no-pub --dart-define=RUST_CORE=false` and `true` | Pass: ordinary root app builds, not native fixture/browser execution. |
| Protected-path diff and `git diff --check` | Pass: app, baseline, scripts, manifests, locks and three old state targets unchanged. |

### Complete twice-generated inventory

| Path | SHA-256 (both runs) |
| --- | --- |
| `rust/crates/fractal-bridge/src/frb_generated.rs` | `0cbc8fe962b9f82e379926bd69047d9f7d503d4c93de4a8a5fd22c1626aae3ac` |
| `packages/fractal_engine_bridge/lib/src/rust/api.dart` | `16c50ada823620dfdc90c0d35fb8aadd3ad8ecc691679482edc6ad9cec2fa1e2` |
| `packages/fractal_engine_bridge/lib/src/rust/frb_generated.dart` | `91d514213e0a91154b7b64326b6031e5a2afd802a16db0096ba39ab17097a434` |
| `packages/fractal_engine_bridge/lib/src/rust/frb_generated.io.dart` | `850d839d97084b410efd6913a5c2ccc402669d4bb54066a7c6fb74fa99ea6b8b` |
| `packages/fractal_engine_bridge/lib/src/rust/frb_generated.web.dart` | `40eb56593cf70793476b4d166cadf90cd935780401a5bcef2db477c45ff476a7` |

### Compiled artifacts (not installed proof)

| Path | SHA-256 |
| --- | --- |
| `build/linux/x64/debug/bundle/flutter_fractals` | `31280790eaab184a9091901f23c59c0456ced0f745a7847493f2c603db933993` |
| `build/linux/x64/debug/bundle/data/flutter_assets/kernel_blob.bin` | `c80e0a48657a0296f037e005f6e16bc5d90c9edef51afaa469db582cd8ada4f6` |
| `build/linux/x64/debug/bundle/lib/libfractal_bridge.so` | `83cfb61d404563b3cdfd7639ce13490077dac4bf951f1ed6ac0b744b8010cee7` |
| `build/app/outputs/flutter-apk/app-debug.apk` | `5e4463689df33108b7a8f71bdea5a492fad803800362c5f7894b51a0f6e12223` |
| `build/fractal_engine_bridge/rustJniLibs/debug/x86_64/libfractal_bridge.so` | `d1c5cc5f70afdf61a30fa58a07b643d3b1a53b7178f09d8cf1acb4c12b73568c` |

## Pending installed qualification and scoped documentation maintenance

After producer integration, execute **this new target** through the official Linux
integrationDriver and the standing Waydroid target. Revalidate source/input/artifact
and loaded-library identity, record actual backend identity, require terminal success
and complete test aggregates, and retain owned-process/handle cleanup. Use the existing
[Linux runtime contract](../engineering/runbook.md#owned-linux-runtime-with-reserved-ports)
and [standing Waydroid contract](../engineering/testing/waydroid-headless.md#standing-owner-designation-use-this-waydroid-target).
This task grants no new live authority. Rejected high operands and Rust encoder-byte
tests remain independent guards, not successful native Dart high-u64 output proof.

Docs Sync Maintain is scoped to this component/API/test evidence note. The existing
spec remains the ownership authority; no policy, acceptance or historical result is
rewritten. Local link/anchor, source/input/artifact/hash and generated ownership/codec
readback checks cover this note. Bundled `docs.py stale .` and `docs.py check .`
report no `docs/roles.json` and therefore provide no repository-wide link coverage.
No task store/history is edited or pruned by this worker; the coordinator owns
closeout, shared documentation and changelog integration.
