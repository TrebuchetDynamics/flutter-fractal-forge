# RUST-M2-EXTENDED-FIXTURE — source-bound effects/frame producer

## Result and boundary

The launcher now accepts `--extended` before `-- COMMAND`. The separate target is
[`rust_state_extended_smoke_test.dart`](../../integration_test/migration/rust_state_extended_smoke_test.dart).
Linux and Android x86_64 debug artifacts compile with the native library included.
**The native assertions are unexecuted.** Nothing was installed or run on a native
target. Both Web root flag builds pass, without browser qualification.

Sources: [extended producer contract](RUST-PLAN-06.md#extended-native-fixture-producer),
[effects bridge](RUST-M2-EFFECTS-BRIDGE.md) and
[Number Walls bridge](RUST-M2-WALL-BRIDGE.md).
The [opt-in probe](../engineering/spec.md#opt-in-native-engine-probe) and
[replay validation boundary](../engineering/spec.md#number-walls-replay-validation-boundary)
remain unchanged. There is no app, adapter, renderer, Rust, generated transport,
dependency, persistence, build-rule or flag change.

## Inputs and identities

Baseline: `e54bec658d5e2f0bbd45d66fcf3ae49f297f554c`.
SHA-256 of the final producer sources:

- `scripts/migration/run_state_session_smoke.py`:
  `459e5cb13db5b00aace7e4e69214b158432dac6d624c39dce4be034f92cd7154`
- `integration_test/migration/rust_state_extended_smoke_test.dart`:
  `073bb9ea74626e65647dab25a4cf301d9d6f81b2115b715bf45467c9fbdd77bc`

Each envelope contains seven complete records in original source order:
`cantor_set`, `julia`, `kaleidoscope_basic`, `kaleidoscope_fractal`, `mandelbrot`,
`number_wall`, `recursive_sine_sphere`. No field is trimmed. Number spelling is
preserved by the existing lexical-number serializer. Provenance retains the
original envelope hash, derives the source-set hash, and records selected IDs and
the original source-set hash.

| Envelope | Original SHA-256 | Extended SHA-256 | Projected bytes |
| --- | --- | --- | ---: |
| modules | `571fb9c2c6ae14572485574c4ca382de2a55eeb6a32e5958869a671d2fbd62d3` | `afc6f18acd52dfdf6d11029c5d46a889f4e07393a5a9fa521a9c7e4f719a3c0f` | 3575 |
| parameters | `5c8dff3eef955aed9d46f203136dea42b0b070d9bda2966fa4938fac1a6d9517` | `46ab96397b86b330462671b2f1374257dba15bf25ec81e65630cc960c689923d` | 24679 |
| presets | `318a6c336b2f4310d4fef0d5b7ae09f8a2bff5597471eac742757b088c6b381e` | `d7bb5a2651467e00414c1dbad5fb107ac666b3962e5331be9280df88e739dc87` | 12092 |
| capabilities | `5f6e0c69a46faf5ebfa627757a9fc29b7124624b038ada4ca21241fe240261aa` | `f29b25e6dd11ba3e53f1aea551488d263c3f3a98973fe0bf33be2180c796959c` | 13341 |

Both native build invocations recorded **12288/32768 Flutter-encoded bytes**,
including `RUST_CORE=true`. The existing inclusive cap remains: an aggregate
of 32768 bytes is allowed, anything larger is rejected before launch. Caller
defines count toward it. Overrides, define files and inherited `DART_DEFINES`
remain rejected. Missing, truncated or tampered source inputs do not become skips.

Direct comparison with the baseline launcher confirmed byte-identical default
four-module output in all four envelopes. Default hashes remain:

- modules: `da7bad4bfde2db8e5a995a9ca1a314c6bc965664de6c12bb42413776b5e1165e`
- parameters: `2ac3fea39d030b3acf18c2e361f5859426ef709914ff9b75582cd0664b05e762`
- presets: `b24a99f57fcff5e0052d1ef44fbced8731bcb4b6e39a5cfd58a03c10db052beb`
- capabilities: `1041f69847161b0ede0bf5413cfa4613d9f0aaa16e9a5a5fcb51c14e6effe8fa`

The original native target and original baseline files are unchanged.

## Assertion inventory and handle rules

The new target contains four focused cases. These describe compiled assertions,
not native results:

1. Decode every extended envelope against its pinned hash. Reject missing,
   truncated and tampered data. Check that the disabled adapter never loads native
   code. Every native case requires `RUST_CORE=true` and `rendering=false`.
2. Call all eleven effect constructors and getters against the existing Dart
   `FractalController` oracle. Exercise ordinary → forced → forced → ordinary
   restoration. Reject a batch that would corrupt the hidden restore state and
   compare retained effects, module, params, view and revision. Check isolation,
   duplicate shutdown, post-close rejection and retained snapshot reads.
3. Stage all six Number Walls sequences with prime `00097`, rows 4, columns 16,
   origin 3. Drive zero work, one work unit and bounded steps. Compare canonical
   settings, sequence, modulus, dimensions, support and **every grid cell** with
   `NumberWallFrame.prepare` and its existing Dart model. Assert admission,
   pending and terminal revisions. Invalid `1e2`, composite `561` and budget-zero
   unverified `170141183460469231731687303715884105727` retain certified state.
4. Exercise inactive guards, repeated revoke, zero-work revocation observation,
   supersession, stale cancellation/advance, wrong session/revision and foreign
   requests. Reject a mixed deferred batch atomically. Exercise explicit cancel,
   duplicate cancel, navigation, immediate begin, shutdown with pending work and
   all post-close session operations. Read detached frames after navigation/close
   and finish an independent session without changing its earlier pending state.

Every command and owned `StateValue` argument is constructed fresh and consumed by
the generated transport, including rejected calls. Guards and requests are
borrowed, retained across operations and explicitly disposed. Returned progress,
snapshot and frame handles are retained and disposed in fixture cleanup. Every
params getter's value handles are disposed after readback. Grid mutation tests
change only detached Dart collections. No public identity setter, fabricated
certificate, timer, background executor or concurrency claim is introduced.

Reuse decisions: keep the launcher's serializer, compression, provenance and
aggregate guards; parameterize its existing four Python cases rather than add a
second protocol harness. Reuse Dart controller/frame/model oracles and the existing
locked crypto dependency. Do not copy baseline fixtures or refresh the old target.

## Actual offline checks

Setup used Flutter **3.47.9 / Dart 3.13.7**, matching `fdroid/flutter.version`,
Rust **1.95.0**, `PUB_CACHE=$AUTOWORK_CACHE/pub-cache` and
`CARGO_HOME=$AUTOWORK_CACHE/cargo-1.95.0`. The cache is under the absolute Git
common directory when not explicitly supplied. `/usr/bin/python3` is 3.12.3;
pytest 9.0.2, jinja2 3.1.6 and callable `markupsafe.soft_str` imports passed.
`flutter pub get --offline --enforce-lockfile` regenerated checkout-local metadata
without a lock change. No tools, packages or profiles were installed or changed.

Long builds used `autowork-run timeout --kill-after=10s` with 900-second limits
(1200 seconds for APK). Commands below ran with that setup:

| Command | Final result |
| --- | --- |
| `/usr/bin/python3 -m pytest -q scripts/migration/tests/test_state_session_smoke.py` | Pass: 8 cases, both modes, complete ordered records/lexemes, provenance/hashes, round-trip/exit propagation, inclusive size boundary and fail-closed guards. |
| `flutter analyze --no-pub integration_test/migration/rust_state_extended_smoke_test.dart packages/fractal_engine_bridge/lib` | Pass: no issues. |
| `flutter test --no-pub test/migration/rust_engine_adapter_test.dart test/modules/number_wall_model_test.dart test/number_walls/number_wall_state_test.dart` | Pass: 18 tests. These are offline adapter/model/controller checks, not the new native target. |
| `/usr/bin/python3 scripts/migration/run_state_session_smoke.py --extended -- flutter build linux --debug --no-pub --dart-define=RUST_CORE=true -t integration_test/migration/rust_state_extended_smoke_test.dart` | Pass: compiled only; native library present. |
| `RUSTC="$AUTOWORK_CACHE/rustup-1.95.0/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin/rustc" /usr/bin/python3 scripts/migration/run_state_session_smoke.py --extended -- flutter build apk --debug --no-pub --target-platform android-x64 --dart-define=RUST_CORE=true -t integration_test/migration/rust_state_extended_smoke_test.dart` | Pass: compiled only; APK contains `lib/x86_64/libfractal_bridge.so`. Existing Java source/target 8 warnings remain warnings. |
| `flutter build web --debug --no-pub --dart-define=RUST_CORE=false && flutter build web --debug --no-pub --dart-define=RUST_CORE=true` | Pass: both root builds. No browser or WASM execution. |
| `git diff --exit-code -- lib migration/baseline integration_test/migration/rust_state_session_smoke_test.dart rust packages flutter_rust_bridge.yaml pubspec.lock && git diff --check` | Pass: preserved sources/locks and clean whitespace. |
| Scoped source/artifact/doc readback | Pass: source/projection/artifact hashes, default byte preservation, seven complete records, all eleven calls/getters, local links/anchors and explicit unexecuted boundary. |
| Bundled Docs Sync `docs.py stale .` and `docs.py check .` | Pass: no `docs/roles.json` manifest, so these provide no repository-wide coverage. Scoped readback supplies this note's coverage. |

## Compile artifacts

These checkout-local artifacts were inspected, not installed. SHA-256:

| Artifact | SHA-256 |
| --- | --- |
| `build/linux/x64/debug/bundle/flutter_fractals` | `9b22e06f4c5ed6c150f6a47351b1d8518dd261ef6be0f8d57bacd6273a72d81d` |
| `build/linux/x64/debug/bundle/data/flutter_assets/kernel_blob.bin` | `5dec4f83ddc54869caa6fd412b634aa71583460d41ce2c98c20976417b3cfa8a` |
| `build/linux/x64/debug/bundle/lib/libfractal_bridge.so` | `f848e46913d3dd994b803b212d6dca02108fbf109dc8377dc42dd74c993240db` |
| `build/app/outputs/flutter-apk/app-debug.apk` | `0b068b8c781af44a142df05cced009d8f0cfdb210e79d31ade49c2c57ba090cf` |

## Pending qualification and documentation ownership

The same coordinator must later plan official-driver Linux and designated
Waydroid execution of this **new target**, with source/artifact identities,
terminal results and owned cleanup. Earlier four-module scalar execution does not
execute these assertions. No installed effects/frame, off-UI executor, successful
high-u64 output, physical GPU, browser or whole-session/full-M2 proof follows.
Wrong large identity/revision operands are input-only checks. Deterministic
interleavings do not establish concurrency safety.

Scoped Docs Sync Maintain updated this designated producer/result/gap note only.
The spec, glossary and RUST-PLAN-06 were inspected and remain valid unchanged.
Task-store closeout, shared planning/history and the final Docs Sync pass belong
to the coordinator/docs maintainer. The runner owns the merged-tree offline gate;
this worker did not run it. Next: RUST-PLAN-07 reconciliation and separately planned
installed qualification, without changing these proof limits.
