# MAIN-CHECK-RESULTS-01 — subsequent MAIN evidence triage

## Evidence read in place

Checked revision: `bf869df33f64107fc3e1424566bfdc6d4c4afffd`; last green named by metadata: `c026454f2cc3926665b55f68b997f7bb932a8fe4`.
Bundle: `/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/main-evidence/bf869df33f64107fc3e1424566bfdc6d4c4afffd`.
Read all five files in place: `main_check.json`, `main-check.log`, `main-check.exit`, `main-check-reruns.log`, `flaky_history.json`. Nothing was copied from the bundle.

The notice reports two crashes, with this crash line:

```text
[offline-gate] summary: /tmp/aw-main-t6d1s8mo/offline-gate-acytPL/offline-gate.json
```

Metadata says `broken/INCOMPLETE`, `failures=null`, `repair_pending=[]`. The log instead reports passing offline pub-get, Cargo fmt/clippy/test and Flutter analysis, then Flutter tests exit 1 with `33:12 +3493 ~9 -1: Some tests failed.` It contains a failing-test footer. The exit file is 1, the reruns log is empty and flaky history is `{}`. No isolated rerun or three-revision flakiness is established. Later Python/Bats families are not reached. No crashing tool is identified by this evidence; the summary pathname is not itself a tool crash diagnosis.

## Disposition

The existing open `tasks/items/MAIN-CHECK-RESULTS-01.md` and accepted `docs/tasks/MAIN-CHECK-RESULTS-01.md` already cover exactly this metadata/log reporting discrepancy, including supported `--json` output, complete failure diagnostics, genuine exits and unchanged gate families. Do not create a duplicate or a repair task for the footer's test name. No product defect, full-gate pass or goal qualification is inferred.

The saved slot report under `.git/autowork-execution/slot-data/MAIN-CHECK-RESULTS-01/attempt-1/report.json` and slot record were inspected. The held attempt retains candidate `882c0d2a119c8cb8002bc61b1bc54cdb4bfbeef5`. Its report records seven passing executable-double cases and prerequisite/lock/readback checks, but explicitly leaves the real full-gate receipt NOT_RUN. The recorded worker PID was absent at inspection; that does not authorize editing an entry whose candidate is retained awaiting disposition. Consequently this maintainer pass leaves the task entry, acceptance, dependencies, ordering and candidate-owned plan unchanged. This separate note supplies the subsequent bundle reference without modifying candidate work or runtime state. The original full-gate acceptance remains outstanding; no closure is justified.

`tasks handoff .` reports `files=[]`, empty diff, `commit=null` and a clean lifecycle: no saved task edits await a commit. No proposal is applied and no historical closure or newer planning is undone. The notice supplies no separate task ID or patch location for another ledger proposal.

## Verification and next boundary

`tasks validate --worktree .` passed before this documentation change (181 tasks, 22 goals; no drafts or pending entries). This is evidence triage only; no full gate or implementation checks were run by the maintainer. Continue the existing candidate's supported review/integration path and retain an actual source-bound full-gate result, including stage exits and both lock hashes, before claiming its outstanding acceptance. Do not replace a real failed gate with a successful label or edit external classifier state.
