# RUST-M2-LINUX-TRAJECTORY-U64 — Installed Linux trajectory and exact u64

## Result and boundary

Both existing targets executed through the official Linux `integrationDriver`
at execution revision `d113ac4e65fb8a7be8aa1f37c9bbb24e72c37d0f`.
Each target completed one test body plus teardown (`+2`). For **each** target:

- `driver/run.json`: `exit_code=0`, `protocol_success=true`,
  `cleanup.remaining_pids=[]`.
- `driver/protocol-success.json`: `{"allTestsPassed":true}`.
- The complete `driver/driver.log` names the test and ends with `All tests passed.`
- The observer exited zero after capturing the owned app with its Rust SO loaded.

Only this note changes. No assertion, skip, fixture, launcher, generated source,
build rule, dependency or lockfile was changed. These are actual native assertions,
not raw `flutter test -d linux`, supplemental launches or build-only substitutes.
This retry reuses the collection method but executes both targets anew with the
integrated physical-time sources. Attempt 2 retains its own artifacts and receipts;
no old binary or receipt was repinned. See the [incident repair](RUST-M2-LINUX-TRAJECTORY-U64-repair.md).

Authority: [accepted migration](../planning/refactor-plan.md#flutter-shell-and-rust-engine-migration),
[installed trajectory/u64 contract](RUST-PLAN-09.md#installed-trajectory-and-high-u64-execution)
and the [previous official-driver collection procedure](RUST-M2-LINUX-EXTENDED.md).
The [default-off boundary](../engineering/spec.md#opt-in-native-engine-probe),
[ADR 0005](../adr/0005-rust-owns-all-mathematical-domain-logic.md) and
[ADR 0006](../adr/0006-native-demonstration-performance-is-target-specific.md)
remain unchanged.

## Assertions executed

The unchanged [trajectory target](../../integration_test/migration/rust_state_trajectory_smoke_test.dart)
ran `typed bounded trajectory requests and retained native frames`:

- Thomas, Four Wing and Lorenz 2D typed defaults/settings match Dart. Progress
  reaches 256 and 512 steps, then success. Retained points and projected bounds
  match the Dart trajectory model within `1e-10`.
- Detached point lists, retained snapshots/frames, cross-session cache hits,
  inactive/revoked guards, stale/foreign requests and supersession pass.
- Cancellation, invalid input rejection, legacy camera edits, shutdown and
  post-close rejection pass. Retained frames/settings remain readable.

The unchanged [u64 target](../../integration_test/migration/rust_state_u64_smoke_test.dart)
ran `fixed high-u64 outputs stay exact after source Session close`:

- Actual generated `BigInt` getters return the successful fixed pairs
  `(9007199254740993,18446744073709551614)` and
  `(18446744073709551614,18446744073709551615)` exactly.
- Both detached fixtures preserve tested non-counter payload getters after
  source Session shutdown. Original and initial snapshots retain their
  identities, payload and revisions one and zero respectively.

Both bodies require `RUST_CORE=true` and assert `rendering=false`. Existing fixture
teardown owns returned and borrowed handles. No scheduler timing is measured.

## Setup and exact commands

This attempt received `AUTOWORK_PORT_BASE=20300` (`20300..20399`) and private
`TMPDIR=/var/tmp/aw-1000-48137133-1`, mode `0700`. Existing provisioned caches were
selected as specified in `AGENTS.md`: absolute Git-common-directory
`AUTOWORK_CACHE`, Flutter `3.47.9`/Dart `3.13.7`, isolated `PUB_CACHE`, Rust/Cargo
`1.95.0` with pinned `RUSTUP_HOME` and `CARGO_HOME`, and Cargo offline mode.
Flutter matches `fdroid/flutter.version`. Rust/Dart/codegen FRB is `2.13.0`,
cargo-expand is `1.0.127`; no downgrade or installation occurred.
`/usr/bin/python3` is `3.12.3`, pytest `9.0.2`, Jinja2 `3.1.6`; imports and callable
`markupsafe.soft_str` passed. The existing `ld.lld` shim resolves to BFD.

After `flutter pub get --offline --enforce-lockfile`, the collector ran:

```sh
/usr/bin/python3 -m pytest -q scripts/migration/tests/test_state_session_smoke.py
: "${AUTOWORK_PORT_BASE:?real current allocation required}" "${TMPDIR:?private scratch required}"; /usr/bin/python3 scripts/migration/run_state_session_smoke.py --trajectory -- timeout --kill-after=10s 660 bash scripts/run-native-integration.sh integration_test/migration/rust_state_trajectory_smoke_test.dart --timeout 600 --dart-define=RUST_CORE=true
: "${AUTOWORK_PORT_BASE:?real current allocation required}" "${TMPDIR:?private scratch required}"; /usr/bin/python3 scripts/migration/run_state_session_smoke.py --extended -- timeout --kill-after=10s 660 bash scripts/run-native-integration.sh integration_test/migration/rust_state_u64_smoke_test.dart --timeout 600 --dart-define=RUST_CORE=true
```

Each long collection ran under `autowork-run`. Exact subprocess arrays are retained
in `invocation.json`; official Flutter/Xvfb arrays are in `driver/run.json`.
The wrapper used `flutter drive -d linux --debug --no-pub --no-dds --no-devtools
--no-publish-port --no-keep-app-running`, the official driver adapter, both VM ports
`20300`, and native result reporting disabled. Xvfb used `1280x800x24 -nolisten tcp`.
Only the owned loopback listener `127.0.0.1:20300` was sampled; no owned PID remained.

## Input, source, artifact and backend binding

The launcher verified all four original envelope hashes before projecting complete
records: three trajectory modules for `--trajectory`, seven for `--extended`.
Original/projected bytes, hashes, record order and numeric spellings are retained.
No baseline refresh or whole-catalog transport/parity is claimed.

| Target | Launcher encoded bytes | Actual CMake encoded bytes | Limit |
| --- | ---: | ---: | ---: |
| trajectory | 6952 | 7377 | 32768 |
| u64 | 12288 | 12713 | 32768 |

Actual aggregates include Flutter/driver flags. Readback decodes and decompresses
all four actual CMake input defines and compares them byte-for-byte with the
retained projected inputs and current launcher output.

Each target inventories **518 execution-source files** and **1565 build files**.
Source identities include the target, launcher, driver, wrapper, original inputs,
core/bridge/generated sources and locks. Both runs' complete source path sets and
SHA-256 values match committed execution HEAD, checkout bytes, runner integration
ref `refs/heads/pi-autowork/20261027-235818` (from `PI_AUTOWORK_SESSION`) and
`refs/heads/main`. Before and after both runs, these refs resolved to execution
revision `d113ac4e65fb8a7be8aa1f37c9bbb24e72c37d0f`.

The shared source-set digest is
`aea4cbc4d832659a186206e27b3ec9603366ada0e1c8335b2e4349c1eec6f9b7`
(SHA-256 of the sorted-key JSON path/hash map). Inventories include the changed
`physical_events.rs`, `session.rs`, `session_physical_events.rs` and added
`physical_event_time.rs` / `session_physical_time.rs` from the integrated
physical-time work. The private verifier resolves integration refs afresh before
readback/reporting; it does not hard-code an old revision or inventory count.
It rejects both old 516-file inventories and added, removed or changed entries
in private negative-check copies. No old evidence or tracked source was modified.
A documentation-only revision change is allowed only when full source inventories
remain identical. Any later execution-source drift invalidates this binding.
Executable, kernel, Rust SO, CMake cache and Ninja instructions are retained per
run. The loaded Rust SO hash matches both the bundle and CMake Rust build output.
Trajectory artifacts/configuration were captured before the u64 build; readback
verifies their retained bytes after the second build.

Same-display GLX and app maps identify Mesa `25.2.8`,
`llvmpipe (LLVM 20.1.2, 256 bits)`, `Accelerated: no`. Each backend inventory binds
the app process group and protocol path to its official receipt and retains loaded
library hashes. This is software display capability and loaded-library evidence,
not proof of a specific Flutter renderer, painted frames or physical GPU timing.
The trajectory log includes an OpenGL frame-size timeout warning; native assertions
and the official protocol still passed. Rendering is not qualified by these runs.

## Durable private evidence and verification

Evidence root, outside disposable scratch and this checkout:

```text
/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/slot-data/RUST-M2-LINUX-TRAJECTORY-U64/attempt-2/native-evidence-current
```

Each of `trajectory/` and `u64/` contains:

- `driver/`: official `run.json`, `protocol-success.json`, full `driver.log` and
  protocol outputs;
- `source-binding-pre.json`, `source-binding-post.json`, `pre-launch-sources.json`,
  `identity.json`, `inputs/`, `artifacts/`, `generated_config.cmake`;
- `backend/`: app maps, loaded-library hashes and same-display GLX output;
- `invocation.json`, `terminal.json`, complete launch and observer logs.

Each complete `launch.log` records the original runtime evidence directory.
Root `run-target.py` and `observe-native-backend.py` preserve the reused collection
method. `source_binding.py` adds complete committed/current/integration path-set
and hash comparisons, without changing production code or native assertions.
`final-source-binding.json`, `negative-source-binding.json` and
`check-source-binding.py` retain the final source check and regression readback.
`toolchains.log`, `tool-identities.json`, `pub-get.log` and
`launcher-tests.log` preserve setup results. `verify-evidence.py`,
`verification.log` and `evidence.sha256` preserve readback and integrity checks.
Full logs include local VM-service details and must remain private.

| Check | Final result |
| --- | --- |
| Pinned tool/import checks and offline lock-enforced Pub resolution | Pass; unchanged locks. |
| Launcher pytest module | Pass: 12 cases. |
| Exact trajectory official-driver command | Pass: one body plus teardown; exit 0, protocol success, empty owned cleanup. |
| Exact u64 official-driver command | Pass: one body plus teardown; exit 0, protocol success, empty owned cleanup. |
| Private `verify-evidence.py` readback | Pass: full logs, terminal/protocol/cleanup, inputs/actual aggregates, complete source path-set/hash equality against freshly resolved integration refs and execution HEAD, generated/build/loaded-library/backend/tools and note links/anchors; byte-stable note readback. |
| Private `check-source-binding.py` | Pass: both stale inventories rejected; added/removed/changed entries rejected in private copies; fresh source binding passes. |
| Scoped bundled `docs.py stale .` and `docs.py check .` | Pass; no role manifest, not repository-wide coverage. |
| `autowork tasks validate --worktree .` and `git diff --check` | Pass; no task records or execution sources changed. |

Scoped Docs Sync **Maintain** adds only this designated result/test-evidence owner.
Existing targets, projection launcher, official driver, cleanup and private observer
are reused; no production abstraction, dependency or assertion repair was needed.
The private self-check covers the added source-inventory comparison.
Task preparation/pruning was read-only; the coordinator owns task/history updates.

## Limits and continuation

Only these two installed Linux diagnostic targets are qualified. The product flag
remains default-off, Rust rendering remains disabled and Flutter retains app
ownership. Hardware timing, browser/full M2, executor/scheduler fairness and Android
qualification remain separate. **RUST-M2-WAYDROID-TRAJECTORY-U64** owns the independent
Waydroid execution; no device operations occurred here.

The coordinator owns integration, shared plan/task/history reconciliation and final
Docs Sync closeout. The runner owns the merged-tree/full-main gate; this worker did
not run or claim it.
