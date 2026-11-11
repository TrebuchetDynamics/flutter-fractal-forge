# MAIN-CHECK-RESULTS-01 — additional check-broken evidence

## Bundle read in place

Checked revision: `918a640406e01a8265f4f73ea71b2cb595959b22`.
Last green recorded by metadata: `c026454f2cc3926665b55f68b997f7bb932a8fe4`.
Evidence directory:
`/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/main-evidence/918a640406e01a8265f4f73ea71b2cb595959b22`.

All five files were read in place, not copied or modified:
`main_check.json`, `main-check.log`, `main-check.exit`,
`main-check-reruns.log`, `flaky_history.json`.
The notice reports two crashes. Its crash line is:

```text
[offline-gate] summary: /tmp/aw-main-14d0ilup/offline-gate-zGUsAF/offline-gate.json
```

Metadata records `state=broken`, `result_class=INCOMPLETE`, `failures=null`,
`repair_pending=[]`, and empty flaky history. The exit file is `1`; the
isolated-reruns log is empty and `flaky_history.json` is `{}`.

As in the existing task's earlier bundle, the log contradicts the pre-result
crash description: pub-get, Cargo fmt/clippy/test and Flutter analysis report
passes; Flutter tests then exit 1 with `25:29 +3493 ~9 -1: Some tests failed.`
and a Failing tests footer. Python/Bats are not reached. The summary pathname
is not evidence that a tool crashed or needs provisioning. This note does not
reclassify runner state, infer three-revision flakiness, or turn the footer's
test name into a repair task. No new passing full-check result is evidenced.

## Existing coverage and edit boundary

Read `tasks/items/MAIN-CHECK-RESULTS-01.md`, its accepted approach in
`docs/tasks/MAIN-CHECK-RESULTS-01.md`, and its Sources: root gate setup,
`docs/engineering/test-plan.md#common-offline-gate`, gate script and declared
Bats regressions. The existing scope already covers this same terminal-result
reporting discrepancy; no duplicate task or prerequisite is justified.

Also read the retained attempt's `report.json`, `meta.json`, contract and slot
record under `.git/autowork-execution/slot-data/MAIN-CHECK-RESULTS-01/attempt-1/`
and `.git/autowork-execution/slots/MAIN-CHECK-RESULTS-01.json`.
The worker reports commit `882c0d2a119c8cb8002bc61b1bc54cdb4bfbeef5`, seven
passing executable-double cases and focused checks, but no complete real gate.
It explicitly leaves that gate receipt pending. The slot is held for acceptance;
the recorded PID `1393270` was absent on inspection, but the retained commit is
not an ancestor of this checkout's HEAD. Therefore the instruction not to edit
an entry whose commit waits to land applies even without a live worker.
The task entry, acceptance, dependencies, ordering and runtime state are untouched.
This separate evidence note avoids overwriting the candidate's existing plan edits.

The supported `tasks handoff .` returned no files, empty diff and lifecycle
`clean`: no saved ledger proposal was available here to apply. No historical
closure or newer planning was reversed.

## Remaining action and verification limits

The retained candidate must first be resolved through its existing acceptance
and integration path. Its focused passing report does not prove acceptance or
qualify the goal. Once that protected state is resolved, the existing task can
consume this revision's bundle as additional evidence without broadening scope.
Preserve the bounded approach: existing terminal JSON/reporting interface,
pinned process-local tooling, full diagnostics, genuine exits, both lock guards
and all current stage families. No product/oracle refresh or external runner edit
is authorized by this evidence.

This documentation pass runs task validation and whitespace checks only; the
full offline gate and candidate implementation checks are NOT_RUN here. No
live, device, release or goal qualification is claimed.
