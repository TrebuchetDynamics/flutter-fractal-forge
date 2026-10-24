# NUM-WALL-02 — Retained integration findings

## Current handoff — 2026-10-24

This update supersedes the stale candidate/check status below, not the accepted
Scope, Acceptance, dependency, queue position or browser permission. NUM-WALL-02
is still open. Its latest candidate is `886bbf57b6e95919d96cc782e98681ceba744dac`;
retained integration `30944456069d76eb27d2caea9b5a282a8bc6545e` is based on
`8d94f42734d3ebe2986f664538191e1f5d750a0f`. Neither candidate is canonical delivery
in this maintenance checkout. Reuse the latest reviewed work after checking
current sources and ownership; do not recreate the feature or close the task.

### Evidence and remaining finding

Evidence was read in place, not copied. Under runner state
`/home/xel/.local/state/pi-autowork/481371330a53e93e/`:

- `review-findings/NUM-WALL-02.json` now names only
  `test/services/test_screenshot_service_test.dart`: **TestScreenshotService —
  capture capture creates output directory when it does not exist** on `30944456`.
- `full-check/NUM-WALL-02-merged.log:6109–6116` records `Expected: true`,
  `Actual: <false>` at test line 72. The full Flutter family finishes at
  lines 13831–13834 with `+3000 ~8 -1` and that one failing case. This is a
  failed gate, not a tool crash or a verified product-code regression.
- The same log names the three older count/session cases without failures at
  lines 473, 7404 and 7408. The old review below remains history; these mutable
  runner paths now contain the newer review/log, not the old three-failure run.
- `NUM-WALL-02-merged.{reruns,quiet}.json` bind to `30944456`, with `flaky: []`
  and `incomplete: false`; both companion logs are empty. No isolated passing
  reruns or three-revision flaky classification are provided by these files.
- `.git/autowork-execution/slot-data/NUM-WALL-02/attempt-2/report.json` now binds
  to `886bbf57`: it reports 226 compatibility passes, 35 focused passes, 8 exact
  model passes, 971 matching native/browser math fixtures and **5/5 actual Flutter
  Chrome state cases passed**. This supersedes the prior report's 0/5 startup
  timeout only for that candidate; it is not a passing merged full gate or live
  journey. Attempt 1 retains its failed Chrome history.

### Bounded worker repair and verification

The failing test and screenshot/export services are unchanged between base
`8d94f427` and candidate `886bbf57`. In
`test/services/test_screenshot_service_test.dart:54–76`, twenty zero-delay event
turns stand in for completion of asynchronous `Directory.exists/create`; the
capture future is then ignored. The earlier invalid-key case also leaves its
capture pending. `TestScreenshotService.capture` awaits directory creation before
PNG capture (`lib/core/services/diagnostics/test_screenshot_service.dart:33–47`),
and `ExportService.capturePng` retries via `endOfFrame`
(`lib/core/services/export/export_service.dart:507–547`). These are concrete
fixture timing/lifetime risks, not proof that Number Walls broke directory IO.

- Investigate isolation, filesystem/resource load and pending frame/capture work.
  Replace the fixed-yield race with an explicitly awaited completion or bounded
  condition tied to the existing contract. Use a controlled fixture and settle
  capture work before temporary-directory deletion and singleton teardown.
- Preserve assertions for directory creation, safe names, null-on-failure and no
  crash; do not skip, pre-create the directory under test, increase arbitrary
  yield counts, or change product screenshot/export semantics to satisfy timing.
  Start with the test-only repair; no general export redesign is authorized.
- Run `flutter test --no-pub test/services/test_screenshot_service_test.dart
  --reporter expanded`, repeat it in isolation and with adjacent service tests,
  then rerun the unchanged full offline gate and every existing Number Walls,
  compatibility, shader and parity gate on the delivered composition. Record
  revisions, commands, repetitions, exits and any remaining failures.
- Reuse the candidate's task-scoped `scripts/number-wall-chrome.py` launcher:
  `CHROME_EXECUTABLE="$PWD/scripts/number-wall-chrome.py" timeout --kill-after=10s
  300s flutter test --no-pub --platform chrome
  test/number_walls/number_wall_state_test.dart --reporter expanded --timeout 2m`.
  This is a bounded debug-test budget, not a UI responsiveness claim. Preserve
  all five cases, original grids/assertions, sandboxing, loopback-only permission
  and owned-process cleanup. Do not substitute arithmetic-only browser parity.

Touches adds only the worker-reported launcher and failing test. Scope and every
Acceptance item remain with NUM-WALL-02; NUM-WALL-04/05 and the unverified goal
retain their separate qualification. This pass changes documentation only and
claims no executed repair, passing full gate, integration or live acceptance.

## Historical handoff — earlier three-failure composition

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
