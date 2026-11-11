# MAIN-CHECK-RESULTS-01 — additional MAIN evidence at 9b003612

## Inspection

Bundle read in place, without copying or changing it:
`/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/main-evidence/9b00361298f37948600be944b0ab87121d14ebc3`.
All five files inspected: `main_check.json`, `main-check.log`, `main-check.exit`, `main-check-reruns.log`, `flaky_history.json`.

Metadata records `broken/INCOMPLETE`, `failures=null`, checked revision
`9b00361298f37948600be944b0ab87121d14ebc3`, last green
`c026454f2cc3926665b55f68b997f7bb932a8fe4`. The notice reports two crashes and names:

```text
[offline-gate] summary: /tmp/aw-main-kcrc2e2h/offline-gate-A1HsbN/offline-gate.json
```

The 53-line log contradicts a literal pre-test crash: pub-get, Cargo fmt/clippy/test and Flutter analysis pass; the Flutter test stage exits 1 after `21:31 +3493 ~9 -1: Some tests failed.` Only the final 40 stage-log lines are exposed. The exit file is 1, reruns log empty and flaky history `{}`. Python/Bats are not reached. This is further evidence of the already documented reporting/classification discrepancy, not proof of a crashing tool, an isolated rerun or a flaky test. No named-test repair is created from this check-broken notice, and no main/goal/live qualification is inferred.

## Existing coverage and preserved candidate

The open `MAIN-CHECK-RESULTS-01` already accepts terminal JSON, observable failure diagnostics, executable-double regressions and a real full-gate result. Its Sources, accepted plan `docs/tasks/MAIN-CHECK-RESULTS-01.md`, retained worker report at `.git/autowork-execution/slot-data/MAIN-CHECK-RESULTS-01/attempt-1/report.json` (under the Git common directory), candidate commit and slot record were inspected.

The retained candidate is `882c0d2a119c8cb8002bc61b1bc54cdb4bfbeef5`, not an ancestor of this checkout. It adds `--json` to the root invocation and full failed-stage output, with seven reported executable-double passes; its report explicitly leaves the complete gate NOT_RUN. The slot is held for acceptance and retains that commit. The recorded worker PID is absent, but that does not erase the pending candidate or authorize rewriting its contract. Per this maintainer request's pending-commit restriction, the task entry and candidate's plan path remain untouched. This separate note preserves the new evidence without racing or superseding that work; no duplicate task, dependency, scope change, closure or runtime-state edit is justified.

The remaining boundary is acceptance/landing of the retained reporting candidate and the actual full check on its delivered bytes. This base-revision bundle cannot supply that proof. Preserve genuine nonzero results and NOT_RUN later stages; do not fabricate terminal JSON or before/after lock hashes absent from this bundle.

## Ledger and verification limits

The supported `tasks handoff` command in this checkout reports a clean lifecycle, empty files/diff and no saved task edits awaiting commit. No specific ledger proposal task or patch path was supplied in the notice; none is applied speculatively and no historical closure is undone.

`tasks validate --worktree .` passes: 184 tasks, 22 goals, no warnings or pending drafts. This is a documentation-only inspection; product suites and the full gate were not run by this maintainer. The task entry remains unchanged because a retained candidate awaits acceptance, not because this inspection has completed its acceptance criteria.
