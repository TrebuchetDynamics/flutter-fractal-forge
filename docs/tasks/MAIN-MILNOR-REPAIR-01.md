# MAIN-MILNOR-REPAIR-01 — 960×720 Milnor preview timeout repair

## Evidence and classification

MAIN reports **red / TEST_FAILURE** on checked revision
`42a879bb43e7e9a0642a0cb5d2d4bd394fee5c21`; the last recorded green is
`a54ef5766070c6cb3ed863e9dae11f4ae87cf67e`. The bundle was read in place, not
copied or changed:
`/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/main-evidence/42a879bb43e7e9a0642a0cb5d2d4bd394fee5c21/`.

- `main_check.json` reports `state=red`, `result_class=TEST_FAILURE`, one failure
  (`test/modules/milnor_brieskorn_render_test.dart: actual 960x720 previews and
  exact replay states`) and one commit since green
  (`42a879bb fix(test): find HUD reset actions by tooltip`).
- `main-check.log:485-490`: the case starts at `01:09`, then at `01:43` records
  `[E]` and
  `TimeoutException after 0:00:30.000000: Test timed out after 30 seconds.`
  (the default `package:test` per-test timeout) before the next case runs.
- `main-check.log:14774-14777`: terminal `+3358 ~8 -1: Some tests failed.` with
  exactly that one test in the `Failing tests:` list. `main-check.exit` is `1`.
- `main-check.log:1-53`: the offline `pub get` resolved packages and
  `flutter analyze --no-pub` printed `No issues found!`; the chained Flutter
  test stage then failed, so the later Python and Bats families were not reached
  and no result for those families is inferred.
- `main-check-reruns.log` is empty; `flaky_history.json` is `{}` and metadata has
  `flaky=[]`. No isolated reruns or three-revision flake classification was
  supplied, so this is a red gate, not a recorded flake.

Commit since green: `42a879bb43e7e9a0642a0cb5d2d4bd394fee5c21`. It changes only
`integration_test/flows/user_flows_test.dart` (HUD reset finders). The failing
test file is unchanged since `96c93583` and no product or shader file changed in
`a54ef576..42a879bb`; causation by that commit is unproven and no rollback is
justified. That changed path is a provenance Touch only.

## Source-supported investigation

The failing case (`test/modules/milnor_brieskorn_render_test.dart:259-300`) loops
over `module.builtInPresets` and, for each, calls `draw(width: 960, height: 720,
transparent: false)`, a full `rawRgba` readback via `rgba(image)`, and then two
32×24 draws that must replay identically. Each `draw` creates a fresh
`ui.FragmentProgram.fromAsset`, fragment shader, `PictureRecorder`, 960×720
`toImage` and readback, so the case performs real host FragmentProgram rendering
work rather than a stub.

The bundle shows the case exceeding the 30-second default timeout during the
full-suite run while the analyzer and preceding cases are clean. That is
consistent with either (a) host readback cost plus loaded-suite resource
pressure/fixture timing exhausting the default timeout, or (b) a reproducible
product/shader performance defect. The bundle alone cannot distinguish them, and
no isolated passing run was retained. Establish which one holds before changing
anything; do not treat an isolated pass as proof the fixture is reliable.

Candidate repairs, in order:

1. Reproduce the case in isolation, repeatedly, and record wall time. If it
   passes alone well under 30s, investigate fixture isolation, suite concurrency
   (`dart_test.yaml` sets `concurrency: 1`) and loaded-suite resource pressure,
   then make the fixture deterministic and bounded — for example dispose and
   settle the program, shader and images per preset, and avoid re-programming
   the same shader asset per draw where the existing contract allows — without
   weakening any assertion.
2. Only if an actual product/shader defect is reproduced (for example unbounded
   work at the extreme zoom/iteration presets) may product or shader code change,
   with a failing-before/passing-after regression.

No assertion may be relaxed: keep the `bytes.toSet().length > 80` distinct-output
check, the exact replay-state equality between the 32×24 `time: 12` and `time: 0`
draws, and the optional `MILNOR_PREVIEW_DIR` PNG/JSON capture behavior.

## Existing task reconciliation

No open task covers this failure. `MAIN-CHECK-01` (provisioned Python/tooling),
`MAIN-RANDOM-FAB-01` and `MAIN-LOGGER-REPAIR-01` are already coordinator-closed
and address different failures. The only other open task, `ACAD-013-4142ef42`, is
unrelated Waydroid device work. The completed `MAIN-CHECK-01` record and
`docs/tasks/MAIN-CHECK-01.md` remain the tooling reference for the worker checks
below.

## Verification boundary

Worker checks use MAIN-CHECK-01's process-local invocation and the common offline
gate. From the execution checkout root:

```sh
export FLUTTER_ROOT="$AUTOWORK_CACHE/flutter-3.44.6"
export PUB_CACHE="$AUTOWORK_CACHE/pub-cache"
export PATH="$FLUTTER_ROOT/bin:/usr/bin:$PATH"
```

(These exports are scoped to command subshells, not the host/profile.)

| Worker check | Expected evidence |
| --- | --- |
| `flutter --version` vs `fdroid/flutter.version`; `/usr/bin/python3` imports of pytest, jinja2 and callable `markupsafe.soft_str` | Flutter 3.44.6 / Dart 3.12.2 and usable provisioned Python, no installs. |
| `flutter test --no-pub test/modules/milnor_brieskorn_render_test.dart --reporter expanded`, repeated, plus the focused `--plain-name 'actual 960x720 previews and exact replay states'` | Failing-before and passing-after wall times, commands and exits for isolated and repeated runs. |
| `flutter pub get --offline --enforce-lockfile && flutter analyze --no-pub && flutter test --no-pub && /usr/bin/python3 -m pytest test/research test/scripts -q && bats test/scripts/*.bats` | Complete unchanged gate on delivered bytes, `pubspec.lock` SHA-256 before/after, `git diff --check`. If a stage fails, retain it and diagnose the remaining families separately. |

This document and the task record are a bounded repair contract, not a passing
suite result. Maintainer executable checks are **NOT_RUN**; no goal, device,
production or live qualification is claimed.
