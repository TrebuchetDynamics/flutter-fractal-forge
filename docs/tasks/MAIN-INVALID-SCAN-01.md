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

## Verification boundary and update trigger

This maintainer pass changes documentation only. Flutter checks are NOT_RUN here;
the new task requires repeated isolated/combined execution and the complete
unchanged offline gate on delivered bytes. Missing tools, skips and failures stay
explicit. No device, browser, hardware-GPU, release or goal qualification follows.
Revisit when a source-bound repair or new main bundle supplies actual results.
