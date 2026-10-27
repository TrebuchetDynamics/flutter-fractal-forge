# MAIN-INVALID-SCAN-01 — Invalid-scan fallback check repair

## Contract and evidence map

- [Task](../../tasks/items/MAIN-INVALID-SCAN-01.md): one bounded offline repair,
  not a music feature or renewed UI refactor.
- Accepted context: [app-quality scope](../../PRD.md#mcp-assisted-architecture-and-ui-improvement)
  and [implementation constraints](../engineering/spec.md#mcp-assisted-app-quality).
- Verification recipe: [common offline gate](../../AGENTS.md#common-offline-integration-gate)
  and [pinned process-local setup](MAIN-CHECK-01.md#reproducible-process-local-invocation).
- Source leads: [music fixture](../../test/features/viewer/actions/viewer_music_coordinator_test.dart)
  and [coordinator](../../lib/features/viewer/actions/viewer_music_coordinator.dart).

## Retained main result

Inspected the original bundle in place, without copying or modifying it:
`/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/main-evidence/6f692bd33ed6ee65426a7dcf4be12b8ad614e4f0`.
Read `main_check.json`, failure/terminal sections of `main-check.log`,
`main-check.exit`, `main-check-reruns.log` and `flaky_history.json`.

- Checked revision: `6f692bd33ed6ee65426a7dcf4be12b8ad614e4f0`;
  last green: `69a3a78d440c9d68dee07ddf79b2f5d927e20dfe`.
- State/class: `red` / `TEST_FAILURE`; exit 1. Dependency preflight and
  analysis passed (log line 53). Flutter ended `+3099 ~8 -1: Some tests failed.`
  at line 14042; the chained Python/Bats stages were not reached.
- Failure: `test/features/viewer/actions/viewer_music_coordinator_test.dart`:
  `ViewerMusicCoordinator.startLoopRefresh invalid scans do not suppress fallback updates`.
  Lines 2515–2523 show expected playCount 1, actual 0, assertion at test line 524.
- Commits since green: `6f692bd3` Merge commit
  `53cb35ddd5aa882a95c124c626309d0a80bf90e8` into `pi-autowork/20261026-183408`;
  `53cb35dd` refactor(ui): share tool buttons and options sheet behavior.
  Their ten changed paths are declared in the task's Touches as provenance,
  not mandatory edits. Neither the music test nor coordinator changed;
  causation is unproven. Do not revert the UI work by inference.
- Current bundle reruns log is empty, `flaky=[]`, history `{}`. No passing
  isolated reruns on this revision or three-revision flaky qualification exist
  in this bundle. Retain the failed result rather than relabel main green.

## Existing evidence and bounded investigation

The closed [MAIN-RESCAN-PRESET-01 record](MAIN-RESCAN-PRESET-01.md#worker-verification)
reports this unchanged case failed during diagnostic/paired execution and passed
one isolated rerun. Its retained `slot-data/MAIN-RESCAN-PRESET-01/attempt-1/report.json`
confirms that result, explicitly leaves this case unchanged and identifies its
candidate as `38ef37e3cb20066621028ef8320eddb808f7db66`. That historical single
rerun is not a current-revision pass or three-revision flaky classification.
No open task covers this case. Preserve all prior closures.

At the inspected source, test lines 505–526 use an empty RGBA buffer with 1×1
geometry, pan the controller, schedule a rescan, sleep 20ms and expect one play;
coordinator disposal follows the assertion. The helper at lines 69–115 uses a
1ms debounce and asynchronous capture/playback. Coordinator lines 124–145 and
156–190 distinguish invalid/missing scan refresh from explicit fallback rescan.
The existing controlled-time cases in this same file are a supported local
pattern. These observations support investigating timing, suite load, pending
work and exception-safe cleanup first; they do not prove a product defect.

Repair only this demonstrated failure and directly necessary fixture lifetime
handling. Keep exact fallback and companion no-fallback-retry/cancellation
assertions. Prefer controlled time or observable completion with bounded cleanup;
no arbitrary sleep/yield increases, retries that hide failure, skips or weakened
assertions. A production edit requires a reproduced defect in the existing
contract and failing-before/passing-after coverage, not new behavior.

## Worker diagnosis and repair

Worker baseline: `1147c862674eb04d6e027415b49b4dd24b25b671`.
The original maintainer observations above precede this test-only repair.

The named fixture assumes that sleeping 20ms means the restart has completed.
The actual chain is `scheduleRescan`'s timer → asynchronous `captureFrame` →
`ViewerEffectsController.restartFractalMusic`'s serialized operation → asynchronous
fake `play` → loop-refresh timer. The sleep does not synchronize with completion
of that chain. Moreover, the original `coord.dispose()` follows the assertion:
the retained failure bypasses cleanup, leaving the fixture's timer/work alive.
Each case constructs its own controller/effects/coordinator; no shared music fake
or frame state was found. Leakage after failure is a lifetime risk, not evidence
that a preceding case caused this failure.

The unchanged baseline passed one isolated run and all three combined runs below.
The precise host scheduling behind the retained full-suite failure was not
reproduced; suite load is not a proven cause. No product fallback defect was
reproduced, and no production or UI source changes are justified by these results.
The coordinator already allows an explicit rescan with invalid pixels to play
fallback, while `skipMissingScan` suppresses fallback during loop-refresh retries.

Only the named case now uses the existing neighboring `testWidgets` pattern:
advance the 1ms debounce with `tester.pump`, draining capture/playback microtasks
before the exact `playCount == 1` assertion. The empty RGBA 1×1 frame, explicit
pan and rescan are unchanged. A `finally` block disposes the coordinator, pumps
pending microtasks and disposes effects even when the assertion fails. Fake time
and the widget-test pending-timer check bound the fixture lifetime; there is no
longer a wall-clock sleep or polling budget in this case. Companion missing-frame,
unchanged-frame, startup, phase, cancellation and disposal tests remain unchanged.

## Worker verification

All commands ran from this worktree with the process-local setup in
[MAIN-CHECK-01](MAIN-CHECK-01.md#reproducible-process-local-invocation):
`FLUTTER_ROOT="$AUTOWORK_CACHE/flutter-3.44.6"`,
`PUB_CACHE="$AUTOWORK_CACHE/pub-cache"`, then
`PATH="$FLUTTER_ROOT/bin:/usr/bin:$PATH"`. No tools/packages were installed.
`flutter --version --machine` matched `fdroid/flutter.version`: Flutter 3.44.6,
Dart 3.12.2. The `/usr/bin/python3` probe passed with Python 3.12.3, pytest 9.0.2,
Jinja2 3.1.6 and callable `markupsafe.soft_str`.
`flutter pub get --offline --enforce-lockfile` passed. Before/after lockfile SHA-256:
`22b29dbd8f71276012a54b9bdc62ba88408f967a86b34075986c17e1c4506ec3`.

Exact focused commands (each repetition is a fresh Flutter invocation):

```sh
flutter test --no-pub test/features/viewer/actions/viewer_music_coordinator_test.dart --plain-name 'ViewerMusicCoordinator.startLoopRefresh invalid scans do not suppress fallback updates' --reporter expanded
flutter test --no-pub test/features/viewer/actions/viewer_music_coordinator_test.dart test/features/auto_explore/auto_explore_service_test.dart test/shared/tool_panel_consistency_test.dart --reporter expanded
```

| Source/selection | Repetitions and actual result | Wall time (`/usr/bin/time -p`) |
| --- | --- | --- |
| Unchanged baseline, isolated | 1 run, 1 passed, exit 0 | 69.94s |
| Unchanged baseline, combined | 3 runs, 47 passed each, exits 0/0/0 | 9.71s / 9.06s / 10.00s |
| Repaired fixture, isolated | 5 runs, 1 passed each, exits 0/0/0/0/0 | 2.85s / 2.89s / 2.56s / 2.37s / 2.53s |
| Repaired fixture, combined | 3 runs, 47 passed each, exits 0/0/0 | 8.96s / 8.89s / 9.39s |

No tests skipped in these selections. Timing includes Flutter startup and is not
a performance comparison. Tested fixture SHA-256:
`74b945156efcd5b33bc2d3fbd86e9ed3067906cfb92bd4d9229ce7e0832ed467`.
`dart format` applied only to this fixture; `autowork-run timeout 300 flutter analyze
--no-pub` passed with no issues (analyzer 13.9s). Final formatting, diff and scoped
documentation readback/link checks are recorded in the worker report.

## Verification boundary and update trigger

The complete unchanged offline gate is **NOT_RUN by this worker**, as the supplied
worker instructions reserve that run for the coordinator on the merged tree.
The retained red main result is not relabeled green. Repeated focused success
neither qualifies that gate nor establishes three-revision flakiness.
Missing tools, skips, timeouts and failures must remain explicit in the subsequent
result. No device, browser, hardware-GPU, release or goal qualification follows.
The docs maintainer should reconcile this record with the coordinator's actual
merged-tree gate result, including delivered source and lockfile hashes.
