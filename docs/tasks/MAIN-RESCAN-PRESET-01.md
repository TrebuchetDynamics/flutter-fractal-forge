# MAIN-RESCAN-PRESET-01 — Rescan retry and preset render gate

## Documentation map and boundary

- Contract: [task](../../tasks/items/MAIN-RESCAN-PRESET-01.md),
  [accepted app-quality plan](../engineering/spec.md#mcp-assisted-app-quality)
  and [common offline gate](../../AGENTS.md#common-offline-integration-gate).
- Sources: the retained main bundle, failing fixtures, existing retry implementation
  and commit diff since green. No open task covers these two cases.
- Chosen slice: fixture timing, per-preset audit granularity and exception cleanup;
  no production-code change. All prior closures, goal status and live qualification
  limits remain unchanged.
- Validation: the worker results below supersede the initial documentation-only
  investigation. The coordinator still owns integration and the full merged-tree gate.

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

## Worker diagnosis and bounded repair

Source baseline: `bbbfe1de80d51598fe0c909a9eb84ce46715ad81`. Measurements below
use its executable source plus only the two fixture changes described here.

### Rescan retry: reproduced fixture timing failure

The [music fixture](../../test/features/viewer/actions/viewer_music_coordinator_test.dart)
waited 18ms for a 1ms rescan timer, asynchronous capture/playback and a subsequently
armed 5ms retry timer. If the first timer runs late, the already-due assertion can
run before the newly armed retry. A four-file diagnostic run reproduced expected
`playCount == 2`, actual `1`. Disposal after assertions also left the retry running
when that assertion failed.

The existing case now uses `testWidgets` controlled time: pump 1ms and drain
fallback capture/playback microtasks, then pump 5ms for successful visual retry.
It asserts exactly two plays, phase `0.375` on both, no scanner reset, and no third
play for the unchanged next frame. A `finally` cancels the coordinator, drains
microtasks and disposes effects even if an assertion fails. The
[production retry](../../lib/features/viewer/actions/viewer_music_coordinator.dart)
is unchanged; no product defect was reproduced.

### Preset audit: cumulative deadline and exception ownership

The original [preset fixture](../../test/modules/catalog_preset_render_health_test.dart)
put seven independent runtime-effect audits behind one 30-second deadline. It
passed unchanged in isolation (about 2 seconds of test time) and in the four-file
composition (about 24 seconds for this case). Temporary stage tracing measured
shader load/readback at 0–4ms and rasterization at 25–1637ms per preset in another
run. This supports variable raster-work/load sensitivity, not a missing await.
The retained timeout has no preset/stage attribution: its precise native cause
remains unproven, and the timeout itself was not reproduced locally.

Each existing preset is now a named data row with the same default per-case
deadline. All seven retain their exact merged parameters, view, time zero,
128×128 runtime-effect draw, awaited raster/readback and `RenderAuditMetrics`
`pass` assertion. No synthetic frames, skips, retries or threshold/timeout overrides
were added. This is a granularity repair, **not process isolation**: cases share a
suite process. It deliberately increases the possible aggregate allowance from
one default deadline to seven, so unrelated presets no longer consume another
preset's deadline. It does not claim unchanged aggregate timeout semantics.
Per-stage diagnostics now identify load, draw, raster and readback completion.

A separate verified cleanup defect is repaired: shader/picture ownership now
covers uniform setup, drawing and `toImage` failure, rather than beginning only
after rasterization succeeds. The image, picture and shader are disposed in order.
This does not cancel an engine future that never settles. The original fixture
already retained its shader through readback; no shader-GC race, cross-file leak
or product-renderer defect was established. Fourier shader lifetime work is retained.

## Worker verification

All commands ran from this checkout with the
[pinned process-local setup](MAIN-CHECK-01.md#reproducible-process-local-invocation):
Flutter 3.44.6 / Dart 3.12.2 matched `fdroid/flutter.version`; `/usr/bin/python3`
3.12.3 imported pytest 9.0.2, Jinja2 3.1.6 and callable MarkupSafe `soft_str`.
`flutter pub get --offline --enforce-lockfile` passed. Lockfile SHA-256 before/after:
`22b29dbd8f71276012a54b9bdc62ba88408f967a86b34075986c17e1c4506ec3`.

Commands below use `flutter test --no-pub ... --reporter expanded`; durations are
whole-command wall seconds including startup, not gate performance claims.

| Selection | Actual results on repaired fixtures |
| --- | --- |
| Music file with `--plain-name 'ViewerMusicCoordinator._doRestart outcome rescan fallback keeps retrying until visual capture succeeds'` | Three isolated runs: 1 passed each, exit 0; 3.96 / 2.99 / 14.12s. |
| `test/modules/catalog_preset_render_health_test.dart` | Three isolated runs: all 7 passed each, exit 0; 5.73 / 8.44 / 5.38s. |
| Both whole files together | Two successful runs: 33 passed each, exit 0; 8.22 / 7.72s. An intervening run had 32 passed and one unchanged timing-case failure, as classified below. |
| Both files plus `test/features/auto_explore/auto_explore_service_test.dart` and `test/modules/clean_room_visual_additions_test.dart` | Two runs: 51 passed each, exit 0; 11.76 / 12.33s. No skips. |
| `autowork-run timeout 300 flutter analyze --no-pub` | Exit 0, no issues. |

Across those eight preset executions (including the intervening pair run),
per-preset measured ranges were load 13.554–247.959ms (including module/preset
lookup), draw 0.072–8.006ms, raster 20.336–2733.919ms, readback 0.114–4.173ms.
Every pixel verdict passed. These are host-test observations, not GPU qualification.

Unchanged cases `unchanged full rotation neither restarts nor resets the scanner`,
`invalid scans do not suppress fallback updates`, and `retries once after initial
enable when scan frame was missing` also failed fixed-sleep assertions during
baseline diagnostics or the intervening pair run. Each passed its one required
isolated rerun (1 passed, exit 0; 2.64 / 2.93 / 2.76s). They remain explicitly
classified unrelated timing failures, not hidden passing batch results or a
three-revision flaky qualification. Their bodies are unchanged.

The worker did **not** run the complete offline gate: execution instructions
reserve it for the coordinator on delivered/merged bytes. Focused passes and
analysis are not a green full gate, task closure, integration or live/goal
qualification. Retain the coordinator's actual chained result and lockfile hashes;
no device/browser, physical-GPU or human acceptance is supplied here.

## Preserved closeout

`FIB-PRIME-03` is already coordinator-closed. Its retained
`slot-data/FIB-PRIME-03/attempt-1/report.json` and commit `5b31f603` describe four
changed files and explicitly no task/history changes; no task-file proposal needs
replaying from that candidate. Local Linux/Chromium journey evidence is not proof
that this merged offline gate passed. Android, physical-GPU and human qualification
remain distinct and unclaimed. Do not reopen the task or recreate removed follow-ups.

Revisit this record when a new main bundle or a source-bound repair supplies new
results; retain this failed revision and its empty rerun history as historical inputs.
