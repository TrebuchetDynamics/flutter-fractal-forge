# MAIN-CHECK-RESULTS-01 — additional MAIN evidence at 1954d052

## Bundle inspection

Bundle read in place, not copied or modified:
`/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/main-evidence/1954d05257ecd28ffa0f637fd77134c1f1413087`.
All five files inspected: `main_check.json`, `main-check.log`, `main-check.exit`, `main-check-reruns.log`, `flaky_history.json`.

Checked revision is `1954d05257ecd28ffa0f637fd77134c1f1413087`; last green named by metadata is `c026454f2cc3926665b55f68b997f7bb932a8fe4`. Metadata says `broken/INCOMPLETE`, `failures=null`, and the notice reports two crashes with this marker:

```text
[offline-gate] summary: /tmp/aw-main-ltos7gij/offline-gate-SNUB1u/offline-gate.json
```

The actual log passes pub-get, Cargo fmt/clippy/test and Flutter analysis, then reports flutter-tests exit 1 and `29:34 +3493 ~9 -1: Some tests failed.` A failing-tests footer is present. The exit file is 1, isolated-reruns log is empty, and flaky history is `{}`. Python/Bats are not reached. This repeats the reporting/classification discrepancy documented in `MAIN-CHECK-RESULTS-01.md` and `MAIN-CHECK-RESULTS-01-9b003612-evidence.md`; it does not establish a crashing tool or justify a tool installation, named-test repair or flakiness classification. Do not turn this check-broken notice into a product repair contract.

## Existing coverage and pending candidate

The open task `tasks/items/MAIN-CHECK-RESULTS-01.md` already covers observable terminal JSON, full failure diagnostics, executable-double regressions and an actual delivered-byte full-gate result. Its Sources and accepted plan `docs/tasks/MAIN-CHECK-RESULTS-01.md` were inspected, along with the existing supplemental note, root setup, common offline test-plan section, gate reporting implementation and retained slot/report records.

The second attempt report is retained under the Git common directory at `autowork-execution/slot-data/MAIN-CHECK-RESULTS-01/attempt-2/report.json`. Candidate `1a89f330d239338396ef823ac33946505c8889f1` reports seven passing executable-double cases, unchanged locks, validated provisioned tooling and scoped documentation checks. Its third Acceptance item remains `not_checked`: the worker instructions prohibit the real complete gate and reserve it for the runner. The slot is held for that acceptance gap and retains the candidate; its recorded worker PID `2536505` is absent at inspection.

Absence of a live worker does not authorize rewriting a contract with a retained candidate awaiting acceptance. Preserve the task entry, accepted plan, Acceptance, Checks, Dependencies, priority and candidate. No duplicate repair task or dependency is warranted. This separate evidence note records the current revision without editing that pending entry. The unresolved boundary is the actual full check on delivered reporting-candidate bytes, followed by source/command, stage/overall exits and both lock hashes in the task note. This base-revision bundle cannot supply that proof; do not invent a coordinator receipt or mark acceptance complete.

## Ledger and verification

Supported `tasks handoff .` reports a clean lifecycle, no saved files/diff and no pending commit. No saved ledger proposal is applied and no newer planning or closure is undone.

`tasks validate --worktree .` passes with 184 tasks, 22 goals, no drafts, pending records or warnings. Product suites and the full gate are NOT_RUN by this documentation-only maintainer. No goal, main, device, live or publication qualification is inferred. Only this evidence note is added; task entry edits remain deferred under the pending-candidate restriction.
