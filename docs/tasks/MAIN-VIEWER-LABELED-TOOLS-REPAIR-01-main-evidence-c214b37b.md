# MAIN-VIEWER-LABELED-TOOLS-REPAIR-01: refreshed main evidence

## Evidence, not a second repair

The [existing open task](../../tasks/items/MAIN-VIEWER-LABELED-TOOLS-REPAIR-01.md)
and [accepted repair plan](MAIN-VIEWER-LABELED-TOOLS-REPAIR-01.md) already cover
all 42 failures at checked revision
`c214b37bb6572d852e79ba5f4980a2902daf9e26`. Last green remains
`ebb178c23f8eaf20b4d2cb870190d57220dd2d6e`; red began at
`393c45ac957550b08de291104b877f7c56423414`.

Bundle inspected **in place**, not copied or changed:

`/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/main-evidence/c214b37bb6572d852e79ba5f4980a2902daf9e26`

- `main_check.json`: red / TEST_FAILURE; 42 failures, flaky=[],
  flaky_history={}, repair_pending=[].
- `main-check.log`: line 49 reports clean analysis; lines 11375–13164
  record the toolbar presentation, safe-bound, order and palette hit-testing
  failures; line 16305 ends `+3425 ~9 -42: Some tests failed.`
- `main-check.exit`: 1. The chained Python/Bats stages were not reached.
- `main-check-reruns.log`: empty. `flaky_history.json`: {}.
  No isolated passing reruns or three-revision flaky classification are supplied.

Readback compared every metadata failure to the log's `[E]` entries and the
existing plan's original names: exact match, 3 mobile toolbar + 8 responsive
controls + 29 toolbar layout + 2 palette cases. The plan retains the complete
inventory; this evidence does not replace or relax it. The two palette failures
still find no hit-testable `viewerPaletteButton` at helper line 100. Main remains
red, not classified flaky or check-broken.

Metadata lists commits since green: `c214b37b`, `d2cbfc07`, `09572d13`,
`75fec8e6`, `bbf42659`, `d05b7822`, `393c45ac`.
The viewer change remains `393c45ac` (labeled tools), changing
`lib/features/viewer/chrome/fractal_view_controls.dart`,
`lib/features/viewer/fractal_viewer_screen.dart` and
`test/fractal/fractal_view_controls_test.dart`; these and the four failing test
modules are already declared Touches. The intervening repair-planning and Play
observability changes add no new failing module or product prerequisite.
Do not broaden this repair into release tooling.

## Reservation prevents task-entry refresh

At maintainer inspection, the existing slot is `reported`, attempt 1, with
candidate `512482818a70baff3b277d666716b9e0463a3e0d` **waiting to land**.
It is not an ancestor of this checkout's HEAD. Slot evidence:

`.git/autowork-execution/slots/MAIN-VIEWER-LABELED-TOOLS-REPAIR-01.json`

Its `writers_busy_reason` names uncommitted changes in main to
`lib/features/viewer/chrome/fractal_view_controls.dart`,
`test/fractal/viewer_mobile_toolbar_test.dart` and
`test/fractal/viewer_toolbar_layout_test.dart` that would be overwritten.
Read-only main status confirms those dirty paths. This is a legitimate landing
wait, not a missing product dependency. Preserve all dirty work and runtime state.

The retained `slot-data/MAIN-VIEWER-LABELED-TOOLS-REPAIR-01/attempt-1/report.json`
reports exact baseline reproduction and two final focused-union passes, 198/198,
plus clean analysis and unchanged lockfile. Its candidate evidence document
records the diagnosis and original-to-replacement test names. These are **worker
reports**, not maintainer reruns or a merged-tree full-check result. The worker
explicitly did not run the complete offline chain; no combined pass is inferred.

Because the candidate is awaiting integration, the maintainer leaves the task
entry, rank, Touches, Checks, Dependencies, Acceptance and candidate-owned plan
unchanged and creates no duplicate. This separate note avoids conflicting with
the candidate's edits to its evidence document. After the landing reservation
clears, refresh the existing task's Evidence through `tasks field` using this
bundle and the then-current integration/check result; do not reopen a task that
has since closed. The pending full check remains:

```sh
flutter pub get --offline --enforce-lockfile && flutter analyze --no-pub && flutter test --no-pub && /usr/bin/python3 -m pytest test/research test/scripts -q && bats test/scripts/*.bats
```

Use the unchanged task's pinned Flutter 3.47.9/Dart 3.13.7 process-local setup.
No task/goal closure, release, device/browser or visual qualification is implied.
Maintainer application suites: **NOT_RUN** (documentation-only inspection).
Documentation checks: `tasks validate --worktree .` passed (117 tasks, 20 goals,
no drafts/pending); `git diff --check` and local-link readback passed. A fresh
slot readback still showed the same reported, unlanded candidate.
