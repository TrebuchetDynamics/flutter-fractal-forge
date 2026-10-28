# Web/Linux test-port recovery — 2026-10-28 UTC

The missing test-port allocation was recovered and both runtime lanes executed.
This is **not** complete runtime qualification or release approval.

## Continuation: Web failures fixed and verified

Final Web execution is bound to base `b58ba1bd550fb4198e1489a97168baf6d8cb848b`
plus dirty-source digest
`efd4db5f4f65c8eee261db97187c917d58c9f3c17e987c23b9b54622a9b23ab1`.
The frozen identity matched before/after the run. The actual fresh lease was
`20200..20299`, released after owned cleanup; it was not borrowed from the
independent release worker. The candidate labels remain `1.1.112+112`, not a
published version.

- `test/playwright/web-image-creation-journey.spec.mjs:104` now selects the
  **enabled** textbox rather than its empty-value hint. Flutter retains the query
  after viewer navigation and removes that hint-based accessible name; a second,
  disabled semantics input must not be selected. Existing focus, input activation,
  query, navigation, formula, saved-state and PNG assertions remain intact.
- `scripts/run-release-command.py:snapshot/main` now records exit-time descendant
  state and distinguishes fully exited zombies from live leaks. A `Z` leader is
  exempt only when its task directory is nonempty and **every** task is also `Z`;
  incomplete reads fail closed. Cleanup still reaps them. Nonzero command exits,
  timeouts and live descendants still fail. No assertion/cleanup waiver was added.
- `test/scripts/test_release_process_cleanup.py` exercises successful and nonzero
  commands leaving zombies, plus a zombie leader with a live worker thread.
  Both bugs were observed with failing regressions before correction. Independent
  review caught the live-thread edge case; the corrected implementation received
  a no-blockers review and additional classification/error-handling checks.

| Final check | Actual result |
|---|---|
| Fresh Web build, served bundle identity/hash and asset inventory | Passed |
| Chromium image-creation journey | 4 executed, passed; supervised exit 0 |
| Chromium saved-session journey | 1 executed, passed; supervised exit 0 |
| Owned Web command cleanup | Both `remaining_pids=[]`; only fully exited zombies at command exit |
| Focused safety/regression families | 39 tests and 58 subtests passed |
| Full offline gate on final helper/test bytes | Exit 0: analyzer clean; Flutter 3,096 passed / 8 skipped; Python 385 passed / 1 skipped / 133 subtests passed; Bats 25 passed |
| Lockfile | SHA-256 unchanged from the initial execution below |

Final evidence: `attempt-m275x3ub/qualification.json`, its `stage-logs/`,
`web-browser_journey-bvs3gls9/`, `web-saved_data-c4ffyh4k/` and
`full-offline-gate-thread-safe.log`, all beneath the local evidence root below.
The earlier `attempt-twvdj25b` retains diagnostic proof of `command_exit: 0` with
only zombie descendants and a false supervisor exit 1; intermediate failed
locator attempts and pre-hardening passes remain history, not final evidence.

Verified SHA-256 inputs:

- `scripts/run-release-command.py`: `1895810cee67340daf169f2faf7d7401eedbe7217d03eb4dc7d50462173ec09b`
- `test/scripts/test_release_process_cleanup.py`: `e17ccedcf9d12cd244c65265f5d3fa639a47c9ddcb09c53564cac45e18630f30`
- `test/playwright/web-image-creation-journey.spec.mjs`: `43c38aabb986661f54d07f8c2e88461f21f78c566e15222c53dce9d57ca36125`

Linux evidence below remains bound to its original source. No new retained Linux
edited-PNG/EN/ES/inspired-entry/human review evidence was produced in this
continuation. Unrelated pre-release-gate changes belong to another worker and
were neither edited nor adopted by this task. No commit or publication is claimed.

## Initial source and allocation

- Source: `41a3e0ab003c4d78ea03d219b88214112d211c6c`.
- Candidate labels: `1.1.112+112`; no publication attempted.
- Flutter 3.44.6 / Dart 3.12.2; offline lockfile-enforced package preflight exited 0.
- `pubspec.lock` SHA-256: `22b29dbd8f71276012a54b9bdc62ba88408f967a86b34075986c17e1c4506ec3`.
- The existing Autowork `parallel_dispatch.port_lease(1)` allocator supplied
  `20100..20199`. Its locked descriptor remained open across both lanes and was
  closed in `finally`. No guessed allocation, old worker allocation, SDK change,
  port-policy waiver or runner restart was used.
- A fresh private scratch directory was passed as `TMPDIR`/`TMP`/`TEMP`. Existing
  `scripts/release_platform_lanes.py:_produce_lane` ran only `web` and `linux`,
  rebuilding artifacts and executing the existing qualification adapters.
- Frozen identity matched before/after execution, including the pre-existing
  untracked task file; that unrelated file was not modified.

## Initial executed results (historical)

| Check | Actual result |
|---|---|
| Fresh web build and artifact inventory/hash validation | Passed |
| Chromium image-creation journey | 3 passed, 1 failed; command exit 1 |
| Chromium saved-session test | 1 test passed, but supervised command exit 1; **failed gate** |
| Fresh Linux release build and artifact verification | Passed |
| Linux full-flow integration driver | Exit 0, official `protocol_success: true`, owned `remaining_pids: []` |
| Complete Linux native/export qualification | Unknown: required retained edited-view comparisons, EN/ES/inspired-entry coverage and attributable human review remain unverified |

The native receipt recorded only `127.0.0.1:20100`. The web adapter verified its
owned served release identity and `main.dart.js` hash before running Chromium.
Both web command supervisors recorded `remaining_pids=[]`; their nonzero exits
are retained, not converted into successful results. Existing unrelated listeners
elsewhere in the allocated block were not reused or terminated.

### Initial Web failures (resolved by the continuation above)

1. `test/playwright/web-image-creation-journey.spec.mjs:108` cannot find textbox
   `Name, formula or family` while opening the second (3D) example. The retained
   semantics snapshot instead contains disabled `Search by name, formula or
   family` and an unnamed textbox. This is diagnostic evidence, not proof of a
   product-versus-fixture root cause. Sine sphere, Fibonacci and Gaussian cases
   passed; the required 2D/3D case did not.
2. `production-saved-session.spec.mjs` reports one passed test with no Playwright
   errors, but `scripts/run-release-command.py` exits 1. Its `finally` block
   deliberately rejects a zero-exit child when owned descendants remain at child
   exit, even if subsequent cleanup succeeds. The retained log does not identify
   those descendants; instrument ownership/timing before changing that guard.

## Retained evidence and next step

Local evidence is under `$HOME/.cache/tmp/web-linux-qualification/`:

- `run.py`, `run.log`, `preflight.log`: one-off allocation/execution harness and logs.
- `attempt-hvilektf/qualification.json`: source, allocation, artifact hashes,
  stage logs, protocol receipt, source-identity comparison and lease release.
- `attempt-hvilektf/stage-logs/`: build, artifact and runtime receipts.
- `attempt-hvilektf/web-browser_journey-fgr3ncmk/`: JSON/HTML reports, failure
  screenshot, semantics snapshot and trace.
- `attempt-hvilektf/web-saved_data-2ua0behv/`: saved-session report and command logs.

Do not overwrite older campaign receipts or repin this evidence to later source.
The two Web failures are resolved on the final hash-bound bytes above. Retain
Linux edited PNG/state comparisons before seeking remaining human/platform
qualification. No hardware-GPU, physical-device, human acceptance, publication or
deployment pass is claimed. Earlier campaign identities are not updated by these
new local results.

Update this report when the linked runtime fixtures, release qualification
adapters or allocation policy changes. See the [reserved-port runbook](../engineering/runbook.md#owned-linux-runtime-with-reserved-ports).
