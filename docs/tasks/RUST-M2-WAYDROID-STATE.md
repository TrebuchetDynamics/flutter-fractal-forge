# RUST-M2-WAYDROID-STATE — Designated Android StateSession result

## Result and limits

**Passed on the designated Waydroid instance on 2026-11-07 UTC.** The real
[StateSession fixture](../../integration_test/migration/rust_state_session_smoke_test.dart)
completed with terminal Flutter exit **0**: three tests passed, none skipped.
The tested source was `61643ca955feea1e0885d5392a64809fe4d265fe`.
Only this result note changes. No fixture, launcher, native source, generated
binding, manifest, lockfile or original baseline needed repair.

The native run executed the existing assertions for:

- Missing, truncated and tampered fixture input rejection, with SHA-256 checks
  before StateSession construction.
- Independent identities and source-derived defaults for all four selected modules.
- Ordered batches versus singleton commands, nonfinite normalization, empty/no-op
  revisions, wrong/stale operands and atomic failed-batch rollback.
- Retained snapshots across mutation/reset/shutdown, duplicate shutdown,
  post-close rejection and independent-session survival.
- Exact number/text/boolean getters and nonfinite float getters.
- Explicit disposal of readback values, snapshots and sessions in `finally`,
  adapter shutdown and closed-adapter rejection.

This is executed Android container transport evidence, not a build-only or
probe-only result. It does **not** qualify full M2, full-session/full-catalog
parity, whole original-envelope byte transport, runtime races, successful
high-u64 snapshot outputs, Rust rendering, Linux, browsers or physical hardware.
Large wrong/stale operands remain rejected inputs, not high-u64 output proof.
See the [input protocol](RUST-M2-NATIVE-FIXTURE.md#input-protocol),
[decided execution seam](RUST-PLAN-04.md#decided-implementation-seams) and
[planned Rust boundary](../engineering/spec.md#planned-rust-engine-boundary).

## Private evidence

Resolve `GIT_COMMON_DIR` with `git rev-parse --path-format=absolute --git-common-dir`.
The retained owner-only directory is outside disposable `TMPDIR`:

```text
$GIT_COMMON_DIR/autowork-execution/slot-data/RUST-005-c9f7f34a/attempt-1/evidence/
```

`SHA256SUMS` binds the retained files. Main records:

| Record | Evidence |
| --- | --- |
| `coordination.json`, `processes-before.log` | Admitted worker, actual ACAD worker liveness and process inventory. |
| `transport.log`, `preflight.log` | Status/helper/device inventory, matching consent/readiness checks, native properties, backend and prior installation. |
| `setup-final.log`, `flutter-version.json`, `pubspec-lock.before` | Pinned SDK comparison, Python/Rust/Cargo/FRB versions and unchanged lockfile. `setup.log` also retains offline Pub resolution and the initial missing ambient Cargo PATH diagnostic, corrected before execution. |
| `source.json` | Tested revision and hashes of fixture, launcher, tests, baseline envelopes, adapter, Rust, bindings and Android build inputs. |
| `inputs.json`, `projected-*.json` | Original/projected hashes and the actual complete-record projection bytes. |
| `command.txt`, `flutter.started`, `flutter.ended`, `flutter.log`, `flutter.exit` | Exact command, UTC interval, complete build/install/assertion output and terminal exit 0. |
| `artifacts.json`, `artifact-readback.log`, `app-debug.apk`, `libfractal_bridge-unstripped.so` | Actual tested artifacts and packaged/stripped/unstripped SO identities. |
| `installed-before.sha256`, `installed-after.sha256`, `readback.log`, `apk-signing.log`, `apk-badging.log` | Previous/current installed APK identities, package/signing history and build metadata. |
| `run-state-session-waydroid.sh`, `adb-reserved-port.py`, `forward-shim.jsonl` | Task-private execution and reserved host-forward instrumentation, without SDK edits. |
| `device.log`, `forward-cleanup.json`, `cleanup.log` | Test process/guest VM port, owned forward removal, stopped app, absent owned listeners and healthy target. |
| `launcher-tests.log`, `analyze.log`, `adapter-tests.log` | Focused offline results. |
| `doc-readback.py`, `doc-readback.log`, `docs-check.log`, `tasks-validate.log` | Scoped documentation and evidence readback. |

## Source, input and artifact binding

| Identity | SHA-256 |
| --- | --- |
| Fixture | `bb1c415c8a581294472d67d9bce8f1ec47914dcbb80d90bb5d4d5b4018b373b5` |
| Launcher | `4e2eb60a2f62611d03c8eb65ddd7e87ffcd0d8da5345eab290c3d242050ddb7c` |
| Built and installed APK | `0d8eea9c173680a6402300700ba41304a7430b6379e1af96b65d468d4b0ff49e` |
| Packaged `lib/x86_64/libfractal_bridge.so` | `7a9488bffd7d73a3fed0d95a2d02e6b396b2488fa23e68761c7c8e0734a16985` |
| Unstripped Cargo/debug SO | `140a694b3976e2e4835ec1eb38a20404828e46d5dd4adda1915385f6f2326b22` |

The APK is 65,041,930 bytes. Its sole Rust ABI is x86_64. The packaged SO is
3,213,248 bytes and matches Gradle's stripped output. The unstripped SO is
39,762,608 bytes. Installed `base.apk` readback matches the built APK hash.

Original paths are `migration/baseline/<kind>.json`. Each projection retains the
complete records for `mandelbrot`, `julia`, `cantor_set` and
`recursive_sine_sphere`, with explicit derived provenance, not the full catalog.
The launcher printed these bindings during the successful run:

| Kind | Original SHA-256 | Projected SHA-256 |
| --- | --- | --- |
| modules | `571fb9c2c6ae14572485574c4ca382de2a55eeb6a32e5958869a671d2fbd62d3` | `da7bad4bfde2db8e5a995a9ca1a314c6bc965664de6c12bb42413776b5e1165e` |
| parameters | `5c8dff3eef955aed9d46f203136dea42b0b070d9bda2966fa4938fac1a6d9517` | `2ac3fea39d030b3acf18c2e361f5859426ef709914ff9b75582cd0664b05e762` |
| presets | `318a6c336b2f4310d4fef0d5b7ae09f8a2bff5597471eac742757b088c6b381e` | `b24a99f57fcff5e0052d1ef44fbced8731bcb4b6e39a5cfd58a03c10db052beb` |
| capabilities | `5f6e0c69a46faf5ebfa627757a9fc29b7124624b038ada4ca21241fe240261aa` | `1041f69847161b0ede0bf5413cfa4613d9f0aaa16e9a5a5fcb51c14e6effe8fa` |

The measured Flutter-encoded aggregate was **9704/32768 bytes**, including
`RUST_CORE=true`. The existing guard and assertions were not weakened.

## Tools, target and consent

| Field | Observed value |
| --- | --- |
| Flutter / Dart | `3.47.9` / `3.13.7`, matched `fdroid/flutter.version` |
| Framework / engine revisions | `c197ca5199e9ee5661e865596c9c07294dfab51c` / `89c39edfdfae2949f6806e4a315c0c08522238b7` |
| Rust / Cargo | `1.95.0` (`59807616e`) / `1.95.0` (`f2d3ce0bd`) |
| FRB Rust runtime / Dart runtime / codegen | `2.11.1` / `2.11.1` / `2.11.1` |
| Build | Debug, `x86_64-linux-android`, NDK `28.2.13676358`, Cargo locked/offline |
| App | `com.trebuchetdynamics.fractal.forge`, `1.1.0+38`, minSdk `24`, targetSdk `36` |
| Current serial / state | Rediscovered `192.168.240.112:5555` / `device` |
| Native model / boot | `WayDroid x86_64 Device` / `sys.boot_completed=1` |
| Android / ABI | `13` / `x86_64,x86` |
| Session / container / display | `RUNNING` / `RUNNING` / existing `waydroid-headless` |
| Rust backend | Native FRB FFI, `rendering=false` |
| Guest graphics | EGL `mesa`, Vulkan `radeon`; SurfaceFlinger: AMD Radeon Graphics, OpenGL ES 3.2 Mesa `26.0.5` |
| Test interval | `2026-11-07T12:23:40+00:00` through `2026-11-07T12:25:07+00:00` |

Python was `/usr/bin/python3` 3.12.3, with pytest 9.0.2, Jinja2 3.1.6 and callable
MarkupSafe `soft_str`. Process-local setup reused the pinned Flutter/Pub cache,
`CARGO_HOME=$AUTOWORK_CACHE/cargo-1.95.0` and the existing target-enabled compiler:
`RUSTC=$AUTOWORK_CACHE/rustup-1.95.0/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin/rustc`.
No SDK, target or dependency was installed or upgraded.

The runner admitted this task for `live, waydroid`. Fresh admission/liveness and
process inspection found ACAD-013-4142ef42 held with `worker_live=false`, not using
the target. No active Android test/install worker was found. No contention wait
or interruption was needed. Historical claims were preserved.

The [standing owner designation](../engineering/testing/waydroid-headless.md#standing-owner-designation-use-this-waydroid-target)
supplied existing app-test/replacement consent, not new live or publication
permission. `waydroid status` supplied the current IP. The normal helper and all
actual get-state/model/boot checks passed. Matching `ANDROID_DEVICE` and
`ANDROID_DISPOSABLE_DEVICE` were exported as `192.168.240.112:5555`.
No restart/reset, key enrollment, privileged recovery or other device was used.

The previous APK hash was
`168e636131b63a5facdb1d78c428cafabc0e6fdaf383a8efd6f8945e186300fe`, the retained
[M1 test installation](RUST-M1-WAYDROID.md#execution-and-owned-cleanup).
It was already debug-signed, versionCode 38. This run replaced it without a
version-downgrade or uninstall retry. Package readback preserved firstInstallTime
`2026-11-07 08:37:31` and the same signing identity. The APK signer is Android
Debug, SHA-256 `73c58e9435161f7826d6eb4f7155243a8609468b204472e45a8b0e1e3715ecff`.
No credentials or signing configuration changed. Earlier signed-app replacement
history remains in the M1 note, not reclassified as a new consent gap.

## Execution and owned cleanup

The long-command wrapper was
`autowork-run timeout --kill-after=10s 1260 bash "$TMPDIR/run-state-session-waydroid.sh"`.
Inside it, a 1200-second timeout bounded this exact command:

```sh
/usr/bin/python3 scripts/migration/run_state_session_smoke.py -- \
  flutter test --no-pub --no-uninstall integration_test/migration/rust_state_session_smoke_test.dart \
  -d 192.168.240.112:5555 --dart-define=RUST_CORE=true --reporter expanded --dds-port=20100
```

Flutter `test` has no host VM-service port option. A task-private SDK view reused
all installed SDK files, except an ADB shim that delegated only this serial's
`forward tcp:0` request as `forward tcp:20101`. DDS used 20100. The shim logged the
actual mapping `tcp:20101 → tcp:34295`; it did not edit the SDK or shared ADB server.
Both selected host ports are within this worker's 20100–20199 allocation.

Gradle built and installed the real StateSession APK. Existing Java source/target
8 warnings remained visible. Terminal output was:

```text
00:00 +0: source-bound input protocol refuses missing/truncated/tampered data
00:00 +1: real synchronous StateSessions preserve transactions and lifecycle
00:00 +2: native StateValue getters retain exact scalar type and text
00:00 +3: (tearDownAll)
00:00 +3: All tests passed!
```

After installed-artifact readback, only the tested app was force-stopped.
`pidof` returned 1, meaning absent. The owned test/DDS processes and listeners
were absent. Only the shim-recorded ADB forward was removed, with exit 0.
All eight pre-existing forwards were preserved. The test APK remains installed
under `--no-uninstall`; the earlier APK was not restored. Waydroid remained
`RUNNING`, with the designated serial still `device`.

## Focused checks and scoped Docs Sync Maintain

| Check | Result |
| --- | --- |
| `waydroid status`; `waydroid adb connect`; `adb devices -l` | Pass, with actual designated serial readiness verified separately. |
| Matching consent variables and get-state/model/boot assertions | Pass. |
| `flutter pub get --offline --enforce-lockfile` and lock hash comparison | Pass, checkout-local metadata regenerated without lock changes. |
| `/usr/bin/python3 -m pytest -q scripts/migration/tests/test_state_session_smoke.py` | Pass, four existing tests. |
| `flutter analyze --no-pub integration_test/migration/rust_state_session_smoke_test.dart` | Pass, no issues. |
| `flutter test --no-pub test/migration/rust_engine_adapter_test.dart --reporter expanded` | Pass, three existing tests. |
| Source-bound Waydroid command above | Pass, three native tests and terminal exit 0. |
| Artifact/source/cleanup readback | Pass, installed APK equals built APK; packaged SO equals stripped SO; owned cleanup complete. |
| Task-private `doc-readback.py` | Pass, local links/anchors, command/results, evidence hashes and unchanged source closure. Repeat pass leaves this note byte-identical. |
| Bundled `docs.py stale .`, `docs.py check .`; `autowork tasks validate --worktree .` | Pass. No docs manifest exists, so scoped readback supplies this note's link coverage. |
| `git diff --check`; preserved-source diff | Pass. |

Scoped Maintain adds only this designated result owner. Existing protocol,
specification, runbook, glossary and M1 history were inspected and remain unchanged.
Reuse decision: keep the existing fixture/launcher and assertions, with no new
repository code, dependencies, duplicate tests or evidence registry. The temporary
ADB shim exists only to constrain the host forward during this run.
The coordinator owns task closure, changelog integration, the merged-tree full
gate and closeout Docs Sync. None is claimed by this worker result.
