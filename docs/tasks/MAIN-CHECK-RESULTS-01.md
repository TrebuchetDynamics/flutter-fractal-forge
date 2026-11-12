# MAIN-CHECK-RESULTS-01 — Restore observable full-check results

## Evidence read in place

Checked revision: `52fc51571717604062eb4f9e75c2eb0268107beb`; last green named by metadata: `c026454f2cc3926665b55f68b997f7bb932a8fe4`.
Bundle: `/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/main-evidence/52fc51571717604062eb4f9e75c2eb0268107beb`.
All five files were read in place, not copied: `main_check.json`, `main-check.log`, `main-check.exit`, `main-check-reruns.log`, `flaky_history.json`.

The runner reports two pre-result crashes. Its recorded crash line is:

```text
[offline-gate] summary: /tmp/aw-main-tdak8u69/offline-gate-n1RglI/offline-gate.json
```

There is a material evidence discrepancy: metadata says `broken/INCOMPLETE`, `failures=null`, but the log reports successful pub-get, Cargo fmt/clippy/test and Flutter analysis, followed by Flutter tests exiting 1 at `31:07 +3493 ~9 -1: Some tests failed.` It even supplies a Failing tests footer. This is not evidence that the summary emitter itself crashed. Exit file is 1; reruns log is empty and flaky history is `{}`. Python/Bats are not reached. No isolated rerun, three-revision flakiness or new full-gate pass is evidenced. This task must not repair the test named in that footer or qualify this revision.

## Bounded execution approach

1. Revalidate the root process-local setup against `fdroid/flutter.version`, the existing Rust 1.95.0 cache/toolchain and provisioned Python imports. No crashing tool/version mismatch is established; do not invent a tool upgrade or install one.
2. Inspect `scripts/ci/offline-gate.sh`: `run_stage` captures all output but forwards only the final 40 lines on failure; `finish_and_exit` defaults to a summary pathname. The existing `--json` option emits terminal verdict, failed stage and stage exits. First test whether restating `AGENTS.md`'s Full check invocation to use that supported result output suffices. Preserve all setup and gates.
3. If necessary, make only the gate's reporting preserve observable stage results and full failure diagnostics in the command output, while retaining private stage logs and nonzero exit propagation. Do not modify the external runner, runtime state, protected evidence, tests under diagnosis or product code. Do not create a second gate implementation.
4. Use executable doubles in `test/scripts/offline_gate.bats` to show successful and failed stages remain distinguishable, a failure with diagnostic context outside the final 40 lines remains observable, and the JSON/exit agrees with retained logs. Keep stop-on-failure, timeout/setup failures and both lock guards; do not turn failed stages into success or run skipped families as if they had passed.
5. Run the complete unchanged-family gate on delivered bytes using the restated command. Record actual source/command/exits, stage terminal results and both lock hashes in this note. A genuine stage failure is an observable result, not successful qualification; remaining short-circuited families are NOT_RUN. If the external classifier still rejects an otherwise explicit result, report its exact boundary without editing runner state or claiming acceptance.

## Retained-report correction

See [the check-receipt protocol](maintainer-check-receipts.md). Attempt 2 report for
`20dcd625c0832af973ba5286222ef7e297ace51b` explicitly says the worker did not run
the complete gate. Its focused results and future runner gate do not satisfy the
third acceptance item. The normalized executable Checks retain the complete root
setup, add supported terminal JSON reporting and perform version/import preflight;
no full-gate obligation or failure is waived. Record actual delivered-tree results,
including both lock hashes before/after, not a promised coordinator closeout.

The historical bundle named above is absent on this host during this maintainer
pass; its prior recorded readback is not a new verification. No named-test repair
or goal qualification follows from it.

## Delivered reporting and reuse

Execution base: `0d28414cb825ab51dcaeb62379751f2dc5d2ba8b`, exported as `BASE_REVISION`. Reused only the inspected reporting/test delta from `175fb6e2676419ce237c813d4b2b17c5f19652b5`; its historical full-gate receipt does not qualify this composition. Root Full check selects the existing `--json` interface. Failed stages now print the entire captured log instead of the final 40 lines, because JSON alone cannot expose early diagnostic context. Successful stages, private logs, summary schema, stage commands, setup refusal, timeouts, stop-on-failure and both lock guards are unchanged. No dependency, second gate, product/test-name repair or external runner change was needed.

Seven focused executable-double cases pass, covering passing terminal/private-summary agreement, long-failure diagnostic/log agreement and stage exit 42, timeout exit 124, setup refusals, missing Cargo, both lock guards and stopped later families. These are reporting regressions, not product qualification.

Scoped Docs Sync Maintain updates this note and `AGENTS.md`. The test-plan's common offline gate already delegates root setup and retains the correct family order. Shared history, task store, prior closures, goals and all live/publication gates remain untouched.

## Current MAIN evidence readback

The original `52fc5157` bundle has rotated out. The worker read all five files in the available `c5515c625bcb674c0bec3e2b46008f93e8882a78` bundle under the Git common directory's `autowork-execution/main-evidence/`, in place. Unlike the historical failing bundle, this records green/PASS, eight passing stages, exit 0, an empty isolated-reruns log and empty flaky history. Its default output still ends with only a private summary pathname. This is historical evidence on another source snapshot, not evidence for this delivered tree or a reason to repair a named product test. The bounded reporting change does not reclassify historical failures or establish external classifier behavior.

## Actual delivered-tree full-check receipt

The task-specific Check protocol requires an actual worker run in addition to the runner's separate merged-tree gate. From this execution checkout root, the worker invoked `autowork-run timeout --kill-after=10 1750 bash "$TMPDIR/results-r2-current.sh"`. Slot wait: 60.662523 seconds. The private wrapper exports the captured base, records both lock hashes before and after, captures source hashes and writes the genuine overall exit. It executes this exact declared command (all families retained):

```sh
( AUTOWORK_CACHE="${AUTOWORK_CACHE:-$(git rev-parse --path-format=absolute --git-common-dir)/autowork-execution/cache}" && export AUTOWORK_CACHE && export FLUTTER_ROOT="$AUTOWORK_CACHE/flutter-3.47.9" && export PUB_CACHE="$AUTOWORK_CACHE/pub-cache" && export CARGO_HOME="$AUTOWORK_CACHE/cargo-1.95.0" && export RUSTUP_HOME="$AUTOWORK_CACHE/rustup-1.95.0" && test -x "$RUSTUP_HOME/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin/cargo" && test -d "$CARGO_HOME/registry" && test -x "$FLUTTER_ROOT/bin/flutter" && test -d "$PUB_CACHE" && export PATH="$FLUTTER_ROOT/bin:$RUSTUP_HOME/toolchains/1.95.0-x86_64-unknown-linux-gnu/bin:/usr/bin:$PATH" && flutter --version && flutter --version --machine | /usr/bin/python3 -c 'import json, sys; from pathlib import Path; assert json.load(sys.stdin)["frameworkVersion"] == Path("fdroid/flutter.version").read_text().strip()' && /usr/bin/python3 -c 'import sys, pytest, jinja2, markupsafe; print(sys.executable, sys.version, pytest.__version__, jinja2.__version__); assert callable(markupsafe.soft_str)' && scripts/ci/offline-gate.sh --python-bin /usr/bin/python3 --json )
```

Preflight passed: Flutter 3.47.9 matches `fdroid/flutter.version`, Dart 3.13.7; Python 3.12.3, pytest 9.0.2, Jinja2 3.1.6 and callable `markupsafe.soft_str`. Existing Rust 1.95.0 executable and registry verified. No installs or upgrades.

Source SHA-256 values captured before execution and verified unchanged after (only this documentation receipt is added afterward):

- `AGENTS.md`: `c6e253e22bf3cdeac355d7d15f7bfa90497d30400440c3fbbc29cd1177deb935`
- `scripts/ci/offline-gate.sh`: `ef1561e5e4b814463cfb990632de4dba6bfd03edf35219dc3440240106e51bb2`
- `test/scripts/offline_gate.bats`: `e4393bd01e8c0ffa672bedcc0f79b0256fab260308d6c96a4bf39ea244105e79`

Both lock hashes match before/after and the execution base:

- `pubspec.lock`: `b0677b30481bb5321a7e365eb64dc9b28a71987d3fa32626ff13aa90c328adc8`
- `rust/Cargo.lock`: `97ff3cde076b918449b860fd6b9099b3e30372603a9ebc92187d21f24848f559`

Actual overall exit: **0**. Verdict: **passed**. Failed stage: **null**. NOT_RUN families: **none**.

| Stage | Exit | Seconds |
| --- | ---: | ---: |
| flutter-pub-get | 0 | 0 |
| cargo-fmt | 0 | 1 |
| cargo-clippy | 0 | 7 |
| cargo-test | 0 | 155 |
| flutter-analyze | 0 | 12 |
| flutter-tests | 0 | 1017 |
| python-tests | 0 | 112 |
| bats-tests | 0 | 4 |

Flutter reports `+3500 ~9: All tests passed!`; Python reports `600 passed, 1 skipped, 148 subtests passed`; Bats passes 34 cases. Skips remain skips, not substituted family results. No stage failed, so no isolated unrelated-failure rerun was needed.

Terminal JSON, verified equal to the complete private summary:

```json
{"failed_stage": null, "flutter_version": "3.47.9", "lock_sha256_after": "b0677b30481bb5321a7e365eb64dc9b28a71987d3fa32626ff13aa90c328adc8", "lock_sha256_before": "b0677b30481bb5321a7e365eb64dc9b28a71987d3fa32626ff13aa90c328adc8", "lock_unchanged": true, "log_dir": "/var/tmp/aw-1000-48137133-1/offline-gate-QVXkgn", "pinned_flutter_version": "3.47.9", "rust_lock_sha256_after": "97ff3cde076b918449b860fd6b9099b3e30372603a9ebc92187d21f24848f559", "rust_lock_sha256_before": "97ff3cde076b918449b860fd6b9099b3e30372603a9ebc92187d21f24848f559", "rust_lock_unchanged": true, "stages": [{"exit_code": 0, "seconds": 0.0, "stage": "flutter-pub-get"}, {"exit_code": 0, "seconds": 1.0, "stage": "cargo-fmt"}, {"exit_code": 0, "seconds": 7.0, "stage": "cargo-clippy"}, {"exit_code": 0, "seconds": 155.0, "stage": "cargo-test"}, {"exit_code": 0, "seconds": 12.0, "stage": "flutter-analyze"}, {"exit_code": 0, "seconds": 1017.0, "stage": "flutter-tests"}, {"exit_code": 0, "seconds": 112.0, "stage": "python-tests"}, {"exit_code": 0, "seconds": 4.0, "stage": "bats-tests"}], "verdict": "passed"}
```

Private evidence remains under `/var/tmp/aw-1000-48137133-1/`: `results-r2-current.sh`, `.before`, `.after`, `.sources`, `.exit`, `.log`, plus `offline-gate-QVXkgn/` with all stage logs and summary. This is worker-created evidence, not external runner/runtime-state modification. The exact declared full command is receipted in the report to satisfy the task-specific normalization protocol and the prior missing-command hold. The runner's merged-tree gate remains separate and authoritative for integration. No live/device, goal, publication or external-classifier qualification is claimed.

## Original maintainer limits (historical)

This pass only creates the execution contract. Full gate and worker implementation checks are NOT_RUN. Initial `tasks validate --worktree .` passes (180 tasks, 22 goals). No open task covers full-check result reporting; the prior MAIN-CHECK-01 Python binding repair and physical-oracle producer are already closed and remain closed. `tasks handoff .` reports no pending saved edits, so no ledger proposal is applied or historical closure undone. No goal, live, device or release qualification is inferred.
