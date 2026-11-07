# RUST-M2-LINUX-EXTENDED — Linux effects and Future transport

## Result and boundary

Both seven-module targets executed through the official Linux `integrationDriver`
at source revision `df3c2fcffd5fd823d3184ba748496030c7ed3730`.
The extended target completed four test bodies plus teardown (`+5`).
The Future target completed two test bodies plus teardown (`+3`).
No assertion was changed, skipped or replaced by a build-only result.
This commit adds only this result note. The tested execution sources remain unchanged.

For **each** target, the retained `driver/run.json` contains:

```json
{"exit_code":0,"protocol_success":true,"cleanup":{"remaining_pids":[]}}
```

Each `driver/protocol-success.json` contains `{"allTestsPassed":true}`.
The full driver logs name every test and end with `All tests passed.`
These are actual native FRB calls, not raw `flutter test -d linux`, probe-only,
compiled-only or supplemental launches.

Sources: [accepted migration](../planning/refactor-plan.md#flutter-shell-and-rust-engine-migration),
[installed qualification contract](RUST-PLAN-07.md#installed-native-qualification),
[extended producer](RUST-M2-EXTENDED-FIXTURE.md),
[Future producer](RUST-M2-ASYNC-STEP.md) and
[prior Linux driver contract](RUST-M2-LINUX-STATE.md).
The producer notes describe their historical compile-only checks, not these later executions.

## Executed assertions

The unchanged [extended target](../../integration_test/migration/rust_state_extended_smoke_test.dart)
executed all four cases:

- `extended source protocol refuses missing/truncated/tampered inputs`: all four
  pinned envelopes decode. Missing, truncated and tampered data fail. The disabled
  adapter does not load native code.
- `eleven native effects restore forced policy and roll back atomically`: all
  eleven effect constructors/getters match the Dart controller. Forced-module
  transitions restore user effects. Rejected batches preserve hidden restore
  state, module, params, view and revision. Isolation, retained snapshots and
  duplicate shutdown/post-close rejection pass.
- `staged native frames match the Dart oracle and retain certified state on rejection`:
  all six sequences pass canonical settings, support, dimensions and every exact
  grid-cell comparison. Admission, zero/one/bounded work and terminal revisions
  pass. Invalid, composite and budget-zero unverified candidates preserve certified state.
- `borrowed native requests enforce ownership, navigation and closed lifecycle`:
  inactive/revoked guards, supersession, stale/wrong/foreign operations, atomic
  deferred-batch rejection, cancellation, navigation, immediate begin and close
  pass. Detached frames survive navigation/close. The independent session finishes.

The unchanged [Future target](../../integration_test/migration/rust_state_async_smoke_test.dart)
executed both cases:

- `awaited bounded steps match exact Dart frames and retain certified state on rejection`
- `awaited borrowed requests enforce ownership, navigation and closed lifecycle`

These await the actual `snapshotAsync`, `beginNumberWallAsync`,
`advanceNumberWallAsync`, `cancelNumberWallAsync` and `shutdownAsync` methods.
They repeat the full six-sequence exact-grid and rejected-candidate checks through
Future transport, then check borrowed ownership, revocation, stale/foreign requests,
supersession, cancel, navigation, close and retained/independent state.
Returned handles and borrowed handles follow the existing fixtures' explicit cleanup.
Every native case requires `RUST_CORE=true` and asserts `rendering=false`.

## Actual setup and commands

The worker received `AUTOWORK_PORT_BASE=20100` (`20100..20199`) and private
`TMPDIR=/var/tmp/aw-1000-48137133-2`, mode `0700`.
Both sequential runs used the same worker allocation, not a fabricated port.
The following existing caches were selected before checks:

```sh
export FLUTTER_ROOT="$AUTOWORK_CACHE/flutter-3.47.9"
export PUB_CACHE="$AUTOWORK_CACHE/pub-cache"
export RUSTUP_HOME="$AUTOWORK_CACHE/rustup-1.95.0"
export CARGO_HOME="$AUTOWORK_CACHE/cargo-1.95.0"
export PATH="$FLUTTER_ROOT/bin:$RUSTUP_HOME/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin:/usr/bin:$PATH"
export CARGO_NET_OFFLINE=true
flutter pub get --offline --enforce-lockfile
/usr/bin/python3 -m pytest -q scripts/migration/tests/test_state_session_smoke.py
/usr/bin/python3 scripts/migration/run_state_session_smoke.py --extended -- autowork-run timeout --kill-after=10s 660 bash scripts/run-native-integration.sh integration_test/migration/rust_state_extended_smoke_test.dart --timeout 600 --dart-define=RUST_CORE=true
/usr/bin/python3 scripts/migration/run_state_session_smoke.py --extended -- autowork-run timeout --kill-after=10s 660 bash scripts/run-native-integration.sh integration_test/migration/rust_state_async_smoke_test.dart --timeout 600 --dart-define=RUST_CORE=true
```

`AUTOWORK_CACHE` was the absolute Git common directory's `autowork-execution/cache`.
No SDK, dependency, profile, build rule or lockfile was changed.

- Flutter `3.47.9` matches `fdroid/flutter.version`. Dart is `3.13.7`, framework
  `c197ca5199e9ee5661e865596c9c07294dfab51c`, engine
  `89c39edfdfae2949f6806e4a315c0c08522238b7`. The SDK resolves to `/home/xel/flutter`.
- Rust `1.95.0` (`59807616e1fa2540724bfbac14d7976d7e4a3860`), Cargo `1.95.0`
  and Rust/Dart/codegen FRB `2.11.1` were verified. The existing `ld.lld` shim
  resolves to the host BFD linker. No tool was installed.
- `/usr/bin/python3` is `3.12.3`. pytest `9.0.2`, Jinja2 `3.1.6` and callable
  `markupsafe.soft_str` imports passed. Offline Pub resolution preserved locks.
- The official wrapper used `flutter drive -d linux --debug --no-pub --no-dds
  --no-devtools --no-publish-port --no-keep-app-running`, both VM ports `20100`,
  the existing driver adapter and `INTEGRATION_TEST_SHOULD_REPORT_RESULTS_TO_NATIVE=false`.
  Each exact command array, including input defines, is retained in `driver/run.json`.
- Each owned Xvfb used `1280x800x24` and `-nolisten tcp`. The only sampled owned
  TCP listener was `127.0.0.1:20100`. Cleanup left no owned PIDs.
  Separate missing-allocation and missing-`TMPDIR` invocations refused before launch, exit `2`.

## Input, source and build identities

The launcher verified all original envelope hashes, then projected seven complete
module records without changing field content, source order or numeric spelling.
The [producer input table](RUST-M2-EXTENDED-FIXTURE.md#inputs-and-identities)
contains the unchanged original hashes. Each run privately retains original and
projected bytes plus hashes in `inputs/` and `identity.json`.

| Envelope | Projected SHA-256 | Bytes |
| --- | --- | ---: |
| modules | `afc6f18acd52dfdf6d11029c5d46a889f4e07393a5a9fa521a9c7e4f719a3c0f` | 3575 |
| parameters | `46ab96397b86b330462671b2f1374257dba15bf25ec81e65630cc960c689923d` | 24679 |
| presets | `d7bb5a2651467e00414c1dbad5fb107ac666b3962e5331be9280df88e739dc87` | 12092 |
| capabilities | `f29b25e6dd11ba3e53f1aea551488d263c3f3a98973fe0bf33be2180c796959c` | 13341 |

Both launcher aggregates measured **12288/32768 bytes**, including `RUST_CORE=true`.
Both actual generated CMake aggregates measured **12713/32768 bytes**, including
internal Flutter/driver flags. Readback decoded all projected bytes exactly.
The inclusive aggregate guard, source provenance and override guards remain intact.
Whole original-envelope byte transport and full-catalog parity are not claimed.

| Execution source | SHA-256 |
| --- | --- |
| Extended target | `073bb9ea74626e65647dab25a4cf301d9d6f81b2115b715bf45467c9fbdd77bc` |
| Future target | `bfecda61999fd34108402537b0122b199a87b6c8a4e2641868be4e40cef69a24` |
| Projection launcher | `459e5cb13db5b00aace7e4e69214b158432dac6d624c39dce4be034f92cd7154` |
| Official driver adapter | `51382a5b3b178c6454a9d04eeb0cbb3d207b3c43117ecfd6e38a6ef058029343` |
| Owned runtime wrapper | `5d0963a8f0e05f1d340bc62d45fdf09384f15f1a28149312a1bb533a68dc070c` |

| Built artifact | SHA-256 |
| --- | --- |
| Both bundled `lib/libfractal_bridge.so` | `94544b6ff11306872f21e33916a5d468a0a81b9876b3111b5e04762d939ef16e` |
| Both bundle executables `flutter_fractals` | `40d46d008483232d2cb7f12dbf910b6bed9ab8e49bea980babce433affcb9108` |
| Extended `data/flutter_assets/kernel_blob.bin` | `a6c4e910479424ff7434d5441b1a7d88fc3e60c2344a0c78b851ce4b62414b6e` |
| Future `data/flutter_assets/kernel_blob.bin` | `16104d5d18321c02fa43df36628c16dc55d4012f33d33a8a2a0a84c21aa76550` |
| Both bundled `lib/libflutter_linux_gtk.so` | `03e4773db4b0099718fea41520685a195684b5158bc074b6c837178783bb35f9` |

Each app's captured `/proc` maps identify its loaded bundled Rust SO. Its hash
matches that run's CMake Rust build output. The observer binds the app process
group and protocol-result path to the corresponding official receipt.
Both actual app displays were `:99`. Same-display `glxinfo -B` returned exit `0`:
Mesa `25.2.8`, `llvmpipe (LLVM 20.1.2, 256 bits)`, `Accelerated: no`.
Loaded-library inventories retain Mesa EGL/GLES, Gallium and LLVM identities.
This observes software display capabilities and app libraries, not Flutter frame
output, a specific Flutter renderer selection or physical GPU qualification.

## Durable private evidence and verification

Persistent evidence root, outside disposable scratch and this checkout:

```text
/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/slot-data/RUST-M2-LINUX-EXTENDED/attempt-1/native-evidence
```

- `extended/driver/` preserves the full `native-integration-_en5vmnd` evidence.
  `async/driver/` preserves the full `native-integration-5n26o_c0` evidence.
  Each includes `run.json`, `protocol-success.json`, complete `driver.log` and `outputs/`.
- Each target's `identity.json` inventories 482 execution-source files and 1538
  build files. `inputs/` retains all original/projected envelopes. `artifacts/`
  retains its executable, kernel, Rust SO, CMake cache and Ninja instructions.
  `generated_config.cmake` preserves that target's actual encoded defines.
  The first target's evidence was captured before the second build.
- Each `backend/` retains app maps, loaded-library hashes, same-display GLX output
  and owned process/protocol identities. `launch.log`, `observer.log`,
  `invocation.json` and `terminal.json` retain launch/observer outcomes.
- Root `toolchains.log`, `tool-identities.json`, `pub-get.log`, `launcher-tests.log`,
  `refusals.json` and refusal logs retain setup and fail-closed results.
  `run-target.py` retains the exact collection procedure.
  The prior Linux observer was reused with only private output-path and deadline
  adaptations in `observe-native-backend.py`.
- `verify-evidence.py`, `verification.log` and `evidence.sha256` retain the final
  readback procedure, output and integrity inventory. These artifacts are private.
  Driver logs include local VM-service connection details and must not be published.

| Check | Final result |
| --- | --- |
| Pinned tools/imports and `flutter pub get --offline --enforce-lockfile` | Pass; existing tools/caches, unchanged locks. |
| `/usr/bin/python3 -m pytest -q scripts/migration/tests/test_state_session_smoke.py` | Pass: 8 cases across both input modes. |
| Exact extended official-driver command above | Pass: four bodies plus teardown, official success, exit 0, empty owned cleanup. |
| Exact Future official-driver command above | Pass: two bodies plus teardown, official success, exit 0, empty owned cleanup. |
| Missing allocation/private scratch preflight | Pass: each refused before launch, exit 2. |
| `/usr/bin/python3 "$EVIDENCE/verify-evidence.py" "$EVIDENCE"` | Pass: both terminal/protocol/log inventories, source/input/build/SO/backend identities, actual generated defines and this note's links/anchors/hash claims. |
| Bundled `docs.py stale .` and `docs.py check .` | Exit 0; no `docs/roles.json`. These do not establish repository-wide coverage. Scoped readback covers this note. |
| `autowork tasks validate --worktree .` | Pass; no task records changed. |
| Execution-source/lock preservation and `git diff --check` | Pass; only this note changes. |

## Limits and continuation

This establishes Linux effects/full-grid and awaited lifecycle transport only.
It does not complete full-session/full-M2 or RUST-ENGINE-001 acceptance.
Large identity/revision operands remain rejected inputs, not successful high-u64
outputs. Awaited bounded steps and deterministic interleavings do not measure
scheduler fairness, responsiveness or concurrent races.
Rust rendering remains disabled and `RUST_CORE` remains default-off in the product.
No app/render switch, SDK change, device operation or publication occurred.

**RUST-M2-WAYDROID-EXTENDED** owns the independent Android execution of both targets.
Successful high-u64 output, complete scheduling/session ownership, browser/WASM,
physical GPU and performance qualification remain separate and unrun here.

Scoped Docs Sync **Maintain** adds only this designated result/test-evidence note.
It reuses the fixtures, launcher, official driver/owned cleanup and existing observer.
No new abstraction, dependency, copied catalog, assertion change or extra test was needed.
The specification's [opt-in boundary](../engineering/spec.md#opt-in-native-engine-probe)
and the [owned Linux runbook](../engineering/runbook.md#owned-linux-runtime-with-reserved-ports)
remain unchanged. The coordinator owns integration, shared task/plan/history
reconciliation, changelog integration and the final Docs Sync closeout.
The runner owns the merged-tree/full-main gate, which this worker did not run.
