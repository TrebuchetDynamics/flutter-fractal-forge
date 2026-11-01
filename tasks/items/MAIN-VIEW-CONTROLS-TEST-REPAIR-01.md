+++
schema = 1
id = "MAIN-VIEW-CONTROLS-TEST-REPAIR-01"
title = "Repair main red: toggle rows expose selected semantics and a changed neutral surface"
short = "Fix the failing fractal view controls test at 747d048a"
status = "open"
goal = "APP-QUALITY-001"
section = "Now"
rank = 0
depends_on = []
touches = ["test/fractal/fractal_view_controls_test.dart", "lib/features/viewer/chrome/fractal_view_controls.dart", "docs/tasks/MAIN-VIEW-CONTROLS-TEST-REPAIR-01.md"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Repair the main red failure `test/fractal/fractal_view_controls_test.dart: toggle rows expose selected semantics and a changed neutral surface` at revision 747d048a. Commit 747d048a changed lib/features/viewer/chrome/fractal_view_controls.dart to render mobile controls as circular targets. The test failed at 747d048a because its `surface` helper looked for a Container with `borderRadius != null`, but the new implementation uses `shape: BoxShape.circle`. The integration merge d88a5d50 updated the test to expect `shape == BoxShape.circle`; verify the test passes at the current main tip and repair any remaining mismatch. Read the evidence bundle in place: /home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/main-evidence/747d048ae3ddcd0b4b53139fbc50f32fef1b3a2c. Do not copy it."
acceptance = ["The test `toggle rows expose selected semantics and a changed neutral surface` in test/fractal/fractal_view_controls_test.dart passes in the full offline check at the repaired revision. Keep the test's semantics assertions and the neutral surface change check; do not weaken or delete assertions."]
checks = ["From the execution checkout root with the AGENTS.md pinned setup: flutter pub get --offline --enforce-lockfile && flutter analyze --no-pub && flutter test --no-pub && /usr/bin/python3 -m pytest test/research test/scripts -q && bats test/scripts/*.bats. Compare pubspec.lock SHA-256 before and after; git diff --check. Run the focused test `flutter test --no-pub test/fractal/fractal_view_controls_test.dart --reporter expanded` first, then the full check."]
exclusions = []
+++
- Sources: main_check.json at /home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/main-evidence/747d048ae3ddcd0b4b53139fbc50f32fef1b3a2c
- Evidence: Failing test: test/fractal/fractal_view_controls_test.dart: toggle rows expose selected semantics and a changed neutral surface. Commits since last green main: 747d048a fix(viewer): render mobile controls as circular targets. Evidence bundle (read in place, do not copy): /home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/main-evidence/747d048ae3ddcd0b4b53139fbc50f32fef1b3a2c. main_check.json: state=red, result_class=TEST_FAILURE, failures=[test/fractal/fractal_view_controls_test.dart: toggle rows expose selected semantics and a changed neutral surface], commits=[747d048a fix(viewer): render mobile controls as circular targets], flaky=[], flaky_history={}, repair_pending=[]. main-check.exit is 1. main-check-reruns.log is empty. The failing test's surface helper at 747d048a expected a Container with borderRadius != null, but the commit changed the decoration to shape: BoxShape.circle. The integration merge d88a5d50 already updated the test to expect shape == BoxShape.circle. Verify the test passes at the current main tip d88a5d50 and repair any remaining mismatch.
