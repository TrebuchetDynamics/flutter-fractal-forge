# RUST-M2-LINUX-STATE — Installed Linux StateSession transport

## Outcome

**PASS: source-bound Linux StateSession transport**, executed on 2026-11-07 UTC
at `61643ca955feea1e0885d5392a64809fe4d265fe`. The checkout was unchanged during
execution. This result note is the only repository change.

The [four-module projection launcher](../../scripts/migration/run_state_session_smoke.py)
supplied the real [StateSession target](../../integration_test/migration/rust_state_session_smoke_test.dart)
to the existing [reserved-port wrapper](../../scripts/run-native-integration.sh)
and [official integrationDriver adapter](../../test_driver/integration_test.dart).
Both native runs completed three test bodies and teardown (`+4`), with full terminal
output retained. The final `run.json` records:

```json
{"exit_code":0,"protocol_success":true,"cleanup":{"remaining_pids":[]}}
```

The official response is `{"allTestsPassed":true}` in `protocol-success.json`.
The terminal log names all three tests:

- `source-bound input protocol refuses missing/truncated/tampered data`
- `real synchronous StateSessions preserve transactions and lifecycle`
- `native StateValue getters retain exact scalar type and text`

This is executed native FRB transport, not a probe-only, compilation, staging or
supplemental `flutter run` result. Assertions were not changed or skipped. The
[fixture's existing assertions](RUST-M2-NATIVE-FIXTURE.md#fixture-assertions-compiled-not-executed)
now have Linux runtime evidence: independent identities and four-module defaults;
ordered batch/singleton equivalence; nonfinite normalization; empty/no-op revisions;
wrong/stale rejection; atomic rollback; retained snapshots; reset/shutdown/closed
errors; exact scalar types and text. Default-off no-load behavior, legacy GPU policy
and `rendering=false` also passed. The older fixture note remains its historical
build-only result, not a claim about this later execution.

## Invocation and environment

The actual worker allocation was `AUTOWORK_PORT_BASE=20100` (`20100..20199`),
with private `TMPDIR=/var/tmp/aw-1000-48137133-2`, mode `0700`. No replacement
port, SDK edit, device operation or unrelated process cleanup was used.

```sh
export FLUTTER_ROOT="$AUTOWORK_CACHE/flutter-3.47.9"
export PUB_CACHE="$AUTOWORK_CACHE/pub-cache"
export RUSTUP_HOME="$AUTOWORK_CACHE/rustup-1.95.0"
export CARGO_HOME="$AUTOWORK_CACHE/cargo-1.95.0"
export PATH="$FLUTTER_ROOT/bin:$RUSTUP_HOME/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin:/usr/bin:$PATH"
flutter pub get --offline --enforce-lockfile
/usr/bin/python3 scripts/migration/run_state_session_smoke.py -- autowork-run timeout --kill-after=10s 660 bash scripts/run-native-integration.sh integration_test/migration/rust_state_session_smoke_test.dart --timeout 600 --dart-define=RUST_CORE=true
```

- Flutter `3.47.9` matches `fdroid/flutter.version`; Dart `3.13.7`, framework
  `c197ca5199e9ee5661e865596c9c07294dfab51c`, engine
  `89c39edfdfae2949f6806e4a315c0c08522238b7`. The provisioned SDK resolves to
  `/home/xel/flutter`.
- Rust `1.95.0` (`59807616e1fa2540724bfbac14d7976d7e4a3860`), Cargo `1.95.0`;
  FRB Rust/Dart/codegen `2.11.1`. Existing SDKs and caches were reused, not installed.
- `/usr/bin/python3` `3.12.3`, pytest `9.0.2`, Jinja2 `3.1.6`, and callable
  `markupsafe.soft_str` verified. Offline dependency resolution preserved the lockfile.
  The existing host `ld.lld` shim resolves to `/usr/bin/ld`; no tooling was changed.
- The wrapper used `flutter drive -d linux --debug --no-pub --no-dds --no-devtools
  --no-publish-port --no-keep-app-running`, both VM-service ports `20100`, and
  `INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE=false`. Its complete command
  array, including all compressed input defines, is retained in each `run.json`.
- Xvfb was owned by the wrapper, `1280x800x24`, TCP disabled. The only observed
  owned TCP listener was `127.0.0.1:20100`. Both runs ended with no remaining
  owned PIDs. Missing allocation and missing `TMPDIR` separately refused with
  exit `2` before launch.

## Source, input and build identities

The launcher verified all original envelopes before selecting complete records
for `mandelbrot`, `julia`, `cantor_set` and `recursive_sine_sphere`. It retained
record order, fields, scalar kinds and numeric token spelling, with explicitly
[derived fixture provenance](RUST-M2-NATIVE-FIXTURE.md#input-protocol).
Original paths are `migration/baseline/<kind>.json`; projected hashes bind decoded
compact UTF-8 bytes. Both sets of bytes are retained privately.

| Kind | Original SHA-256 | Projected SHA-256 |
| --- | --- | --- |
| modules | `571fb9c2c6ae14572485574c4ca382de2a55eeb6a32e5958869a671d2fbd62d3` | `da7bad4bfde2db8e5a995a9ca1a314c6bc965664de6c12bb42413776b5e1165e` |
| parameters | `5c8dff3eef955aed9d46f203136dea42b0b070d9bda2966fa4938fac1a6d9517` | `2ac3fea39d030b3acf18c2e361f5859426ef709914ff9b75582cd0664b05e762` |
| presets | `318a6c336b2f4310d4fef0d5b7ae09f8a2bff5597471eac742757b088c6b381e` | `b24a99f57fcff5e0052d1ef44fbced8731bcb4b6e39a5cfd58a03c10db052beb` |
| capabilities | `5f6e0c69a46faf5ebfa627757a9fc29b7124624b038ada4ca21241fe240261aa` | `1041f69847161b0ede0bf5413cfa4613d9f0aaa16e9a5a5fcb51c14e6effe8fa` |

The launcher measured **9704/32768 bytes**, including `RUST_CORE=true`. Readback
of actual generated Linux CMake `DART_DEFINES` measured **10129/32768 bytes**,
including driver and Flutter internal flags, and decoded all four projected inputs
byte-for-byte. The aggregate guard and all missing/truncated/tampered-input
assertions remain intact. Whole original-envelope byte transport and full-catalog
parity are **not** claimed.

| Source or build artifact | SHA-256 |
| --- | --- |
| StateSession target | `bb1c415c8a581294472d67d9bce8f1ec47914dcbb80d90bb5d4d5b4018b373b5` |
| Projection launcher | `4e2eb60a2f62611d03c8eb65ddd7e87ffcd0d8da5345eab290c3d242050ddb7c` |
| Official driver adapter | `51382a5b3b178c6454a9d04eeb0cbb3d207b3c43117ecfd6e38a6ef058029343` |
| Runtime wrapper | `5d0963a8f0e05f1d340bc62d45fdf09384f15f1a28149312a1bb533a68dc070c` |
| Bundled `lib/libfractal_bridge.so` | `64a164b6cb12ca7bfed01be441c73ea47c72c997acde3396294366b339b7b15d` |
| Bundle executable `flutter_fractals` | `254db7eb02efc48f023b925e7d48c225826914d31838acf4133deca4df2bb4d0` |
| Bundle `data/flutter_assets/kernel_blob.bin` | `c3882762b545df7444b8810bebffb9130ea1da167ddec486b83deada21e5e562` |
| Bundled `lib/libflutter_linux_gtk.so` | `03e4773db4b0099718fea41520685a195684b5158bc074b6c837178783bb35f9` |

The final app's `/proc` maps identify this bundled Rust library as loaded; it also
matches the CMake Rust build output. The maps identify Mesa EGL/GLES, Gallium and
LLVM. The reused M1 read-only observer ran `glxinfo -B` on that app's actual display
`:99`: Mesa `25.2.8`, `llvmpipe (LLVM 20.1.2, 256 bits)`, `Accelerated: no`, exit `0`.
This identifies the software display context and loaded libraries, **not** Flutter
frame output or a specific Flutter renderer selection. Rust uses native FRB FFI
and reports `rendering=false`; no Rust/wgpu renderer or hardware GPU is qualified.

## Retained private evidence and checks

Persistent root, outside the disposable checkout and scratch:

```text
/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/slot-data/RUST-004-2dccfb82/attempt-1/native-evidence
```

- `final/`: complete `driver.log`, `run.json`, `protocol-success.json`, and driver
  `outputs/` from `native-integration-afogcm8j`; these establish the terminal result.
  `initial/` retains the earlier complete passing run from `native-integration-36136qak`.
- `identity.json`: tested revision, 463 source-file hashes, 572 build-file hashes
  (full bundle plus Rust output/build configuration), input hashes and tool paths.
  `inputs/` preserves original and projected bytes. Generated CMake configuration,
  CMake cache and Ninja build instructions are retained alongside the inventories.
- `backend/`: actual app maps, loaded-library hashes, same-display GLX output,
  owned process group and exact protocol-result path. `observe-native-backend.py`
  is reused unchanged from the [M1 evidence](RUST-M1-LINUX.md#retained-private-evidence).
- `state-session-launch-final.log`, `state-session-launch.log`,
  `state-session-backend-observer.log`, `toolchains.log`, `pub-get.log`,
  `launcher-tests.log`, `refusals.json` and corresponding refusal logs retain
  command output, input/aggregate identities and fail-closed preflight results.
- `verify-evidence.py`, `verification.log` and `evidence.sha256` retain the readback
  procedure, results and private integrity inventory. Driver logs contain local
  VM-service connection details; do not publish these private artifacts.

| Check | Result |
| --- | --- |
| `/usr/bin/python3 -m pytest -q scripts/migration/tests/test_state_session_smoke.py` | Pass: all four existing focused tests. |
| Exact launcher/driver command above | Pass: three test bodies plus teardown, official success, exit 0, owned cleanup empty. |
| Missing allocation/private scratch preflight | Pass: both refused before launch, exit 2. |
| `/usr/bin/python3 "$EVIDENCE/verify-evidence.py" "$EVIDENCE"` | Pass: terminal receipts, complete driver logs, source/build/library/backend/input identities, generated aggregate, and scoped note links/anchors/hash/limit readback. |
| Bundled `docs.py stale .` and `docs.py check .` | Exit 0; no `docs/roles.json` manifest. Scoped readback supplies this note's link coverage. |
| `autowork tasks validate --worktree .` | Pass; no task records changed. |
| Preserved execution-input diff and `git diff --check` | Pass; only this note changes. |

## Limits and continuation

Large wrong/stale identity/revision operands `9007199254740993` and `u64::MAX`
were rejected inputs, **not successful high-u64 snapshot outputs**. Successful
identity/revision outputs above `2^53` remain unreachable through this fixture's
low identity counter and zero-based revisions; that installed proof is pending.
The synchronous Dart API does not establish a concurrent race. Rust contention
and private codec tests remain separate [Rust-test evidence](RUST-M2-BRIDGE.md#test-and-codec-evidence-limits).

This completes the Linux transport slice only, not full M2/M3 or RUST-ENGINE-001.
The full session frontier, 68-event replay, Number Walls certification/grids,
effects transport, trajectories, randomization, ingress, gestures, timers and
whole-session ownership remain in the [remaining proof map](RUST-PLAN-04.md#remaining-proof-and-continuation).
Waydroid execution belongs to RUST-005-c9f7f34a; physical hardware, performance,
rendering, browser/WASM and production qualification remain separate and unrun.
No production state/render switch occurred; `RUST_CORE` remains default-off.

Scoped Docs Sync **Maintain** added only this designated result note. It reused
the fixture, launcher, official driver/cleanup and M1 observer, with no code,
assertion, input, schema, dependency, manifest, lockfile, SDK or policy edits.
The [planned boundary](../engineering/spec.md#planned-rust-engine-boundary),
[opt-in probe](../engineering/spec.md#opt-in-native-engine-probe) and
[owned Linux runtime](../engineering/runbook.md#owned-linux-runtime-with-reserved-ports)
remain unchanged. The coordinator owns integration, task reconciliation,
changelog integration and the closeout Docs Sync pass. The runner owns the
merged-tree/full-main gate; it was not run by this worker.
