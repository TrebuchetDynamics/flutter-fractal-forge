# RUST-M2-NATIVE-FIXTURE — Source-bound native StateSession target

## Result and limits

RUST-003-2b8363f4 adds an executable fixture and input launcher on baseline
`dfa45147e49604797ae9ac8d87fa0121dde52bb9`. Linux and Android x86_64 debug builds
of this **new target** pass. Neither artifact was installed or executed here.
RUST-004-2dccfb82 and RUST-005-c9f7f34a own terminal Linux/Waydroid execution.
This result does not qualify full M2, full-catalog parity, rendering, hardware
performance, a Dart concurrent race, or successful high-u64 snapshot outputs.

The implementation follows the [decided fixture seam](RUST-PLAN-04.md#decided-implementation-seams)
and reuses the [synchronous generated bridge](RUST-M2-BRIDGE.md).
The [opt-in probe](../engineering/spec.md#opt-in-native-engine-probe) and
[reserved-port Linux driver contract](../engineering/runbook.md#owned-linux-runtime-with-reserved-ports)
remain unchanged. The app adapter, startup, controller, renderer, generated glue,
wrapper/driver, root manifest, locks, old probe fixture and original M0 files are
unchanged. There are no copied fixtures or app assets.

## Input protocol

From the repository root, invoke
[`run_state_session_smoke.py`](../../scripts/migration/run_state_session_smoke.py)
as `/usr/bin/python3 scripts/migration/run_state_session_smoke.py -- COMMAND ARGS...`.
The launcher resolves source paths relative to itself, not the caller's directory.
It verifies pinned SHA-256 values for the original four envelopes before projection.

Each derived envelope retains every complete payload record for exactly
`mandelbrot`, `julia`, `cantor_set` and `recursive_sine_sphere`. Selection uses `id`
for modules and `module_id` otherwise. Source record order, fields, nulls,
booleans, string text and numeric token spelling are preserved. Keys are sorted
and JSON whitespace is compacted. No expected outputs are projected.

Only provenance is replaced, as specified by RUST-PLAN-04:

- Retain original `flutter_version`, `hash_algorithm` and `registry_mode`.
- Set `sources` to `{original_envelope_path: original_file_sha256}`.
- Hash the sorted compact UTF-8 JSON `sources` mapping into `source_set_sha256`.
- Add `fixture_projection.selected_ids` in the selection-list order above and
  `fixture_projection.original_source_set_sha256`. The latter is
  `d435a3644b06fa1822e4729fce8c596ee1f09c410cfdc8e031c1fa75ff64aac3`
  for all four original envelopes.

These are **derived fixture provenance**, not original full-envelope bytes or a
claim that the original catalog's provenance map was transported.

Each compact envelope is zlib-compressed at level 9, then ordinary base64 encoded.
Exactly four ordinary flags are appended to the selected command's argv:
`--dart-define=STATE_SESSION_MODULES=...`, `STATE_SESSION_PARAMETERS`,
`STATE_SESSION_PRESETS`, and `STATE_SESSION_CAPABILITIES` (all with the same
`--dart-define=` syntax). No shell evaluation occurs. The native fixture reads
four explicit const environment keys, decompresses with `dart:io`, and verifies
the decoded bytes against pinned projected SHA-256 values before native use.
Missing, truncated or changed inputs fail, never skip.

The launcher measures Flutter's actual aggregate format:
`comma_join(base64(utf8(KEY=VALUE)))`, as implemented by pinned Flutter's
`build_info.dart::encodeDartDefines`. The inclusive budget is **32768 bytes**,
including supplied defines. Both `--dart-define` forms, Flutter's historical
`--DartDefines` alias and `-D` forms are counted. Define files, inherited
`DART_DEFINES`, and reserved fixture-key overrides are refused. Over-budget input
is rejected before launch, never truncated. Normal command exits and launch
errors remain nonzero; signal exits use 128 + signal.

This implementation measures **9683 bytes** for fixture inputs alone and **9704**
with `RUST_CORE=true`, below the budget. This is the current measurement, not the
planner's earlier 9639-byte estimate. Flutter's few internal flags have headroom.
Readback of the actual generated Linux CMake `DART_DEFINES` verifies **10056 bytes**
including Flutter's internal build/version flags, with all projected bytes intact.

### Source and derived hashes

Original paths are `migration/baseline/<kind>.json`. Projected hashes bind decoded
compact UTF-8 bytes, not their compressed encoding. The launcher prints this
inventory and aggregate size on each invocation.

| Kind | Original SHA-256 | Projected SHA-256 | Projected bytes |
| --- | --- | --- | --- |
| modules | `571fb9c2c6ae14572485574c4ca382de2a55eeb6a32e5958869a671d2fbd62d3` | `da7bad4bfde2db8e5a995a9ca1a314c6bc965664de6c12bb42413776b5e1165e` | 2220 |
| parameters | `5c8dff3eef955aed9d46f203136dea42b0b070d9bda2966fa4938fac1a6d9517` | `2ac3fea39d030b3acf18c2e361f5859426ef709914ff9b75582cd0664b05e762` | 12377 |
| presets | `318a6c336b2f4310d4fef0d5b7ae09f8a2bff5597471eac742757b088c6b381e` | `b24a99f57fcff5e0052d1ef44fbced8731bcb4b6e39a5cfd58a03c10db052beb` | 8633 |
| capabilities | `5f6e0c69a46faf5ebfa627757a9fc29b7124624b038ada4ca21241fe240261aa` | `1041f69847161b0ede0bf5413cfa4613d9f0aaa16e9a5a5fcb51c14e6effe8fa` | 7846 |

## Fixture assertions (compiled, not executed)

[`rust_state_session_smoke_test.dart`](../../integration_test/migration/rust_state_session_smoke_test.dart)
initializes the real native library through `RustEngineAdapter.create()`. It
asserts opt-in/default-off loading, version `0.1.0`, rendering=false and unchanged
legacy GPU policy selection. It then exercises:

- Independent StateSession identities and source-derived defaults for all four modules.
- Ordered batches versus fresh singleton commands, with differing revision counts.
- Nonfinite view retention/clamps and schema-default parameter normalization.
- Empty batches without revision change and nonempty no-op batches incrementing once.
- Wrong identities, stale revisions and atomic rollback of failed command batches.
- Unsupported operation/module/trajectory rejection after a valid candidate edit.
- Retained snapshot immutability across mutation, reset and shutdown.
- Duplicate shutdown, post-close rejection and independent-session survival.
- Exact number/text/boolean getters and nonfinite float getters. The numeric and
  text value `9007199254740993` retain separate types without binary64 coercion.

Readback parameter handles, retained snapshots and sessions are explicitly disposed.
Owned command/value arguments are freshly constructed for each call and consumed
by generated transport. The fixture reuses flutter_test's already locked `crypto`
dependency for SHA-256, with a fixture-only analyzer suppression. No manifest or
custom hash implementation is needed.

Large wrong/stale operands include `9007199254740993` and `u64::MAX`. These are
rejected **inputs**, not successful identity/revision outputs above `2^53`.
The synchronous API has no Dart async race. Rust contention and private codec
proof remain the separate evidence recorded in RUST-M2-BRIDGE.

## Executed offline checks

Setup: Flutter 3.47.9/Dart 3.13.7 matches `fdroid/flutter.version`.
`/usr/bin/python3` imports pytest/Jinja2/MarkupSafe successfully.
`flutter pub get --offline --enforce-lockfile` regenerates checkout-local metadata
without changing the lockfile. Rust/cargo are 1.95.0 with
`CARGO_HOME=$AUTOWORK_CACHE/cargo-1.95.0`. SDKs and package caches were reused.
Android selects the existing target-enabled compiler shown below; nothing was installed.

| Command | Result |
| --- | --- |
| `/usr/bin/python3 -m pytest -q scripts/migration/tests/test_state_session_smoke.py` | Pass: four focused tests, including complete-record/provenance/hash binding, argv round trips/exit propagation, aggregate boundaries/aliases and fail-closed input/launch errors. |
| `flutter analyze --no-pub integration_test/migration/rust_state_session_smoke_test.dart` | Pass: no issues. |
| `flutter test --no-pub test/migration/rust_engine_adapter_test.dart` | Pass: three existing adapter tests. |
| `/usr/bin/python3 "$TMPDIR/state-session-readback.py"` (task-private readback) | Pass: local links/anchors, assertions, hashes, const keys, both execution commands and actual Flutter CMake aggregate/source-bound decode. |
| Bundled `docs.py stale .` and `docs.py check .`; `autowork tasks validate --worktree .` | Pass: no docs manifest; task store validates. Scoped readback supplies this note's link coverage. |
| Linux build command below | Pass: new target compiled, not executed. |
| Android build command below | Pass: new target compiled, not installed. Existing Gradle/AGP/Kotlin warnings remain visible. |
| `git diff --exit-code -- migration/baseline lib packages/fractal_engine_bridge rust pubspec.yaml pubspec.lock integration_test/migration/rust_engine_smoke_test.dart && git diff --check` | Pass: preserved boundaries and whitespace. |

```sh
autowork-run timeout --kill-after=10s 900 /usr/bin/python3 scripts/migration/run_state_session_smoke.py -- \
  flutter build linux --debug --no-pub --dart-define=RUST_CORE=true \
  -t integration_test/migration/rust_state_session_smoke_test.dart

RUSTC="$AUTOWORK_CACHE/rustup-1.95.0/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin/rustc" \
  autowork-run timeout --kill-after=10s 1200 /usr/bin/python3 scripts/migration/run_state_session_smoke.py -- \
  flutter build apk --debug --no-pub --target-platform android-x64 --dart-define=RUST_CORE=true \
  -t integration_test/migration/rust_state_session_smoke_test.dart
```

The coordinator owns the separate merged-tree full gate. It was not run here.

## Consumer execution commands — NOT RUN

Select the pinned SDK/cache and Rust toolchain as above. Linux consumers must use
their actual reserved `AUTOWORK_PORT_BASE` and private `TMPDIR`. The unchanged
wrapper owns host reporting, private outputs, terminal protocol checks and cleanup:

```sh
autowork-run timeout --kill-after=10s 660 /usr/bin/python3 scripts/migration/run_state_session_smoke.py -- \
  bash scripts/run-native-integration.sh integration_test/migration/rust_state_session_smoke_test.dart \
  --timeout 600 --dart-define=RUST_CORE=true
```

A Linux pass requires `run.json` exit_code=0, protocol_success=true, official
allTestsPassed=true and no remaining owned PIDs. Build success is insufficient.

Waydroid consumers must first coordinate access and follow the
[designated-instance transport checks](../engineering/testing/waydroid-headless.md#working-android-test-sequence).
Revalidate its current serial/model/boot and export matching `ANDROID_DEVICE` and
`ANDROID_DISPOSABLE_DEVICE`. Do not select another device or reset the container.
The accepted consumer command is:

```sh
test "$ANDROID_DEVICE" = "$ANDROID_DISPOSABLE_DEVICE" && \
RUSTC="$AUTOWORK_CACHE/rustup-1.95.0/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin/rustc" \
  autowork-run timeout --kill-after=10s 1200 /usr/bin/python3 scripts/migration/run_state_session_smoke.py -- \
  flutter test --no-pub --no-uninstall integration_test/migration/rust_state_session_smoke_test.dart \
  -d "$ANDROID_DEVICE" --dart-define=RUST_CORE=true --reporter expanded
```

Retain full terminal output/exit, source/fixture/launcher/input/APK/SO identities,
actual target/backend, toolchains and owned cleanup. Waydroid remains container
functional evidence, not physical-device or hardware-GPU qualification.

## Scoped Docs Sync Maintain

Only this designated result/protocol/check note is added. Source readback covers
the fixture assertions, four original/projected hashes, explicit const keys,
aggregate guard, build commands and both unrun native execution commands.
Local link/anchor checks and repeated readback cover this note. Bundled
`docs.py stale .` and `docs.py check .` report `no manifest at docs/roles.json`;
they do not provide repository-wide link coverage. Specification/runbook policy
and shared history remain unchanged. The coordinator owns changelog integration
and the closeout Docs Sync pass.
