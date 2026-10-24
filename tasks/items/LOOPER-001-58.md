+++
schema = 1
id = "LOOPER-001-58"
title = "Add optional randomized camera-looper points.**"
short = "Add optional randomized camera-looper points.**"
status = "open"
goal = "LOOPER-RANDOM-001"
section = "Next"
rank = 15000
depends_on = []
touches = ["lib/features/looper/", "lib/features/viewer/dialogs/viewer_dialogs.dart", "lib/features/viewer/export/viewer_export_actions.dart", "lib/l10n/", "test/features/looper/", "test/services/looper_controller_test.dart", "test/a11y/screens/looper_sheet_a11y_test.dart", "test/fractal/fractal_viewer_screen_widget_test.dart", "docs/engineering/test-plan.md"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Add explicit camera-only dice actions for individual A/B/existing optional points and Add random point, reusing the existing list, immutable snapshot/plan, camera bounds and GIF path. Implement the spec's bounded injectable sampler without mutating the viewer to obtain a candidate. Manual controls remain the default; no arbitrary point cap, parameter randomization, seed UI, automatic motion, storage schema, new dependency or release/publication work."
acceptance = ["A can be randomized from empty; B requires A; optional points are appended only explicitly after A/B. Replacing one point preserves all others, order, params, duration, module and live viewer. Seeded samples meet declared camera/bounds contracts; trajectory-backed views/plans are explicitly unavailable to randomization without modifying their metadata or manual controls. Check that guard in UI and controller commands; invalid/disabled/no-change cases remain truthful and safe. A valid edit stops preview without restarting it. New actions are disabled during export and cannot mutate a captured in-flight plan. Preview/GIF use exactly the stored generated states, without further RNG; existing reset/cancel/save/share/GIF guards pass. EN/ES point-specific semantics, keyboard access and 48px targets work without overflow at 320/360 widths and text scales 1/2/3. Composed sheet-to-preview-to-decoded-GIF regression passes as well as manual-only behavior."]
checks = ["Add the composed randomized sheet → preview → decoded-GIF regression to `test/fractal/fractal_viewer_screen_widget_test.dart`, using the existing controller/sheet fixtures; assert the generated stored camera states exactly match preview/export plan states and decoded GIF frames (not merely viewer GIF success). Then run `flutter test --no-pub test/features/looper/looper_controller_test.dart test/services/looper_controller_test.dart test/a11y/screens/looper_sheet_a11y_test.dart test/fractal/fractal_viewer_screen_widget_test.dart --reporter expanded`; `flutter gen-l10n`; `flutter analyze --no-pub`; `dart format --output=none --set-exit-if-changed lib/features/looper/ test/features/looper/ test/services/looper_controller_test.dart test/a11y/screens/looper_sheet_a11y_test.dart test/fractal/fractal_viewer_screen_widget_test.dart`; `git diff --check`. Record fixture identities, deterministic inputs and actual decoded GIF/state/frame assertions. These feature checks are planned, not passing evidence; full offline/device gates remain separate."]
exclusions = []
+++

- Section: Next.
- Sources: [Accepted scope and planner defaults](docs/engineering/spec.md#optional-randomized-camera-looper-points), [owner outcome](PRD.md#optional-looper-point-randomizer), [verification](docs/engineering/test-plan.md#optional-looper-randomizer-verification).
- Ownership: Repository backlog, unassigned; preserve live writers. This request plans only and does not dispatch or change the frozen release.
- Next action: First add and run the missing composed randomized sheet → preview → decoded-GIF regression in `test/fractal/fractal_viewer_screen_widget_test.dart`; it must compare generated stored states exactly with preview/export plan states and decoded GIF frames. The attempt-1 controller, sheet and viewer checks passed, but this composed assertion was not implemented or verified. Then finish any remaining acceptance gaps without changing the accepted planner defaults; do not call the global mutating randomizer or rebuild multi-point support.
