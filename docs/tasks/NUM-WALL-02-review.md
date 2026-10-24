# NUM-WALL-02 — Retained integration findings

This is a task-contract clarification, not implementation, integration or a passing
verification receipt. Preserve the task's entire Scope and Acceptance, dependency
on NUM-WALL-01, Next ordering and existing task-only browser permission.

## Docs map and maintenance checklist

- Existing contract: `tasks/items/NUM-WALL-02.md` and unverified goal
  `tasks/goals/NUM-WALL-001.md`.
- Accepted sources: [Number Walls design](../engineering/spec.md#number-walls-and-modular-windows),
  [replay boundary](../engineering/spec.md#number-walls-replay-validation-boundary),
  [loopback exception](../engineering/spec.md#number-walls-widget-test-loopback-exception)
  and [owner outcome](../../PRD.md#number-walls-catalog-category).
- Chosen slice: stale candidate handoff, incomplete Touches and omitted integration
  regressions in Checks. No acceptance transfer, duplicate task or product redesign.
- [x] Read the task, goal, accepted sources, worker reports and retained findings.
- [x] Trace the findings to the existing tests and candidate lifecycle changes.
- [ ] Worker: repair the retained composition and execute the checks below.
- [ ] Worker: obtain actual Chrome widget/state results; retain missing proof as missing.

## Evidence inspected in place

Private evidence remains at its original location; none is copied into this repo.
Paths below identify evidence under the repository's Git common directory or the
named runner state directory:

- `.git/autowork-execution/slot-data/NUM-WALL-02/attempt-{1,2}/report.json`:
  attempt 2 reports candidate `69bae053a59ed70e0263a97eb10931155dd0f192`,
  166 focused native passes, shader/analyzer/math-parity checks, and Chrome widget
  startup timeout (exit 124, **0/5 state cases executed**). These are historical
  worker reports, not full-check or browser acceptance.
- `.git/autowork-execution/slots/NUM-WALL-02.json`: held validation state;
  integration `1ee63570f9e7f2c074194a8fa6308ea2ba37d037` against base
  `0f41de0f534e5a990c5d9292afda5b81d1012141`. Its reverify verdict for
  `33b775e8cc05f4a4bc3e3242d0612821ae4ae3c6` still names both viewer failures.
- Runner state `/home/xel/.local/state/pi-autowork/481371330a53e93e/`:
  `review-findings/NUM-WALL-02.json` names all three failures on `1ee63570`;
  `full-check/NUM-WALL-02-merged.log:473–475,7399–7439` contains the assertions
  and stack below. `NUM-WALL-02-merged.reruns.json` and
  `NUM-WALL-02-merged.quiet.json` both record `flaky: []`, `incomplete: false`;
  their companion logs are empty. Do not invent isolated passing reruns.
- This maintenance checkout has no Number Walls module registration; the retained
  candidate is not an ancestor of its HEAD. Do not treat a retained integration
  worktree/commit as canonical delivery or close the task on that basis.

## Explicit repair obligations under the existing acceptance

1. **Public production fractal counts match the registry.** The integration log
   reports expected 1023, actual 1024. Recompute against the delivered composition,
   using the existing diagnostic/scientific exclusions in
   `test/modules/readme_catalog_claims_test.dart:14–34`; reconcile its assertions,
   README, pubspec description, landing page, store-listing count and EN/ES copy.
   Reconcile the already affected inventory/coverage/count fixtures too. Neither
   1023 nor 1024 is a permanent target; preserve every real registered identity.
   This is catalog-admission compatibility, not permission for a general rebuild.
2. **FractalViewerScreen restores a durable session before the viewer is rendered.**
   The existing test (`test/fractal/fractal_viewer_screen_widget_test.dart:916–965`)
   requires the restored module, camera, visual flags and Controls on the first
   render. The integration rendered Julia but found no `Controls` widget. The
   retained candidate changes session application to return a Future and waits
   before restoring HUD visibility. Preserve ordinary modules' first-frame
   behavior while still delaying Number Walls visual state until certification
   commits; do not add extra pumps or weaken the first-frame assertions to hide it.
3. **FractalViewerScreen unknown restored module is rejected without mutating the viewer.**
   The log reports a null-check exception in `_onControllerChanged`, called by
   `_restoreViewerSession` during `didChangeDependencies`. In the retained candidate,
   its `finally` calls `_onControllerChanged` even when snapshot application throws
   before `_lastController` is attached. Repair lifecycle ordering/completion
   handling at the viewer/session seam. Unknown snapshots must not mutate the
   active module/camera, crash, or create history/persistence for uncommitted state.
   Keep valid, rejected, unfinished and stale Number Walls replay coverage intact.

Compare both retained candidates and current sources before reuse; retain reviewed
work rather than recreating the feature. Relevant seams are
`ViewerSessionSnapshot.applyToController`, controller `loadState`/commit callbacks,
viewer restoration, and controller/history attachment. The existing base viewer
attaches `_lastController` after invoking restoration
(`lib/features/viewer/fractal_viewer_screen.dart:354–409,427–484`); a new synchronous
failure/completion path must not assume that attachment already occurred.

Touches now includes files identified by worker reports, the retained candidate's
count reconciliation and these failing tests. It is not authority to rewrite
unrelated viewer, export, catalog or research behavior. Preserve newer work and
one-writer ownership; no owner receipt, runner reset or runtime-state edit is a
prerequisite for a worker to perform these local repairs.

## Required worker verification

Retain all existing focused Number Walls, catalog, shader, formatting, analyzer,
exact-parity and Chrome widget/state gates, and independent review of the actual
delivered composition. In addition, run:

```sh
flutter test --no-pub test/modules/readme_catalog_claims_test.dart test/fractal/fractal_viewer_screen_widget_test.dart test/viewer/viewer_session_store_test.dart test/screens/settings_screen_a11y_test.dart --reporter expanded
```

Run the **full common offline gate** from the execution checkout using the pinned
SDK and existing provisioned Python bindings in
[MAIN-CHECK-01](MAIN-CHECK-01.md#reproducible-process-local-invocation).
Compare Flutter with `fdroid/flutter.version`, probe `/usr/bin/python3` imports,
regenerate checkout-local metadata and compare `pubspec.lock` hashes. Preserve
all gate families and report actual source revision, command, exits and failures.
A short-circuited full gate is not a pass; separately diagnosing later families
cannot turn it into one. The old cache `PYTHONPATH` workaround is historical,
not the current required binding.

Chrome must run the actual Number Walls state/widget suite on unmodified pinned
Flutter 3.44.6, with the existing NUM-WALL-02-only OS-assigned-loopback permission,
normal browser security and owned-process cleanup. Arithmetic parity does not
replace it. No SDK patch, assertion weakening, skips or newly broadened listener
permission. NUM-WALL-04/05 retain real Linux/browser and installed Android
qualification; goal NUM-WALL-001 remains unverified.

Revisit this clarification when the retained composition or test contracts change;
rerun checks on the delivered bytes rather than reusing these historical results.
