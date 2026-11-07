# RUST-M1-WAYDROID — designated Android native lifecycle result

## Result and scope

**Passed on the designated Waydroid instance on 2026-11-07 UTC.** The real
[smoke fixture](../../integration_test/migration/rust_engine_smoke_test.dart)
completed with terminal Flutter exit **0**, one test passed and no skipped tests.
The tested source was `9c84e6dae75ac09513194e66ceeb47a9720d951d`.
This result note is the only repository change. The fixture, native bridge,
generated bindings, manifests, locks and default-off behavior are unchanged.

The existing assertions passed through the real native bridge:

- `RUST_CORE=true` and engine version `0.1.0`.
- Rust capability `rendering=false`.
- Two independent native sessions. Closing the first leaves the second readable.
- Duplicate native shutdown, then a closed native capability read that throws
  an error containing `session is closed`.
- Native handle shutdown/disposal in `finally`, duplicate adapter shutdown,
  and a closed adapter capability read that throws `StateError`.

This is Android container evidence only. It does not qualify physical-device or
hardware-GPU timing, Rust rendering, browser execution, Linux execution, later
migration phases, or full M1 without the separate native Linux result and review.
See the [planned Rust boundary](../engineering/spec.md#planned-rust-engine-boundary)
and [remaining proof map](RUST-PLAN-02.md#remaining-proof-map).

## Private evidence

Resolve `GIT_COMMON_DIR` with `git rev-parse --path-format=absolute --git-common-dir`.
The retained private directory is:

```text
$GIT_COMMON_DIR/autowork-execution/slot-data/RUST-M1-WAYDROID/attempt-1/evidence/
```

This is outside disposable `TMPDIR` and is not committed. Directory permissions
are owner-only. `SHA256SUMS` binds the retained files. The main records are:

| Record | Evidence |
| --- | --- |
| `coordination.json` | Worker identity/liveness and process inventory before target use. |
| `transport.log` | Waydroid status, normal connection helper, device inventory, current IP, native model and boot. |
| `setup.log`, `setup.exit`, `flutter-version.json` | Pinned SDK comparison, Python imports, Rust/Cargo/FRB versions, locked offline Pub resolution and unchanged lock hashes. |
| `source.json` | Tested revision and SHA-256 inventory of fixture, adapter, Rust sources/locks, bindings and Android build inputs. |
| `preflight.log` | Exact matching consent/readiness checks, clean source status, Android fingerprint/ABI/backend properties and previous app identity. |
| `command.txt`, `flutter.started`, `flutter.ended` | Exact test invocation and UTC interval. |
| `flutter.log`, `flutter.exit` | Complete build/install/test output and terminal exit `0`. |
| `artifacts.json`, `readback.log` | Built/installed APK identity, packaged and unstripped native-library identities, NDK version and guest compositor readback. |
| `cleanup.log`, `cleanup.exit` | Owned app stopped, no app PID, no remaining task test process or DDS listener, and healthy target after the run. |
| `flutter-device.log`, `activity-device.log`, `forward-cleanup.json` | Test-interval app PID/VM port, Impeller opt-out diagnostic, and removal of only the proven owned ADB forward. |
| `adapter-tests.log`, `adapter-tests.exit` | Three existing offline adapter cases passed, including default-off/Web no-load. |

An initial CLI setup attempt used unsupported `--host-vmservice-port` and exited
64 before building or testing. Its `cli-setup-*` records remain separate. The
final supported invocation below passed. That setup attempt is not a native test
failure or a passing run.

## Source, tools and target

| Field | Tested value |
| --- | --- |
| Fixture SHA-256 | `c09568fb6a194de535e043e322e198fb2f14b461cb965bc1315c839c8dee6b1c` |
| Flutter / Dart | `3.47.9` / `3.13.7`; Flutter version compared with `fdroid/flutter.version` |
| Flutter framework / engine | `c197ca5199e9ee5661e865596c9c07294dfab51c` / `89c39edfdfae2949f6806e4a315c0c08522238b7` |
| Rust / Cargo | `1.95.0` (`59807616e1fa2540724bfbac14d7976d7e4a3860`) / `1.95.0` (`f2d3ce0bd`) |
| FRB runtime / Dart runtime / codegen | `2.11.1` / `2.11.1` / `2.11.1` |
| Native build | Debug, `x86_64-linux-android`, NDK `28.2.13676358` (`r28c`), Cargo `--locked --offline` |
| Flutter app | `com.trebuchetdynamics.fractal.forge`, version `1.1.0`, versionCode `38`, minSdk `24`, targetSdk `36` |
| Serial / state | Rediscovered `192.168.240.112:5555` / `device` |
| Native model / boot | `WayDroid x86_64 Device` / `sys.boot_completed=1` |
| Android / ABI | `13` / `x86_64,x86` |
| Session / container / display | `RUNNING` / `RUNNING` / existing `waydroid-headless` |
| Rust backend | Native FRB FFI; no Rust rendering backend (`rendering=false`) |
| Guest graphics readback | `ro.hardware.egl=mesa`, `ro.hardware.vulkan=radeon`; SurfaceFlinger reports AMD Radeon Graphics, OpenGL ES 3.2 Mesa `26.0.5` |
| Test interval | `2026-11-07T08:36:01+00:00` through `2026-11-07T08:37:32+00:00` |

The guest fingerprint in `preflight.log` is
`waydroid/lineage_waydroid_x86_64/waydroid_x86_64:13/TQ3A.230901.001/eng.aleast.20260403.132616:userdebug/test-keys`.
The graphics readback describes the container compositor, not proof of a Rust
renderer or a physical GPU performance measurement.

APK SHA-256, verified against the installed `base.apk`:

```text
168e636131b63a5facdb1d78c428cafabc0e6fdaf383a8efd6f8945e186300fe
```

Packaged `lib/x86_64/libfractal_bridge.so` SHA-256 (1,446,640 bytes):

```text
6fbbdeaeb29aee700d094720a13c59bf3b55542233f8b26afb2bc0b2655b9a8a
```

Unstripped Cargo/debug SO SHA-256 (29,227,768 bytes):

```text
5ff45b6719fe1ead07af8f3481d2a2ea1412a605f6a9d9bf182db9abf2d90f5e
```

The packaged SO matches Gradle's stripped native output. `artifacts.json` records
all local SO stages. The APK contains only the requested x86_64 Rust library.

## Execution and owned cleanup

The worker used the runner's admitted `live, waydroid` task. Before target use,
slot/process inspection found the ACAD-013-4142ef42 worker absent and its attempt
held, not actively using the device. No active Android test/install process was
found. No device-contention wait was needed. Historical claims were not removed,
and no other worker, container, compositor or shared ADB server was stopped.

The [standing target contract](../engineering/testing/waydroid-headless.md#standing-owner-designation-use-this-waydroid-target)
supplied the existing app-testing/replacement consent. The current IP came from
`waydroid status`, not a substituted device. `waydroid adb connect` exited 0;
`adb devices -l`, actual `get-state`, the native model and boot checks all passed.
Both `ANDROID_DEVICE` and `ANDROID_DISPOSABLE_DEVICE` were exported as
`192.168.240.112:5555`. No recovery, restart, key enrollment or privileged command
was needed.

Process-local setup selected `$AUTOWORK_CACHE/flutter-3.47.9`, its provisioned
`pub-cache`, `cargo-1.95.0`, `rustup-1.95.0` and FRB codegen cache. Rust's direct
1.95.0 toolchain binaries were on `PATH`. Python was `/usr/bin/python3` 3.12.3,
with pytest 9.0.2, Jinja2 3.1.6 and callable MarkupSafe `soft_str`. Offline Pub
resolution enforced the lockfile. No SDK, dependency or host/profile installation
was required.

The long-command wrapper was
`autowork-run timeout --kill-after=10s 1140 bash "$TMPDIR/run-waydroid-probe.sh"`.
Inside it, a 1,080-second timeout bounded this exact supported invocation:

```sh
flutter test --no-pub --no-uninstall integration_test/migration/rust_engine_smoke_test.dart \
  -d 192.168.240.112:5555 --dart-define=RUST_CORE=true \
  --reporter expanded --dds-port=20100
```

DDS used the allocated worker port. This Flutter `test` command does not expose a
host VM-service port option. It automatically allocated ADB forward
`tcp:32993 → tcp:36953`, outside the worker port range. Thus this run was not fully
port-constrained. The owned forward was identified and removed after testing;
no SDK patch or broader port allocation was made. Gradle built the native library
and debug APK.
The first installation returned `INSTALL_FAILED_VERSION_DOWNGRADE`: versionCode
38 was older than installed versionCode 122. Flutter then uninstalled the old
app and installed this test APK under the standing replacement consent. This
replacement can delete the app's private data; the old installation was not
restored. The full output retains that intermediate failure rather than hiding it.
The final native test and Flutter process exited successfully:

```text
00:00 +0: native version, capabilities and isolated handle lifecycle
00:00 +1: (tearDownAll)
00:00 +1: All tests passed!
```

After installed-APK hash readback, the worker force-stopped only the tested app.
`pidof com.trebuchetdynamics.fractal.forge` exited 1 (absent). The test process and
DDS port 20100 were no longer present. The debug APK remains installed, as requested
by `--no-uninstall`. ActivityManager bound test app PID `25119` to the package,
and its test-interval Flutter log identified guest VM port `36953`. The worker
removed only the corresponding ADB forward, `tcp:32993`, with terminal exit 0.
Before/after inventories prove the other eight forward entries were preserved.
The shared ADB server was left running. Waydroid remained `RUNNING` and its serial
remained `device`.

Reuse decision: retain the existing fixture and all assertions without new
instrumentation, codegen, manifests or duplicate tests. Only this evidence owner
needed a change. The runner still owns merged-tree/full-main verification and
coordinator task closure. This note does not claim either occurred.
