# MAIN-INITIAL-SCAN-01 — Initial-enable missing-scan check

## Scope and evidence

This records the bounded [task](../../tasks/items/MAIN-INITIAL-SCAN-01.md), under
[app quality](../../PRD.md#mcp-assisted-architecture-and-ui-improvement) and its
[implementation constraints](../engineering/spec.md#mcp-assisted-app-quality).
Use the [pinned offline setup](MAIN-CHECK-01.md#reproducible-process-local-invocation).
This is a fixture repair/verification record, not a new audio feature.

- [x] Inspect retained failure, current fixture and production call chain.
- [x] Preserve deterministic synchronization and exception-safe cleanup.
- [x] Check initial playback and each unchanged-frame refresh separately.
- [x] Repeat isolated/combined checks and record source/lockfile hashes.
- [ ] Coordinator: full unchanged offline gate on the merged tree.

Inspected in place, without copying or modifying, all five files in the runner's
`main-evidence/60b3c4cdc6c046e30b796058776884ee23adb166/` bundle:
`main_check.json`, failure/terminal sections of `main-check.log`, `main-check.exit`,
`main-check-reruns.log`, `flaky_history.json`.
The checked revision was `60b3c4cdc6c046e30b796058776884ee23adb166`, last green
`d967721435c408aa870999d4c073a871ac4eaac5`. State/class: red / TEST_FAILURE;
exit 1. Log lines 2521–2528 show the named initial-enable case expected
`playCount == 1`, actual 0, at test line 569. Lines 14046–14049 end
`+3100 ~8 -1: Some tests failed.` Preflight and analysis passed; chained Python
and Bats were not reached. Reruns are empty, flaky list empty, history `{}`.
No isolated success or three-revision flaky qualification comes from that bundle.
The intervening reporting commit did not change music source/fixture; it does
not establish reporting causation or justify rollback.

## Diagnosis and adopted repair

Worker baseline: `94114266bd4bf15cbe73b50a097741cdafb28746`.
Unlike the older task evidence, this baseline **already includes**
`77ef6c5453f214ee70f522dc13618ea740bf1c86`
(`test(viewer): make initial music refresh check deterministic`). Its existing
change replaces the named case's 12ms sleep with `testWidgets` and separate
1ms/5ms/5ms pumps, and adds `finally` cleanup. This worker adopts that repair;
it does not claim to have introduced it or undo it to recreate the old failure.
The [invalid-scan companion repair](MAIN-INVALID-SCAN-01.md#worker-diagnosis-and-repair)
is distinct and unchanged.

The [fixture](../../test/features/viewer/actions/viewer_music_coordinator_test.dart)
uses a fresh controller per case, fresh effects/music fake and an asynchronous
capture helper with a 1ms rescan debounce. The actual chain is
[`startLoopRefresh` / `scheduleRescan` / `_doRestart`](../../lib/features/viewer/actions/viewer_music_coordinator.dart)
→ timer → asynchronous capture →
[`restartFractalMusic`'s serialized queue](../../lib/features/viewer/actions/viewer_effects_controller.dart)
→ asynchronous fake play → loop-refresh timer.
A 12ms wall-clock sleep does not synchronize completion of that chain: delayed
capture/playback work can outlive the assertion deadline. The old disposal after
assertions also allowed a failure to bypass cleanup. No shared fake/frame state
was found; leaked work after a failed assertion is a risk, not proof of an
incoming leak. Exact scheduling behind the historical loaded-suite failure was
not reproduced. The already-repaired baseline passed locally; suite load remains
an investigation lead, not a demonstrated product defect.

This worker strengthens only the existing named case: exact `playCount == 1`
and empty animation-sync assertions now follow the initial 1ms pump and each
5ms refresh, rather than only the last pump. A delayed startup can no longer hide
behind later refreshes. The case still starts with music enabled and **no**
`scanFrame`, captures `frameWithValue(140)`, and uses a 5ms refresh interval.
No production change is justified or made. All companion cases remain unchanged.

Existing `finally` cleanup cancels coordinator timers, pumps pending microtasks,
then disposes effects even when a behavior assertion fails. The fake capture/play
have no external I/O or unresolved barriers here; fixed fake-time pumps drain the
chain without a wall-clock polling budget. Widget-test pending-timer verification
bounds cleanup. No increased sleep/yield, skipped assertion or swallowed failure
is introduced.

## Worker verification

From the execution checkout root, in each checking subshell:

```sh
export FLUTTER_ROOT="$AUTOWORK_CACHE/flutter-3.44.6"
export PUB_CACHE="$AUTOWORK_CACHE/pub-cache"
export PATH="$FLUTTER_ROOT/bin:/usr/bin:$PATH"
```

`flutter --version --machine` matched `fdroid/flutter.version`: Flutter 3.44.6,
Dart 3.12.2. The `/usr/bin/python3` import probe passed: Python 3.12.3, pytest
9.0.2, Jinja2 3.1.6, callable `markupsafe.soft_str`.
`flutter pub get --offline --enforce-lockfile` passed; nothing was installed.
Lockfile SHA-256 before preflight and after checks was unchanged:
`22b29dbd8f71276012a54b9bdc62ba88408f967a86b34075986c17e1c4506ec3`.

Exact test selections (each repetition a fresh invocation):

```sh
flutter test --no-pub test/features/viewer/actions/viewer_music_coordinator_test.dart --plain-name 'ViewerMusicCoordinator.startLoopRefresh retries once after initial enable when scan frame was missing' --reporter expanded
flutter test --no-pub test/features/viewer/actions/viewer_music_coordinator_test.dart test/features/auto_explore/auto_explore_service_test.dart test/screens/debug_mode_test.dart --reporter expanded
```

| Source / selection | Results and exits | Wall seconds (`/usr/bin/time -p`) |
| --- | --- | --- |
| Unchanged worker baseline / isolated | 2 runs, 1 passed each, 0/0 | 37.31 / 3.80 |
| Unchanged worker baseline / combined | 1 run, 45 passed, 0 | 21.54 |
| Intermediate step assertions / isolated | 5 runs, 1 passed each, all 0 | 7.35 / 4.15 / 3.44 / 3.48 / 3.32 |
| Intermediate step assertions / combined | 45 passed / 45 passed / 44 passed + 1 unrelated failure; 0/0/1 | 17.23 / 12.18 / 27.81 |
| Delivered fixture / isolated | 2 runs, 1 passed each, 0/0 | 2.31 / 4.26 |
| Delivered fixture / combined | 2 runs, 45 passed each, 0/0 | 40.95 / 16.33 |

The intermediate and delivered fixtures differ only in one explanatory comment.
Intermediate fixture SHA-256:
`4005cd05eb52bd55a49424737ca64585184d6a83eb46a05cd1e95743ab61f8c2`.
Delivered fixture SHA-256:
`8a8d25e8858e48fcb77aa29c80a7d75cf740abda72be750e1d969fa613b687fb`.
No skips occurred in these selections. Timings include startup/compilation and
are not a performance comparison.

The unrelated failure was the unchanged `aligned Fourier restart publishes only
after a real bar transition`, expected 1 / actual 0 at test line 666. Its one
required isolated rerun passed, exit 0, 4.28s:

```sh
flutter test --no-pub test/features/viewer/actions/viewer_music_coordinator_test.dart --plain-name 'aligned Fourier restart publishes only after a real bar transition' --reporter expanded
```

It remains an explicit unrelated failure in the worker report, not a green
relabeling of that combined attempt. The named initial-enable case passed in
that attempt as well. No three-revision flaky classification is inferred.

`autowork-run timeout 300 flutter analyze --no-pub` passed with no issues
(analyzer 12.7s). Formatting, diff and scoped documentation checks accompany the
worker report. No sharded check runner exists in this checkout, so focused tests
used Flutter directly.

## Qualification boundary and next action

The full unchanged offline gate is **NOT_RUN by this worker**: the execution
instructions reserve it for the coordinator on the merged tree. These focused
passes do not qualify the full gate or erase the retained red main result.
The coordinator must record the actual merged revision, complete unchanged gate
result, stage exits and before/after lockfile hashes. DOCS-MAINTAINER should
reconcile this evidence owner with that result without changing acceptance or
prior closures. Device/browser/hardware-GPU, live audio, release and goal
qualification are not inferred or added to this offline task.
