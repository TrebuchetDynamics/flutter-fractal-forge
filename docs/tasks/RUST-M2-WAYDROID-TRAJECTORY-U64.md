# RUST-M2-WAYDROID-TRAJECTORY-U64 — installed trajectory and exact u64

## Result and boundary

On **2026-11-12 UTC**, both targets executed on the standing Waydroid instance.
Each completed **one native test, no skips, terminal Flutter exit 0**:

| Target | UTC interval | Flutter encoded aggregate |
| --- | --- | --- |
| `rust_state_trajectory_smoke_test.dart` | 17:01:30–17:04:08 | 6952/32768 bytes |
| `rust_state_u64_smoke_test.dart` | 17:13:36–17:14:33 | 12288/32768 bytes |

Tested base: `cf52b4bdcd32fae6db803400fd1d017dbbd0c0a6`, plus only the two
fixtures' loaded-library diagnostics in this commit. Launcher, original/projected
inputs, native sources, generated bindings and locks are unchanged from that base.
The source manifests bind the actual tested bytes, not an earlier producer build.

The trajectory target ran Thomas, Four Wing and Lorenz 2D: 256-step bounded
progress, exact settings, tolerance-bound Dart point/bounds comparisons, detached
getters, cache reuse, foreign/stale revision rejection, supersession, revocation,
cancellation, legacy view invalidation, closed-session rejection and retained frames
after shutdown. Registered teardown disposes owned frames, progress, snapshots,
requests, guards, sessions and adapter.

The u64 target successfully read both fixed pairs through generated **BigInt**
getters after source-session close, retaining unchanged detached payloads:
`(9007199254740993, 18446744073709551614)` and
`(18446744073709551614, 18446744073709551615)`.

These are Android **container/native FFI** results with `RUST_CORE=true` and
`rendering=false`, not physical GPU, browser, scheduler, production or full-M2
qualification. No app/controller ownership switch follows. The
[installed contract](RUST-PLAN-09.md#installed-trajectory-and-high-u64-execution),
[planned boundary](../engineering/spec.md#planned-rust-engine-boundary) and ADRs
[0005](../adr/0005-rust-owns-all-mathematical-domain-logic.md) /
[0006](../adr/0006-native-demonstration-performance-is-target-specific.md) remain unchanged.

## Durable private evidence

Resolve `GIT_COMMON_DIR` with `git rev-parse --path-format=absolute --git-common-dir`.
Owner-only logs and binaries, not publication artifacts, are retained at:

```text
$GIT_COMMON_DIR/autowork-execution/slot-data/RUST-M2-WAYDROID-TRAJECTORY-U64/attempt-2/evidence/
```

- `admission.json`, `processes-before.log`, `transport.log`, `readiness.log`,
  `consent.json`: supported runner admission/liveness, process inventory, current
  target readiness and typed existing owner / 2026-10-26 consent.
- `setup.log`, `flutter-version.json`, `pub-get.log`, `tools-sha256.json`:
  pinned versions/imports, actual tool identities and offline enforced Pub resolution.
  Setup retains an initial wrong codegen executable-path error and its corrected
  version readback; nothing was installed or downgraded.
- `source-revision.txt`, `source-sha256.json`, `inputs/{trajectory,u64}/*.json`:
  exact runtime/build/fixture/generated closure and complete-record input bytes.
- Each of `trajectory/` and `u64/`: source manifest, exact command, UTC start/end,
  full `flutter.log`, `flutter.exit`, preflight, backend/package readback,
  installed-before/after hashes, retained APK and packaged/unstripped SOs,
  `artifacts.json`, signing/badging, device logs, forward log and owned cleanup.
- `run-waydroid.sh`, `adb-reserved-port.py`, `capture-artifacts.py`, `setup.sh`,
  focused check logs, `doc-readback.py`, `doc-readback.log`, `evidence-sha256.json`:
  reproducible instrumentation and source/artifact/result/document readback.

These are this attempt's first runs; each APK/SO was collected before the next
build. Attempt-1 evidence (including its first-run artifacts and replacement
history) remains untouched at the sibling `attempt-1/evidence/` path. Its older
source/build is historical evidence, not qualification of this base.

## Source and artifact binding

| Source | SHA-256 |
| --- | --- |
| Trajectory fixture | `e4ebc7bfc05ff32806979061f8a4e6960ea3d69a39c6e8260642653be8d4a539` |
| u64 fixture | `cffe115e241c507a109b6ee634c0425f653c79ad59f8c2a16da6a2d96d7ccb32` |
| Launcher | `03ad83f7b2ce2b01c64f2ca53a287a77481e44e5286364b09d9fa4f977350821` |

| Tested artifact | SHA-256 |
| --- | --- |
| Trajectory APK | `bb80cf96114d5f73f473287d5adc3df59fa21852a8b905afd362f6dcabd09615` |
| u64 APK | `ab8abfcbc1cf9acca74451cc93995d41f2daa85f132bede319c5caeb5258fa16` |
| Both packaged **and loaded** x86_64 Rust SOs | `5102c7c9be5b67d2825aaddb1cbe66328e7678610d4b33d57e63e35a46e031f5` |
| Both unstripped Rust SOs | `abe7a548501877181af5f7d9820e26ff52f1777593360af96b608d7b18114310` |

Both APKs are 63,908,030 bytes; their sole Rust ABI is x86_64. Installed `base.apk`
hashes equal the respective built APKs. Packaged SO bytes equal Gradle's stripped
SO. Each fixture requires a Rust SO in its own `/proc/self/maps` and prints the
SHA-256 of that actual file before its native assertions. This reuses the prior
attempt's bounded diagnostic repair for Waydroid's denied host `run-as` access;
no privileged recovery is needed. Existing crypto, test cases, assertions and
handle teardown are reused, without new dependencies or duplicate tests.

Full terminal logs bind each original/projected input hash and aggregate above.
The original baseline SHA-256 checks and 32768-byte guard remain intact.

## Target, tools and execution

Supported runner admission showed this task running; the other active task was
physical-state offline work. Fresh process inspection found no other Android
install/test worker. No interruption or target-contention wait was needed.
Status, normal helper and device inventory passed. Rediscovered serial and matching
`ANDROID_DEVICE` / `ANDROID_DISPOSABLE_DEVICE`: `192.168.240.112:5555`.
Before each target, get-state=`device`, native model=`WayDroid x86_64 Device`,
boot=`1`; session/container remained `RUNNING` on `waydroid-headless`.
The [standing designation](../engineering/testing/waydroid-headless.md#standing-owner-designation-use-this-waydroid-target)
authorized this app-test/replacement cycle, not another device or publication.

Tools: Flutter **3.47.9**, Dart **3.13.7**, framework `c197ca5199`, engine
`89c39edfdf`; Rust/Cargo **1.95.0**; FRB runtime/Dart/generated/codegen **2.13.0**;
cargo-expand **1.0.127**. Flutter matched `fdroid/flutter.version`.
`/usr/bin/python3` 3.12.3 imported pytest 9.0.2, Jinja2 3.1.6 and callable
MarkupSafe `soft_str`. Existing isolated caches and NDK 28.2.13676358 built
x86_64 debug `com.trebuchetdynamics.fractal.forge` 1.1.0+38, minSdk 24,
targetSdk 36. Android 13 backend readback: EGL `mesa`, Vulkan `radeon`, AMD Radeon
Graphics, OpenGL ES 3.2 Mesa 26.0.5. This is context, not hardware qualification.

Each run used `autowork-run timeout --kill-after=10s 1260 bash
"$TMPDIR/r2/run-waydroid.sh" TARGET`, with the inner command bounded to 1200 seconds:

```sh
# TARGET=trajectory uses MODE=--trajectory; TARGET=u64 uses MODE=--extended.
RUSTC="$AUTOWORK_CACHE/rustup-1.95.0/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin/rustc" \
  /usr/bin/python3 scripts/migration/run_state_session_smoke.py "$MODE" -- \
  flutter test --no-pub --no-uninstall \
  "integration_test/migration/rust_state_${TARGET}_smoke_test.dart" \
  -d "$ANDROID_DEVICE" --dart-define=RUST_CORE=true --reporter expanded --dds-port=20500
```

The [private SDK-view forwarding method](RUST-M2-WAYDROID-STATE.md#execution-and-owned-cleanup)
was reused without SDK edits: DDS 20500, shim-constrained ADB host forward 20501,
inside this worker's 20500–20599 allocation. Guest endpoints were 32963 and 44361.
Both terminal teardowns completed. Only recorded owned forwards were removed
(exit 0); all eight pre-existing forwards survived. App force-stop exited 0;
app PID, owned test/DDS processes and host listeners were absent. The final u64
APK remains installed under `--no-uninstall`.

The prior installed APK hash was
`ee3566184abc3449df67082dbdb2b1e2e07e0c5489c8ab2eab19cc6a0a6559dc`.
Both installs replaced the debug test app normally, retaining firstInstallTime
`2026-11-12 16:14:57`; no uninstall retry occurred in this attempt. No unrelated
data deletion, other target, reset/restart, authentication, profile, dependency,
lock, SDK, native/generated source or baseline change occurred.

## Focused checks and scoped Docs Sync Maintain

- Pinned tools/imports, offline enforced Pub resolution and unchanged locks: pass.
- Launcher pytest module: **12 passed**.
- `flutter analyze --no-pub` on both targets: no issues.
- Both native commands: **one test passed each, terminal Flutter exit 0**.
- Private `doc-readback.py`: exact source/input/APK/packaged-and-loaded-SO bindings,
  complete results, owned cleanup, local links and repeat byte-stability: pass.
- Bundled `docs.py stale .`, `docs.py check .`, task validation and
  `git diff --check`: pass. Full check: runner gate.

Scoped Maintain updates only this result owner. The plan/spec, ADRs, prior notes
and Waydroid runbook retain their decisions, history and qualification boundaries.
Task preparation/pruning was read-only; shared task/history closeout belongs to
the coordinator. Omitted: launcher changes, new dependencies/tests/registries,
oracle refresh and unrelated qualification. Next: coordinator integration and
RUST-PLAN-10 reconciliation with separate Linux and remaining M2 proof.
