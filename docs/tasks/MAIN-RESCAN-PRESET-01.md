# MAIN-RESCAN-PRESET-01 — Rescan retry and preset render gate

## Documentation map and boundary

- Contract: [task](../../tasks/items/MAIN-RESCAN-PRESET-01.md),
  [accepted app-quality plan](../engineering/spec.md#mcp-assisted-app-quality)
  and [common offline gate](../../AGENTS.md#common-offline-integration-gate).
- Sources: the retained main bundle, failing fixtures, existing retry implementation
  and commit diff since green. No open task covers these two cases.
- Chosen slice: one first-in-Now repair task, not a product repair by this maintainer.
  All prior closures, goal status and live qualification limits remain unchanged.
- Validation: task-store validation, source/path readback and diff whitespace checks.
  Executable suites belong to the repair worker; none were run by this docs pass.

## Retained main result

Read the original bundle in place, without copying it into this checkout:
`/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/main-evidence/c299663227b2cca63585d07ef6b780a1f0981ff2`.
Inspected `main_check.json`, `main-check.log`, `main-check.exit`,
`main-check-reruns.log` and `flaky_history.json`.

Metadata identifies checked revision `c299663227b2cca63585d07ef6b780a1f0981ff2`,
last green `639952fef7c63d844d04b321b88504953736c875`, state `red`,
class `TEST_FAILURE` and exit 1. Dependency preflight and analysis passed.
The Flutter stage ended **3,049 passed, 8 skipped, 2 failed**
(log lines 13966–13970); the chained Python/Bats stages were not reached.
The reruns log is empty, `flaky` is empty and flaky history is `{}`.
There is no supplied isolated-pass evidence or three-revision flaky classification.

| Failing case | Observed failure |
| --- | --- |
| `test/modules/catalog_preset_render_health_test.dart`: audited alternate presets render visible structure | Lines 446–449: 30-second timeout, not a reported failed visual-health verdict. |
| `test/features/viewer/actions/viewer_music_coordinator_test.dart`: ViewerMusicCoordinator._doRestart outcome rescan fallback keeps retrying until visual capture succeeds | Lines 2450–2457: expected playCount 2, actual 1, assertion at test line 458. |

The task Evidence records all six commits since green. Their exact changed paths
are declared in Touches as provenance, not mandatory edits. Neither failing fixture
changed in that diff. A causal relationship to the Fibonacci shader-lifetime change
is unproven; do not revert correct code or alter standing authorization by inference.

## Source-supported investigation

- [Music fixture lines 439–462](../../test/features/viewer/actions/viewer_music_coordinator_test.dart)
  supplies a missing frame then a valid frame, arms a 5ms loop refresh, waits a fixed
  18ms and disposes only after assertions. Nearby successful-restart coverage already
  registers teardown and observes playback completion. Investigate deterministic
  synchronization and failure-path cleanup rather than increasing the delay.
- [Existing retry implementation lines 156–270](../../lib/features/viewer/actions/viewer_music_coordinator.dart)
  re-arms refresh after missing captures and successful fallback playback. This is
  source intent, not proof that every asynchronous path is correct. Any product
  repair needs a failing-before/passing-after regression of that existing contract.
- [Preset fixture lines 8–54](../../test/modules/catalog_preset_render_health_test.dart)
  loops over seven presets, loading each shader and awaiting real image/readback.
  Its cleanup starts after `toImage` completes. Investigate per-preset stage timing,
  compilation/rasterization load and resource lifetime; retain all seven pixel-health
  assertions. The timeout alone does not identify a defective preset or justify
  removing work, weakening thresholds or arbitrarily extending the timeout.

Repeat focused cases, both complete files together and the named adjacent tests;
then run the unchanged full gate with the
[pinned process-local setup](MAIN-CHECK-01.md#reproducible-process-local-invocation).
Record actual source, repetitions, timing, commands and exits. Preserve lockfile
hashes and report any short-circuited stage honestly. No coordinator receipt is
needed to perform local diagnosis. Focused passes do not qualify the full gate.

## Preserved closeout

`FIB-PRIME-03` is already coordinator-closed. Its retained
`slot-data/FIB-PRIME-03/attempt-1/report.json` and commit `5b31f603` describe four
changed files and explicitly no task/history changes; no task-file proposal needs
replaying from that candidate. Local Linux/Chromium journey evidence is not proof
that this merged offline gate passed. Android, physical-GPU and human qualification
remain distinct and unclaimed. Do not reopen the task or recreate removed follow-ups.

Revisit this record when a new main bundle or a source-bound repair supplies new
results; retain this failed revision and its empty rerun history as historical inputs.
