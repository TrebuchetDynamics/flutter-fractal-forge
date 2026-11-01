# MAIN-VIEW-CONTROLS-TEST-REPAIR-01

## Failure

Main check at revision `747d048ae3ddcd0b4b53139fbc50f32fef1b3a2c` (`747d048a fix(viewer): render mobile controls as circular targets`) reported:

`test/fractal/fractal_view_controls_test.dart: toggle rows expose selected semantics and a changed neutral surface`

The bundle `/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/main-evidence/747d048ae3ddcd0b4b53139fbc50f32fef1b3a2c` records `state=red`, `result_class=TEST_FAILURE`, `main-check.exit=1`, empty `main-check-reruns.log` and empty `flaky_history.json`. The failing case throws `Bad state: No element` at the `surface` helper in `test/fractal/fractal_view_controls_test.dart:602`, where the helper filters `Container` decorations for `borderRadius != null`.

## Diagnosis

Commit `747d048a` changed `lib/features/viewer/chrome/fractal_view_controls.dart` to render mobile controls as circular targets: the toggle decoration moved from `borderRadius: BorderRadius.circular(12)` to `shape: BoxShape.circle`. The test file was not updated in that commit, so at revision `747d048a` the helper's `borderRadius != null` filter matches no `Container` and `.last` throws.

The integration merge `d88a5d50` updated the same helper to `.where((d) => d.shape == BoxShape.circle)`, matching the delivered implementation. The current `main` tip is `d88a5d50`, which contains both the product change and the test adjustment. The `main_check.json` evidence still describes the pre-merge revision `747d048a`.

## Repair contract

Verify the focused case and then the full offline check at the current `main` tip:

1. `flutter test --no-pub test/fractal/fractal_view_controls_test.dart --reporter expanded` (focused).
2. Full check from `AGENTS.md`: `flutter pub get --offline --enforce-lockfile && flutter analyze --no-pub && flutter test --no-pub && /usr/bin/python3 -m pytest test/research test/scripts -q && bats test/scripts/*.bats`.
3. Compare `pubspec.lock` SHA-256 before and after; `git diff --check`.

If the focused case still fails at the current tip, repair the test expectation or the delivered widget contract to make the semantics/neutral-surface assertions hold without weakening them. Do not copy the evidence bundle into the worktree or commit.

## Verification limit

This maintainer entry records the failure, its bundle and the known pre-merge mismatch. The passing focused and full-gate results remain for the worker or coordinator runner to reproduce; no goal, device, release or live qualification is inferred.
