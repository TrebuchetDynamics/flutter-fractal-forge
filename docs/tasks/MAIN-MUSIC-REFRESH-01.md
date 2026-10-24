# MAIN-MUSIC-REFRESH-01 — Missing-frame refresh fixture repair

## Scope and diagnosis

Worker baseline: `80375294186cf82bbd0bde2542b946e2e323d30e`.
The music coordinator and its test file are unchanged between the failed-main
revision `409db49694afe9e86d508894b75fd1879a3b1a8d` and that baseline.
The retained main-evidence bundle was inspected in place, not copied or changed.
Its failure is the transient missing-frame case, with zero plays instead of one;
the chained gate stopped in Flutter tests. No passing isolated rerun was supplied.
The commits since the recorded green revision only change Number Walls task docs;
there is no evidence that those documentation changes caused the music failure.

The baseline fixture waits 18ms after `startLoopRefresh`, but the work is chained:

1. [`startLoopRefresh` and `scheduleRescan`](../../lib/features/viewer/actions/viewer_music_coordinator.dart)
   arm the fixture's 1ms rescan timer.
2. `_doRestart` awaits the capture. A missing frame with `skipMissingScan` returns
   without restarting fallback music and calls `_armLoopRefresh`.
3. Only then does the fixture's 5ms loop timer start. Its next valid, changed frame
   passes through the asynchronous effects queue and playback before rearming.

A delayed event loop can make both the first rescan and the 18ms assertion deadline
ready before the retry timer is even armed. This is a fixture timing assumption,
not a demonstrated defect in the product retry contract. On unchanged baseline
bytes, five isolated runs produced exits **1, 0, 0, 0, 0**; the failure matched the
retained main symptom. The two requested files together passed all **40 tests**.
An isolated pass is therefore not evidence that the original fixture is reliable.

A temporary diagnostic scheduled the original deadline, then blocked the event
loop for 25ms. Capture tracing showed the missing first capture before the failed
assertion, and the valid second capture **after** the assertion. This reproduced
the scheduling race and demonstrated unfinished fixture work: baseline disposal
was after the assertion and therefore never ran on failure. Diagnostic code and
traces are not part of the delivered test. No product-code repair is justified.

## Delivered change

Only the existing [transient missing-frame case](../../test/features/viewer/actions/viewer_music_coordinator_test.dart)
changes. Flutter's fake clock now advances the rescan and refresh timers separately,
draining capture/playback microtasks at each pump. It asserts zero plays after the
missing frame, exactly one after the changed valid frame, still exactly one after
the next unchanged frame, and no animation sync throughout. A `finally` block
cancels coordinator timers/invalidates captures, drains microtasks, then disposes
the effects fixture even if an assertion fails. There is no wall-clock sleep,
polling budget increase, skip, relaxed assertion or production behavior change.
All companion cases and the completed MAIN-TIMER-REPAIR-001 changes/closure remain
untouched. Number Walls scope, acceptance and ownership also remain untouched.

## Worker verification

All commands use the process-local setup in
[MAIN-CHECK-01](MAIN-CHECK-01.md#reproducible-process-local-invocation):
`FLUTTER_ROOT="$AUTOWORK_CACHE/flutter-3.44.6"`,
`PUB_CACHE="$AUTOWORK_CACHE/pub-cache"`, then
`PATH="$FLUTTER_ROOT/bin:/usr/bin:$PATH"`. No packages or SDKs were installed.

| Check | Result on delivered executable bytes |
| --- | --- |
| Flutter machine version compared with `fdroid/flutter.version`; provisioned Python imports | Exit 0: Flutter 3.44.6, Dart 3.12.2; `/usr/bin/python3` 3.12.3, pytest 9.0.2, Jinja2 3.1.6, callable MarkupSafe `soft_str`. |
| `flutter pub get --offline --enforce-lockfile` | Exit 0; checkout-local metadata regenerated, lock hash unchanged. |
| `flutter test --no-pub test/features/viewer/actions/viewer_music_coordinator_test.dart --plain-name 'ViewerMusicCoordinator.startLoopRefresh keeps refresh loop alive after a transient missing scan frame' --reporter expanded` | Ten repeated isolated runs, each exit 0, one test passed, no skips; an initial post-edit smoke run also passed. |
| `flutter test --no-pub test/features/viewer/actions/viewer_music_coordinator_test.dart test/features/auto_explore/auto_explore_service_test.dart --reporter expanded` | Three repeated paired runs, each exit 0, 40 tests passed, no skips. |
| `autowork-run flutter analyze --no-pub` | Exit 0, no issues. |
| `dart format --output=none --set-exit-if-changed test/features/viewer/actions/viewer_music_coordinator_test.dart`; `git diff --check` | Exit 0 for both. |

Independent read-only review found no correctness or cleanup issues; it did not
run tests. These are focused offline results, not full-gate qualification.
The checked test file's SHA-256 is
`c42db0a390ef6dd2774e04a5a9a68cc5bfcdb8a5c0280621334f534baae3012c`.
The lockfile SHA-256 before preflight and after worker checks is
`22b29dbd8f71276012a54b9bdc62ba88408f967a86b34075986c17e1c4506ec3`.

## Coordinator handoff

The full unchanged offline gate on delivered/merged bytes is **NOT_RUN by this
worker**, as explicitly reserved by the execution instructions. The coordinator
must retain its actual terminal stages, exits, aggregate and before/after lock
hashes; a focused pass does not satisfy that remaining acceptance criterion.
No device, browser, live-audio, production or whole-goal qualification is inferred.
Scoped Docs Sync Maintain records this diagnosis only; shared test-plan/history
and task-store closeout remain coordinator/docs-maintainer owned.
