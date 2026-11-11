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

## Maintainer limits

This pass only creates the execution contract. Full gate and worker implementation checks are NOT_RUN. Initial `tasks validate --worktree .` passes (180 tasks, 22 goals). No open task covers full-check result reporting; the prior MAIN-CHECK-01 Python binding repair and physical-oracle producer are already closed and remain closed. `tasks handoff .` reports no pending saved edits, so no ledger proposal is applied or historical closure undone. No goal, live, device or release qualification is inferred.
