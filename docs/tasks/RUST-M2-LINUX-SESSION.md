# RUST-M2-LINUX-SESSION — Official Linux whole-session transport

## Current result and boundary

Run `653b8192` executed the official Linux driver against source revision
`34fe1f1bc72363a5261ca818c8fe5e08f0b580c5`: **one test body plus teardown (`+2`)**.
`session/driver/run.json` reports `exit_code=0`, `protocol_success=true`, and
`cleanup.remaining_pids=[]`. `session/driver/protocol-success.json` contains
`{"allTestsPassed":true}`. The complete driver log names the whole-session test
and ends with `All tests passed.`; the backend observer also exited zero.
The result-note commit changes documentation only, not those execution sources.

Authority: [official Linux Session execution](RUST-PLAN-11.md#official-linux-session-execution),
[verification/recovery](RUST-PLAN-11.md#common-verification-and-recovery),
[fixture contract](RUST-M2-SESSION-FIXTURE.md), and the
[existing collection method](RUST-M2-LINUX-TRAJECTORY-U64.md#input-source-artifact-and-backend-binding).
This is diagnostic native transport evidence, not production viewer qualification.
Rust reports `rendering=false`; product routing remains default-off.

## Retained history, failure and repair

The retained result at `a62fe76e70f295b40c27d78201321c6fff86f3d2` recorded a pass
at candidate `0230535f2ac7412415a783e9e0a882982202da59`. That historical pass does
not qualify new source or guarantee the cancellation interleaving. Its original
private evidence remains untouched under the Git common directory:
`autowork-execution/slot-data/RUST-M2-LINUX-SESSION/attempt-1/native-evidence-current`.

A subsequent execution at `307079cc8f8714551c3685e6dce95da966256824` failed at
Thomas selection (fixture line 230): expected `SessionAdmission.accepted`, got
`SessionAdmission.rejected`, error `StaleRevision`. Its official receipt reports
exit 1, protocol false, and empty owned cleanup. The retained candidate in
`.worktrees/push-qualified-20261114` and original logs in
`/tmp/fractal-partial-session-307079cc-NgmyCv/native-integration-ormhpf45` were
read first and preserved. Copies of `driver.log` and `run.json` are also retained
in this run's `retained-307079cc/`. The exact native interleaving was not measured;
begin-before-cancel is source-supported, not an observed numeric revision trace.

The current fixture reuses both earlier assertion-preserving repairs:

1. `_terminal` releases finished/cancelled tickets with `adapter.cancelWork()`;
   completed executor entries cannot be replacement tickets (`Stale ticket`).
2. Thomas selection uses `resetView: false`, retaining its typed default camera;
   legacy reset cleared that camera (`UnsupportedTrajectory`).

It additionally preserves `cancelWork()` and the rejected poll assertion, then
requires an **accepted explicit `adapter.refresh()` before selecting Thomas**.
No original assertion, teardown, 30-second terminal deadline or 5-second poll
timeout was removed, skipped or widened. No launcher, adapter runtime, Rust,
generated bridge, oracle, provenance, dependency or lockfile was changed.

### Recovered state machine

- Dart [schedule/poll/cancel/refresh](../../lib/core/services/engine/rust_state_session_adapter.dart)
  keeps a detached last-good checkpoint. Scheduling need not publish the worker's
  snapshot; cancellation invalidates the poll generation and releases the ticket.
- [Executor `TicketData::step` / `cancel`](../../rust/crates/fractal-bridge/src/state_work_executor.rs)
  takes the Session mutex for worker turns; cancellation removes its entry and
  synchronously revokes its guard. A turn may already have committed state.
- [Wall begin/advance/cancel](../../rust/crates/fractal-core/src/session_number_wall.rs)
  are real revision writers: begin publishes the pending candidate at r+1;
  terminal publication or native cancellation can advance revision again.
  `check_owner` requires exact revision equality and returns `StaleRevision`.
  Revoking a ticket is **not revision rollback**.
- [StateSession snapshot transport and ticket cancellation](../../rust/crates/fractal-bridge/src/api.rs)
  serialize the authoritative refresh under the same Session mutex. Refresh
  reconciles the read; it alone does not promise hidden pending work or every
  independent writer has drained. No production automatic refresh/retry is added.

The test-local `CancellationBackend` regression covers both begin-before-cancel
(r advances before any poll) and cancel-before-begin (r unchanged). It proves
rejected polling retains the identical last-good checkpoint; a deliberate stale
mutation returns `StaleRevision` without admission or publication; explicit refresh
reads the authoritative revision; the next intended Thomas mutation sends that
revision and is admitted exactly once. Ticket/backend disposal remains once-only.
The no-refresh negative run failed as expected (exit 1); the reconciled sequence
passes. Existing wrong-session/older-revision/generation, delayed cancelled poll,
Busy and disposal regressions remain intact. Existing
[native Session guards](../../rust/crates/fractal-bridge/tests/state_session.rs) and
[executor ownership tests](../../rust/crates/fractal-bridge/tests/state_work_executor.rs)
remain unchanged and run in the full gate.

## User journey, tools and commands

The maintainer runs the existing `--session` launcher and official Linux wrapper
below. Success is the whole body, terminal protocol and empty owned cleanup, not
merely a compiled binary. The retained failure exposes `StaleRevision`; repair is
explicit reconciliation before the next mutation, not guessed increments, sleeps
as barriers, silent retry or bypassing the stale guard.

Pinned existing caches supplied Flutter `3.47.9` / Dart `3.13.7`, matching
`fdroid/flutter.version`, Rust/Cargo `1.95.0`, FRB `2.13.0` and cargo-expand
`1.0.127`. `/usr/bin/python3` is `3.12.3`, pytest `9.0.2`, Jinja2 `3.1.6`;
imports and callable `markupsafe.soft_str` passed. The existing external `ld.lld`
resolves to `/usr/bin/x86_64-linux-gnu-ld.bfd`; no tooling was installed/modified.
Offline lock-enforced Pub resolution regenerated checkout-local metadata.

`TMPDIR=/tmp/fractal-session-653b8192` is private mode `0700`.
`AUTOWORK_PORT_BASE=29000` (`29000..29099`) was selected by simultaneously binding
all 100 free loopback ports, then releasing them for the official wrapper's own
availability check. The receipt sampled only `127.0.0.1:29000`.

Commands below used that pinned environment and finite outer timeouts; exact arrays,
full output and real exits are retained. Compile success is not device execution.

```sh
flutter test --no-pub test/migration/rust_state_session_adapter_test.dart test/migration/rust_engine_adapter_test.dart
/usr/bin/python3 -m pytest -q scripts/migration/tests/test_state_session_smoke.py
flutter analyze --no-pub integration_test/migration/rust_state_whole_session_smoke_test.dart lib/core/services/engine
/usr/bin/python3 scripts/migration/run_state_session_smoke.py --session -- flutter build linux --debug --no-pub --dart-define=RUST_CORE=true -t integration_test/migration/rust_state_whole_session_smoke_test.dart
RUSTC="$AUTOWORK_CACHE/rustup-1.95.0/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin/rustc" /usr/bin/python3 scripts/migration/run_state_session_smoke.py --session -- flutter build apk --debug --no-pub --target-platform android-x64 --dart-define=RUST_CORE=true -t integration_test/migration/rust_state_whole_session_smoke_test.dart
flutter build web --debug --no-pub --dart-define=RUST_CORE=false
flutter build web --debug --no-pub --dart-define=RUST_CORE=true
/usr/bin/python3 scripts/migration/run_state_session_smoke.py --session -- timeout --kill-after=10s 660 bash scripts/run-native-integration.sh integration_test/migration/rust_state_whole_session_smoke_test.dart --timeout 600 --dart-define=RUST_CORE=true
```

| Check | Current result |
| --- | --- |
| Pinned/import preflight and `flutter pub get --offline --enforce-lockfile` | Exit 0; locks unchanged. |
| Focused adapter/engine tests | Exit 0; 12 tests (9 Session + 3 engine). |
| Launcher pytest | Exit 0; 14 cases. |
| Target/engine analysis | Exit 0; no issues. |
| Linux and Android-x64 fixture builds | Both exit 0; compilation only. |
| Both Web flag builds | Both exit 0; JavaScript compilation only. Existing FRB Wasm dry-run warning retained. |
| Official Linux command and observer | Both exit 0; one body plus teardown, protocol true, empty owned cleanup. |
| Exact root AGENTS full offline gate, no skip flags | Exit 0, verdict `passed`, all eight stages exit 0; locks unchanged. Flutter: 3515 passed, 9 existing skips; Python: 644 passed, 1 existing skip, 204 subtests; Bats: 34 passed. No skips added. |
| Private evidence/source-binding readback, locks and `git diff --check` | Exit 0; complete source/input/artifact/backend/protocol binding, inventory negative checks and note links/readback pass. |

The first full-gate invocation was externally interrupted with SIGTERM (tool exit
143) after about 600 seconds, despite a requested 3600-second command deadline.
It had passed Cargo fmt/clippy/test and analysis; Flutter tests reached +1572 ~2
before interruption, without an assertion failure or gate summary. It is **not a
passing gate**. Its complete stage logs remain in `offline-gate-interrupted/`.
The final invocation changes supervision to detached `setsid` with an explicit
3600-second timeout and terminal exit file, avoiding the tool-call lifetime limit.
That invocation completed: `offline-gate/offline-gate.json` reports `passed`,
`failed_stage=null`, both locks unchanged, and exit 0 for Pub, Cargo fmt/clippy/test,
Flutter analyze/test, Python and Bats. The unchanged exact Full check from
[root AGENTS.md](../../AGENTS.md) is retained in `.orbi/run-offline-gate.sh`;
`.orbi/offline-gate-r2.log` and `.orbi/offline-gate.exit` retain output and real exit.

## Input, source, artifact and backend binding

The reused private collector/observer/source-binding procedure retains complete
pre/post inventories: **526 execution-source files** (including the new adapter
regression) and **1566 build files**, observed rather than hard-coded counts.
Current bytes match execution HEAD. Freshly resolved local `main` and `origin/main`
were the frozen base `059cc9783fe26bd65266c0f8c5cb3b3a244a607a`; complete path/hash
comparison differs only by the explicitly recorded fixture/regression overlay.
No base was fetched, repinned or modified; future merged sources need Runner checks.
Added, removed and changed source inventory entries are rejected by negative checks.

At final readback, shared `origin/main` had advanced to
`0b497312e336d85114495b69d1e94784fe39bf1f`, including an unrelated execution-source
change in `lib/features/presets/preset_sheet.dart`. The complete fresh upstream
inventory and explicit `NOT_QUALIFIED` drift are retained in
`final-source-binding.json`; they are not overlaid or repinned as passing source.
This task's candidate still matches every tested execution-source byte. The
Runner owns absorbing that base advance and fresh merged-source checks. Neither
this native pass nor the offline gate qualifies that incoming revision.

All four original envelope hashes remain fixed. Projected bytes match the launcher
and actual decoded/decompressed CMake defines. Launcher aggregate: **14224/32768**
bytes; actual driver-added aggregate: **14649/32768** bytes. The executable, kernel,
SO, CMake cache/Ninja configuration, original/projected inputs and tool identities
are retained and hashed. The mapped library matches the bundle and native build:
`e201e0fa52fdeee74e819c5facfcc1b9f98e7eec17703bf412c4db672458378a`.

The observer binds app PID/process group and protocol path to the official receipt.
App maps and same-display GLX identify Mesa `25.2.8`,
`llvmpipe (LLVM 20.1.2, 256 bits)`, `Accelerated: no`. Cursor-theme and OpenGL
frame-size warnings are preserved; they did not fail the assertions or protocol.
This is software display/loaded-library evidence, not painted pixels, hardware GPU,
Flutter renderer ownership or performance qualification.

Private evidence root (full logs include local VM-service details):

```text
/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.worktrees/orbi-TrebuchetDynamics-flutter-fractal-forge-issue-1-653b8192/.orbi/evidence
```

`session/` contains complete `driver/` receipts/logs/protocol outputs, invocation,
terminal result, source bindings, identity/input/artifact inventories and backend
maps/GLX/SO hashes. Adjacent `.orbi/` logs retain TDD red/green, preflight, selected
checks, builds, port allocation and full gate output. Collection/readback helpers
are task-private adaptations; no legacy runner/task-store mutation occurred.
`offline-gate/` retains the final complete stage logs and machine summary;
Adjacent `.orbi/verification.log`, `.orbi/source-binding-self-check.log` and
`evidence.sha256` retain readback/integrity evidence. No unchanged successful full gate was rerun.

## Remaining qualification

All original whole-session assertions execute, including physical wheel/drag/pump,
independent parameter/morph tokens and 36 morph ticks, typed load/effects/immutable
reads, scheduled prime/composite wall and trajectory results/cancellation, retained
frames/closed reads and exact high-u64 getters after source close. This does not
admit all modules, enable Rust product routing, establish lossless rollback, or
qualify production rendering, Waydroid, browser/WASM, hardware GPU or timing.
No device operations or publication occurred. The Runner owns PR creation,
post-PR independent review, merged-tree checks and integration.
