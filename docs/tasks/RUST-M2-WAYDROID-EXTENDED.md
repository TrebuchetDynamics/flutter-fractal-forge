# RUST-M2-WAYDROID-EXTENDED — installed effects and Future transport

## Result and boundary

On **2026-11-07 UTC**, both source-bound targets completed real native assertions
on the standing Waydroid instance, with **terminal Flutter exit 0**:

| Target | Executed result | UTC interval |
| --- | --- | --- |
| `integration_test/migration/rust_state_extended_smoke_test.dart` | 4 tests passed, no skips | 18:50:48–18:53:05 |
| `integration_test/migration/rust_state_async_smoke_test.dart` | 2 tests passed, no skips | 18:53:25–18:54:18 |

Tested source revision: `df3c2fcffd5fd823d3184ba748496030c7ed3730`.
The fixtures, launcher, bridge, Rust, baseline inputs and locks are unchanged.
This note is the only repository change.

The [extended assertion inventory](RUST-M2-EXTENDED-FIXTURE.md#assertion-inventory-and-handle-rules)
ran: source-input rejection, all eleven effects against the Dart controller,
forced-policy restoration and atomic rollback, exact Number Walls frames for all
six sequences, rejection retention, borrowed-request ownership and closed lifecycle.
The [Future fixture](RUST-M2-ASYNC-STEP.md#input-source-and-artifact-identities)
ran awaited begin/advance/cancel/snapshot/shutdown operations, exact Dart-frame
comparisons, stale/foreign request rejection, navigation and detached frame reads.
Both fixtures disposed owned handles through their registered teardown.

These are Android **container/native FFI** results with `RUST_CORE=true` and
`rendering=false`. They do not prove successful high-u64 outputs, scheduler
fairness, whole-session/UI responsiveness, full M2, Linux/browser execution,
physical hardware/GPU performance or production qualification. Wrong large
identity/revision operands remain input-only rejection checks.
Sources: [migration plan](../planning/refactor-plan.md#flutter-shell-and-rust-engine-migration)
and [installed qualification contract](RUST-PLAN-07.md#installed-native-qualification).

## Durable private evidence

Evidence is retained outside Git at:

```text
$GIT_COMMON_DIR/autowork-execution/slot-data/RUST-M2-WAYDROID-EXTENDED/attempt-1/evidence/
```

`GIT_COMMON_DIR` is the absolute result of
`git rev-parse --path-format=absolute --git-common-dir`. Logs and APKs are private,
not publication artifacts. The evidence includes:

- `source-revision.txt`, `source-sha256.json`, `inputs/*.json`, `locks-before.sha256`:
  tracked runtime/build/fixture closure and actual projected input bytes.
- `admission.json`, `admission.txt`, `consent.json`, `setup.log`, `pub-get.log`:
  supported admission/liveness, existing typed consent, target and pinned tools.
- Each of `extended/` and `async/`: `command.txt`, `flutter.started`,
  `flutter.ended`, full `flutter.log`, `flutter.exit`, `preflight.log`,
  `artifacts.json`, `app-debug.apk`, packaged/unstripped SOs, APK signing/badging,
  installed-before/after hashes, package/backend readback and device logs.
- Each target's `forward-shim.jsonl`, `forwards-before.txt`,
  `forward-cleanup.json`, `cleanup.log`: exact owned mapping and terminal cleanup.
- `run-waydroid.sh`, `adb-reserved-port.py`, `capture-artifacts.py`,
  `doc-readback.py`, focused check logs and `evidence-sha256.json`:
  private instrumentation and reproducible source/artifact/doc readback.

## Source, input and artifact binding

| Source | SHA-256 |
| --- | --- |
| Extended target | `073bb9ea74626e65647dab25a4cf301d9d6f81b2115b715bf45467c9fbdd77bc` |
| Future target | `bfecda61999fd34108402537b0122b199a87b6c8a4e2641868be4e40cef69a24` |
| Launcher | `459e5cb13db5b00aace7e4e69214b158432dac6d624c39dce4be034f92cd7154` |

Both runs printed the following original/projected bindings. Original paths are
`migration/baseline/<kind>.json`; seven complete records and explicit derived
provenance are retained. Flutter's encoded aggregate was **12288/32768 bytes**,
including `RUST_CORE=true`. No guard or assertion was weakened.

| Kind | Original SHA-256 | Projected SHA-256 |
| --- | --- | --- |
| modules | `571fb9c2c6ae14572485574c4ca382de2a55eeb6a32e5958869a671d2fbd62d3` | `afc6f18acd52dfdf6d11029c5d46a889f4e07393a5a9fa521a9c7e4f719a3c0f` |
| parameters | `5c8dff3eef955aed9d46f203136dea42b0b070d9bda2966fa4938fac1a6d9517` | `46ab96397b86b330462671b2f1374257dba15bf25ec81e65630cc960c689923d` |
| presets | `318a6c336b2f4310d4fef0d5b7ae09f8a2bff5597471eac742757b088c6b381e` | `d7bb5a2651467e00414c1dbad5fb107ac666b3962e5331be9280df88e739dc87` |
| capabilities | `5f6e0c69a46faf5ebfa627757a9fc29b7124624b038ada4ca21241fe240261aa` | `f29b25e6dd11ba3e53f1aea551488d263c3f3a98973fe0bf33be2180c796959c` |

| Tested artifact | SHA-256 |
| --- | --- |
| Extended APK | `d7f46d545a8a5936cff4e59c1fa300f40174f9b067c8e02ad6341a072e1fc7b0` |
| Future APK | `02e71c1689d0b08651a21cc8e84a9b61b0a5e52e17f65b3b8b84f378b5787048` |
| Both APKs' `lib/x86_64/libfractal_bridge.so` | `921a078dde03e3ed26087b669463b1e19a61ac74094595b0a346269a42c5da5d` |
| Both unstripped Cargo/debug SOs | `5fd5101c229c27301f1bea87053a89311c95f74f5872f541682d3dd26ea1a69b` |

Each APK is 65,806,870 bytes. Its only Rust ABI is x86_64. The packaged SO is
4,228,032 bytes and equals Gradle's stripped output; the unstripped SO is
47,081,264 bytes. Each installed `base.apk` hash equals its tested build.

## Target, tools and existing consent

The supported read-only admission report showed this task running, with
ACAD-013-4142ef42 held and `worker_live=false`. Fresh process inspection found no
other Android test/install worker. There was no device contention or interruption.
The [standing owner designation](../engineering/testing/waydroid-headless.md#standing-owner-designation-use-this-waydroid-target)
provided existing **owner / 2026-10-26** app-test/install/replacement consent;
`consent.json` records that authority, not new planner or publication permission.

`waydroid status`, the normal `waydroid adb connect` helper and `adb devices -l`
passed. The serial was rediscovered from this instance's current IP, not selected
from another device. Matching `ANDROID_DEVICE` / `ANDROID_DISPOSABLE_DEVICE`
were exported as `192.168.240.112:5555`; get-state, native model and boot assertions
all passed before each run:

| Field | Observed value |
| --- | --- |
| ADB state / native model / boot | `device` / `WayDroid x86_64 Device` / `1` |
| Session / container / display | `RUNNING` / `RUNNING` / existing `waydroid-headless` |
| Android / ABI | `13` / `x86_64,x86` |
| Graphics context, not hardware qualification | EGL `mesa`, Vulkan `radeon`; AMD Radeon Graphics, OpenGL ES 3.2 Mesa `26.0.5` |
| App / build | `com.trebuchetdynamics.fractal.forge`, debug `1.1.0+38`, minSdk 24, targetSdk 36 |
| Flutter / Dart | `3.47.9` / `3.13.7`, matched `fdroid/flutter.version` |
| Framework / engine revision | `c197ca5199e9ee5661e865596c9c07294dfab51c` / `89c39edfdfae2949f6806e4a315c0c08522238b7` |
| Rust / Cargo / FRB runtime and generated transport | `1.95.0` / `1.95.0` / `2.11.1` |
| Android native build | `x86_64-linux-android`, NDK `28.2.13676358`, locked/offline Cargo |

Setup reused `FLUTTER_ROOT=$AUTOWORK_CACHE/flutter-3.47.9`,
`PUB_CACHE=$AUTOWORK_CACHE/pub-cache`, `CARGO_HOME=$AUTOWORK_CACHE/cargo-1.95.0`
and the existing target-enabled compiler at
`$AUTOWORK_CACHE/rustup-1.95.0/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin/rustc`.
Python was `/usr/bin/python3` 3.12.3; pytest 9.0.2, Jinja2 3.1.6 and callable
MarkupSafe `soft_str` imports passed. Lockfile-enforced offline Pub resolution
regenerated only checkout-local metadata. No SDK/dependency installation, profile,
key, credential, container reset/restart or other-device operation occurred.

The prior installed APK was the retained [StateSession test](RUST-M2-WAYDROID-STATE.md#execution-and-owned-cleanup),
SHA-256 `0d8eea9c173680a6402300700ba41304a7430b6379e1af96b65d468d4b0ff49e`.
Extended then Future replaced it without uninstall or downgrade retries.
Both preserve firstInstallTime `2026-11-07 08:37:31` and Android Debug signer
SHA-256 `73c58e9435161f7826d6eb4f7155243a8609468b204472e45a8b0e1e3715ecff`.
Earlier signed-app replacement history remains in the linked notes.

## Execution and owned cleanup

Each run used `autowork-run timeout --kill-after=10s 1260 bash "$TMPDIR/run-waydroid.sh" TARGET`.
The script bounded each launcher/Flutter command to 1200 seconds:

```sh
# TARGET is extended, then async; both commands were executed.
RUSTC="$AUTOWORK_CACHE/rustup-1.95.0/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin/rustc" \
  /usr/bin/python3 scripts/migration/run_state_session_smoke.py --extended -- \
  flutter test --no-pub --no-uninstall \
  "integration_test/migration/rust_state_${TARGET}_smoke_test.dart" \
  -d "$ANDROID_DEVICE" --dart-define=RUST_CORE=true --reporter expanded --dds-port=20300
```

The [reserved-host-forward method](RUST-M2-WAYDROID-STATE.md#execution-and-owned-cleanup)
was reused without SDK edits. A task-private Android SDK symlink view delegated
this serial's `forward tcp:0` through a logged ADB shim to host `tcp:20301`.
DDS used 20300, within this worker's 20300–20399 allocation. Guest VM ports were
37333 (extended) and 37113 (Future); these are guest-side endpoints, not additional
host allocations. Full logs retain real Gradle install and terminal Flutter
assertion output. Existing Java source/target 8 warnings remained visible.

The initial private artifact collector looked in `rust/target`, not the Android
plugin's actual Cargo target directory. This caused a post-test collection error,
not a Flutter failure: the extended terminal result was already exit 0. The
collector was corrected and successfully read the extended APK/SO before the
Future build overwrote the output. No repository change or test rerun was needed.

After each run, only the tested app was force-stopped (exit 0); `pidof` exited 1
(absent). Each recorded owned forward was removed with exit 0. All eight
pre-existing forwards were preserved. Owned test/DDS processes and host listeners
were absent, and Waydroid remained `RUNNING` with the serial still `device`.
The final Future APK remains installed under `--no-uninstall`; no old APK was
restored and no unrelated data was deleted.

## Focused checks and scoped Docs Sync Maintain

| Check | Final result |
| --- | --- |
| Status/helper/devices and matching consent/get-state/model/boot checks | Pass, actual designated transport ready. |
| Pinned tools/imports; `flutter pub get --offline --enforce-lockfile`; lock hashes | Pass, unchanged locks. |
| `/usr/bin/python3 -m pytest -q scripts/migration/tests/test_state_session_smoke.py` | Pass, 8 existing tests. |
| `flutter analyze --no-pub integration_test/migration/rust_state_extended_smoke_test.dart integration_test/migration/rust_state_async_smoke_test.dart` | Pass, no issues. |
| Extended native command above | Pass, 4 tests, terminal Flutter exit 0. |
| Future native command above | Pass, 2 tests, terminal Flutter exit 0. |
| Private `doc-readback.py` | Pass, exact source/input/artifact/terminal/cleanup bindings, local links/anchors and repeat byte-stable note. |
| Bundled Docs Sync `docs.py stale .`, `docs.py check .`; `autowork tasks validate --worktree .` | Pass. No docs role manifest exists; scoped readback supplies this note's coverage. |
| `git diff --check`; preserved source/lock readback | Pass. |

Scoped Maintain adds only this task's result owner. The producer notes, migration
plan, installed qualification contract and Waydroid runbook were inspected; their
historical results and acceptance remain unchanged. Reuse: existing targets,
launcher, oracles, handle teardown and forwarding method. Omitted: unnecessary
code, dependencies, duplicate tests, a new evidence registry and unrelated campaigns.
The coordinator owns integration, task/changelog closeout, the merged-tree gate
and final Docs Sync. Next: **RUST-PLAN-08** reconciles these source-bound results
with the separate Linux result and remaining M2 proof; no full-M2 claim is made here.
