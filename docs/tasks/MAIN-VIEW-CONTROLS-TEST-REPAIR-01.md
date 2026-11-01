# MAIN-VIEW-CONTROLS-TEST-REPAIR-01

## Failure

Main check at revision `747d048ae3ddcd0b4b53139fbc50f32fef1b3a2c` (`747d048a fix(viewer): render mobile controls as circular targets`) reported:

`test/fractal/fractal_view_controls_test.dart: toggle rows expose selected semantics and a changed neutral surface`

The bundle `/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/main-evidence/747d048ae3ddcd0b4b53139fbc50f32fef1b3a2c` records `state=red`, `result_class=TEST_FAILURE`, `main-check.exit=1`, empty `main-check-reruns.log` and empty `flaky_history.json`. The failing case throws `Bad state: No element` at the `surface` helper in `test/fractal/fractal_view_controls_test.dart:602`, where the helper filters `Container` decorations for `borderRadius != null`.

## Diagnosis

Commit `747d048a` changed `lib/features/viewer/chrome/fractal_view_controls.dart` to render mobile controls as circular targets: the toggle decoration moved from `borderRadius: BorderRadius.circular(12)` to `shape: BoxShape.circle`. The test file was not updated in that commit, so at revision `747d048a` the helper's `borderRadius != null` filter matches no `Container` and `.last` throws.

The integration merge `d88a5d50` (an ancestor of the worker baseline `20fc5856`) updated the same helper to `.where((d) => d.shape == BoxShape.circle)`, matching the delivered implementation. The worker baseline contains both the product change and the test adjustment. The `main_check.json` evidence still describes the pre-merge revision `747d048a`.

## Repair contract

Verify the focused case and then the full offline check at the current `main` tip:

1. `flutter test --no-pub test/fractal/fractal_view_controls_test.dart --reporter expanded` (focused).
2. Full check from `AGENTS.md`: `flutter pub get --offline --enforce-lockfile && flutter analyze --no-pub && flutter test --no-pub && /usr/bin/python3 -m pytest test/research test/scripts -q && bats test/scripts/*.bats`.
3. Compare `pubspec.lock` SHA-256 before and after; `git diff --check`.

If the focused case still fails at the current tip, repair the test expectation or the delivered widget contract to make the semantics/neutral-surface assertions hold without weakening them. Do not copy the evidence bundle into the worktree or commit.

## Repair result

Verified at worker baseline `20fc5856cb47ae6d0b02b4300691305b38f03d52` (current `main` and `pi-autowork/20261027-235818`, a descendant of merge `d88a5d50`):

- `test/fractal/fractal_view_controls_test.dart` already filters `shape == BoxShape.circle` (line 601), and `lib/features/viewer/chrome/fractal_view_controls.dart` still renders the toggle surface as `shape: BoxShape.circle`.
- `flutter test --no-pub test/fractal/fractal_view_controls_test.dart --reporter expanded` → exit 0, 31 passed, no skips, including `toggle rows expose selected semantics and a changed neutral surface`.
- `flutter analyze --no-pub` → exit 0, no issues found.

The failing case's `isSelected` semantics assertion and chosen-vs-neutral surface change check are unchanged. No remaining mismatch exists at this revision, so no product or test change was required and none was made.

## Verification limit

This maintainer entry records the failure, its bundle and the known pre-merge mismatch. The worker reproduced the focused passing result above; the full offline gate remains for the coordinator runner on the merged tree. No goal, device, release or live qualification is inferred.
