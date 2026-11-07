# RUST-M1-LINUX — Installed Linux Rust probe result

## Outcome

**PASS: Linux native probe lifecycle**, executed on 2026-11-07 UTC at
`9c84e6dae75ac09513194e66ceeb47a9720d951d`. The checkout was unchanged during
execution. This result note is the only repository change.

The existing [smoke fixture](../../integration_test/migration/rust_engine_smoke_test.dart)
ran through the [reserved-port wrapper](../../scripts/run-native-integration.sh)
and the [official integrationDriver adapter](../../test_driver/integration_test.dart).
The binding completed one lifecycle test and teardown (`+2`). The host received
`All tests passed.` and wrote `{"allTestsPassed":true}` to `protocol-success.json`.
The final `run.json` records:

```json
{"exit_code":0,"protocol_success":true,"cleanup":{"remaining_pids":[]}}
```

The unchanged assertions verify native version `0.1.0`, `rendering=false`, two
independent handles, duplicate shutdown, rejection of a closed native handle,
continued access through the other handle, and rejection of a closed adapter.
No mock or build-only result substitutes for these native calls.

This closes the Linux runtime-proof gap only. **M1 remains unqualified until the
separate RUST-M1-WAYDROID result also passes.** It does not qualify Rust rendering,
physical hardware, performance, Web, production routing, or RUST-ENGINE-001.

## Invocation and environment

The worker supplied the actual `AUTOWORK_PORT_BASE=20100` allocation
(`20100..20199`) and private `TMPDIR=/var/tmp/aw-1000-48137133-2` (mode `0700`).
No replacement lease or coordinator receipt was needed.

```sh
export FLUTTER_ROOT="$AUTOWORK_CACHE/flutter-3.47.9"
export PUB_CACHE="$AUTOWORK_CACHE/pub-cache"
export RUSTUP_HOME="$AUTOWORK_CACHE/rustup-1.95.0"
export CARGO_HOME="$AUTOWORK_CACHE/cargo-1.95.0"
export PATH="$FLUTTER_ROOT/bin:$RUSTUP_HOME/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin:$AUTOWORK_CACHE/flutter-rust-bridge-2.11.1/bin:/usr/bin:$PATH"
flutter pub get --offline --enforce-lockfile
autowork-run timeout --kill-after=10s 660 bash scripts/run-native-integration.sh integration_test/migration/rust_engine_smoke_test.dart --timeout 600 --dart-define=RUST_CORE=true
```

- Flutter `3.47.9`, framework `c197ca5199e9ee5661e865596c9c07294dfab51c`,
  Dart `3.13.7`, engine `89c39edfdfae2949f6806e4a315c0c08522238b7`.
  The version matched `fdroid/flutter.version`. The provisioned SDK path resolves
  to `/home/xel/flutter`; no SDK source was changed.
- Rust `1.95.0` (`59807616e1fa2540724bfbac14d7976d7e4a3860`), Cargo `1.95.0`.
  FRB Rust/Dart/codegen remain pinned to `2.11.1`. Existing caches were reused.
- `/usr/bin/python3` `3.12.3`: pytest `9.0.2`, Jinja2 `3.1.6`, and callable
  `markupsafe.soft_str` verified. Offline package resolution preserved `pubspec.lock`.
- Linux x86_64 debug bundle under owned Xvfb, `1280x800x24`, TCP disabled.
  The wrapper used `flutter drive -d linux --debug --no-pub --no-dds
  --no-devtools --no-publish-port --no-keep-app-running`, both VM-service ports
  `20100`, and `INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE=false`.
  The full argument array is retained in `run.json`.
- The only observed owned TCP listener was IPv4 loopback `127.0.0.1:20100`.
  Each invocation recorded no remaining owned PIDs after cleanup.

## Native library and backend identity

The final owned app's `/proc` maps identify the bundled `libfractal_bridge.so`
as loaded. The built and bundled Rust libraries have the same SHA-256 below.
The maps also identify Mesa EGL/GLES, Gallium and LLVM libraries.
`glxinfo -B` on that app's actual Xvfb display (`:99`) exited 0 and reported
Mesa `25.2.8`, `llvmpipe (LLVM 20.1.2, 256 bits)`, `Accelerated: no`.
This is software GLX context identity, not proof of Flutter frame output or its
specific renderer selection. Rust reports `rendering=false`; no Rust/wgpu
renderer or hardware GPU is exercised.

| Input or build artifact | SHA-256 |
| --- | --- |
| Smoke target | `c09568fb6a194de535e043e322e198fb2f14b461cb965bc1315c839c8dee6b1c` |
| Official driver adapter | `51382a5b3b178c6454a9d04eeb0cbb3d207b3c43117ecfd6e38a6ef058029343` |
| Runtime wrapper | `5d0963a8f0e05f1d340bc62d45fdf09384f15f1a28149312a1bb533a68dc070c` |
| `build/linux/x64/debug/bundle/lib/libfractal_bridge.so` | `950a6a30ca4ef1c8dd94f019d38b09cb12293cbea93b8bfe20f014d4b07ed930` |
| `build/linux/x64/debug/bundle/flutter_fractals` | `f6e9d833fea1f785668a73d0edbeb630ec472882508806a96e5e0dfc86ca8bc0` |
| `build/linux/x64/debug/bundle/lib/libflutter_linux_gtk.so` | `03e4773db4b0099718fea41520685a195684b5158bc074b6c837178783bb35f9` |

## Retained private evidence

Persistent evidence root, outside disposable task scratch:

```text
/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/slot-data/RUST-M1-LINUX/attempt-1/native-evidence
```

- `final/`: complete `driver.log`, `run.json`, `protocol-success.json` and
  `outputs/` from `native-integration-cukhok5d`. These establish the terminal pass.
- `identity.json`: tested revision, source hashes (Rust, adapter, generated glue,
  Linux integration, locks and SDK pin), full bundle hashes and toolchain paths.
- `backend/`: actual app maps, loaded-library hashes, same-display GLX output,
  app PID/process group and association with the final protocol response path.
- `rust-m1-linux-terminal-final.log`, `rust-m1-linux-toolchain.log`,
  `rust-m1-linux-pub-get.log`, `rust-m1-linux-adapter.log`, and
  `rust-m1-linux-wrapper-tests.log`: complete command output.
- `rust-m1-linux-refusals.json` and matching logs: missing allocation and missing
  private `TMPDIR` each refused with exit 2 before launch.
- `initial/` and `backend-attempt/`: two earlier native passes with full receipts.
  `backend-observer-incomplete/` preserves the first optional observer's partial
  GLX output. That observer raced display teardown and reached its deadline;
  it is not a passed observation. The corrected observer completed on the final run.
- `verify-evidence.py`, `verification.log` and `evidence.sha256`: retained readback
  command, its results, and an integrity inventory. Logs can contain private local
  VM-service connection details and must not be copied into public artifacts.

## Checks and limits

- `flutter test --no-pub test/migration/rust_engine_adapter_test.dart --reporter expanded`:
  **3 passed**.
- Exact native wrapper command above: **passed**. Final receipt and official
  protocol response agree on success, and cleanup has no remaining PIDs.
- `/usr/bin/python3 -m pytest -q test/scripts/test_reserved_native_driver.py`:
  **12 passed**, including refusal and owned-cleanup regressions.
- Evidence readback verifies source/build/backend hashes and all three terminal
  receipts. Scoped Docs Sync Maintain checks this note's links, anchors, commands
  and unchanged runtime inputs. `git diff --check` passes.

The existing fixture, driver, wrapper and document owners were reused. No fixture
instrumentation, duplicate probe, dependency, manifest, saved format, controller,
or production behavior changed. `RUST_CORE` remains default-off. The runner owns
the merged-tree/full-main gate; it was not rerun by this worker.

The coordinator must integrate this note and reconcile task status. The separate
Waydroid task supplies Android functional evidence. Later tasks retain hardware,
rendering, performance and full-goal gates from the
[remaining proof map](RUST-PLAN-02.md#remaining-proof-map),
[planned boundary](../engineering/spec.md#planned-rust-engine-boundary), and
[owned Linux runtime](../engineering/runbook.md#owned-linux-runtime-with-reserved-ports).
