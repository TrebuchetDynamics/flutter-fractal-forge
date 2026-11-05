# MAIN-VIEWER-LOOPER-GESTURE-REPAIR-01

## Failure

Main check at revision `edd74c9c0236a9490692888bc58e79cce9e66ff4` (`edd74c9c Merge commit 'e856876a...' into pi-autowork/20261027-235818`), last green `0cb3da7ae56943c0d5f02842dadbc3e60ec0e221`, reported `state=red`, `result_class=TEST_FAILURE`, `main-check.exit=1`, empty `main-check-reruns.log` and empty `flaky_history.json`.

Six tests failed in the red bundle `/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/main-evidence/edd74c9c0236a9490692888bc58e79cce9e66ff4`:

`test/fractal/fractal_viewer_screen_widget_test.dart`
- `FractalViewerScreen looper GIF caps its longest side at 480 pixels` — `Null check operator used on a null value`, line 2537.
- `FractalViewerScreen looper keeps a completed save when sharing fails` — `Expected: <1> Actual: <0>`, line 2548.
- `FractalViewerScreen looper reports a directory picker failure` — missing `Error al exportar el GIF en bucle` text, line 2598.
- `FractalViewerScreen looper stops preview when the directory picker fails` — `Expected: <2.0> Actual: <1.1294143299579624>`, line 2620.
- `FractalViewerScreen looper export restores the state visible before the picker` — `Expected: <2.0> Actual: <1.8359026940653054>`, line 2635.

`test/fractal/fractal_renderer_gesture_test.dart`
- `Rapid dual double-tap does not stack duplicate triggers` — `targetZoom 1.0552947536110877 exceeds the <=1.0499999999999998 bound`, line 959.

The green->red diff changed `lib/features/viewer/chrome/fractal_view_controls.dart`, added `lib/features/viewer/chrome/viewer_tools.dart`, changed `lib/features/viewer/fractal_viewer_screen.dart` and four viewer control/toolbar tests. The red->tip follow-ups `6bb96124` and `add273dd` changed the same viewer files and added `lib/features/viewer/chrome/viewer_overlay_flow.dart` and `test/features/viewer/chrome/viewer_overlay_flow_test.dart`.

## Diagnosis

The reported failures belong to the pre-follow-up viewer-tools wiring at `edd74c9c`. The follow-up refactors `6bb96124` (overlay sheets through one flow) and `add273dd` (shared sheet row for options tiles) reworked the looper/export and overlay paths. At the current `main` tip `55f9434c` (worker baseline `bf8dfaf3`, a descendant merge), the six named tests and both complete files pass; the failures do not reproduce.

## Repair contract

Verify the focused files first and then the full offline check at the current tip:

1. `flutter test --no-pub test/fractal/fractal_viewer_screen_widget_test.dart test/fractal/fractal_renderer_gesture_test.dart --reporter expanded`.
2. Full check from `AGENTS.md`: `flutter pub get --offline --enforce-lockfile && flutter analyze --no-pub && flutter test --no-pub && /usr/bin/python3 -m pytest test/research test/scripts -q && bats test/scripts/*.bats`.
3. Compare `pubspec.lock` SHA-256 before and after; `git diff --check`.

If a named test still fails at the current tip, repair the looper-export/double-tap wiring or the affected fixture without weakening any assertion. Do not copy the evidence bundle into the worktree or commit. Do not revert the viewer-tools/overlay-flow refactor.

## Repair result

Verified at worker baseline `bf8dfaf3e2fb8d767eb050762fa131e5833ab35c` (current `main` and `pi-autowork/20261027-235818`, a descendant of merge `55f9434c`):

- Focused: `flutter test --no-pub test/fractal/fractal_viewer_screen_widget_test.dart test/fractal/fractal_renderer_gesture_test.dart --reporter expanded` → exit 0, 243 tests passed (209 + 34), no skips, including all six named cases.
- Full check: `flutter pub get --offline --enforce-lockfile && flutter analyze --no-pub && flutter test --no-pub && /usr/bin/python3 -m pytest test/research test/scripts -q && bats test/scripts/*.bats` → exit 0:
  - `flutter analyze --no-pub` → no issues found.
  - `flutter test --no-pub` → 3460 passed, 9 skipped, "All tests passed!".
  - `pytest test/research test/scripts -q` → 468 passed, 1 skipped, 148 subtests passed.
  - `bats test/scripts/*.bats` → 30/30 ok.
- `pubspec.lock` SHA-256 before and after: `d759c63037e4d4f29a7c09b14886854fb8caa832c41f1172ec684a5cdcb7145b` (unchanged).
- `git diff --check` → clean; `git status --short` → empty.

All six named tests pass and the complete unchanged full offline check is green. No product or test change was required and none was made. The offline autowork pub cache lacked `meta 1.19.0`, `vector_math 2.4.4`, `intl 0.20.3`, `matcher 0.12.20` and `test_api 0.7.12`; these were copied from the host pub cache into `$AUTOWORK_CACHE/pub-cache` to let the pinned offline resolution run. That cache population is outside the repository and is not a product change.

## Verification limit

This maintainer entry records the failure, its bundle and the verified passing tip. The worker reproduced the focused and full offline results above; the coordinator runner's gate remains the authority on the merged tree. No goal, device, release or live qualification is inferred.
