# LOOPER-001-58 verification

Scoped implementation and offline evidence for [the accepted camera sampler](../engineering/spec.md#optional-randomized-camera-looper-points) and [its unchanged verification contract](../engineering/test-plan.md#optional-looper-randomizer-verification). This is candidate evidence on baseline `d256e78816d8974f13e13173ac22653f46ee6e62`, not integration, publication or device qualification. Historical attempt totals are not reused.

## Implementation

- [`sampleLooperCamera`](../../lib/features/looper/looper_camera_sampler.dart) is a pure function with injectable `dart:math Random`. It validates the anchor before drawing, samples once using the accepted log-zoom/pan/pitch/yaw defaults, and applies existing module bounds. It never calls a mutating viewer API.
- [`LooperController`](../../lib/features/looper/looper_controller.dart) can create A from the viewer snapshot and B after A. Existing-point replacement anchors to that point; explicit Add random point anchors to the last point and requires A/B. A successful commit cancels preview without moving the viewer. Invalid, unavailable and clipped/no-change commands return false without editing points or stopping preview.
- Active or stored trajectory metadata makes all random commands unavailable. Manual capture, duration, removal and preview controls retain their existing behavior; trajectory interpolation itself is not qualified by this feature.
- The looper export locks random commands before the directory picker and unlocks in `finally`, including cancellation/failure. The controller also rechecks viewer/export-coordinator busy state. The GIF retains its captured immutable plan. Disposal safely ignores late unlock notifications.
- Preview now uses elapsed `Timer.tick` intervals instead of the adjustable wall clock. This makes the same stored plan reproducible under the widget-test clock and avoids wall-clock changes altering the sampled phase.
- [`LooperSheet`](../../lib/features/looper/looper_sheet.dart) exposes localized point-specific dice tooltips, keyboard-operable controls, success/unchanged SnackBar announcements, and a wrapping full-width Add random point button. It observes live trajectory eligibility changes while open.

## Fixtures and assertions

[`test/services/looper_controller_test.dart`](../../test/services/looper_controller_test.dart):

- Seed 42 on 2D `mandelbrot`: zoom factor in `[0.8, 1.25]`, per-axis pan jitter at most `0.15` for zoom 1, only the chosen point replaced, other point identities/params/duration and the frozen earlier plan preserved. A valid reroll stops active preview.
- Seed 19 on `mandelbulb`, pan `(0.4,-0.3)`, zoom 3, rotation `(0.2,-0.4,0.6)`: pan/roll unchanged, pitch/yaw jitter at most `pi/12`, bounded zoom factor.
- Seed 7: B rejected before A, A and then B explicitly generated, optional append rejected until A/B exist.
- Constant draws 0 and 0.999999: `cantor_set` minimum zoom 0.2 and pan boundary -3, deep zoom ceiling `1e12`, zoom-scaled pan jitter, and clipped no-change outcomes. Repeated seed-42 samples match. NaN/infinite/nonpositive/over-limit zoom and invalid pan anchors are rejected before any RNG call.
- `thomas_attractor` trajectory settings: rejected commands preserve the exact settings object and stored snapshot. Busy/no-change actions retain preview and the captured plan, and busy commands consume no RNG.

[`test/a11y/screens/looper_sheet_a11y_test.dart`](../../test/a11y/screens/looper_sheet_a11y_test.dart):

- Empty-list A is activated with Enter, leaves viewer pan/zoom/params unchanged, then the enabled B dice creates B.
- The existing overflow matrix now includes EN/ES, 0/4 points, widths 320/360 (also 640 landscape), and text scales 1/1.3/2/3. Every random control is scrolled into view and measured at least 48×48 logical pixels. Point-specific tooltips are checked, keyboard C rerolls preserve A/B/D, and the populated matrix checks active and stored-only trajectory guards with localized explanation. These are widget layout/interaction measurements, not physical screen-reader acceptance.
- A stale callback is rechecked after trajectory activation; stored metadata survives clearing only the active view. Export-busy disables all new actions while manual Set A remains available. Existing control-name, target, contrast and localization cases are retained.

[`test/fractal/fractal_viewer_screen_widget_test.dart`](../../test/fractal/fractal_viewer_screen_widget_test.dart), `random looper points preview and export the exact captured plan frames`:

1. Open the actual `mandelbrot` viewer sheet; activate Randomize A from empty, Randomize B after A, then Add random point. UI dice use normal unseeded RNG; the exact three generated snapshots are captured within that invocation rather than assuming fixed random output. Sampler reproducibility is separately established by the seeded fixtures above.
2. Freeze the six-second, three-point plan. Preview at 330ms (ten 33ms ticks) must equal `plan.stateAtPhase(330/6000)` bit-for-bit for all six camera doubles. Stored point identities remain unchanged and Preview is explicitly stopped.
3. Export through the real GIF encoder using the existing export-service capture seam. Each of 48 PNGs encodes its actual captured pan, zoom and rotation as six float64 values in 384 black/white pixels (16×24). Randomize/add commands are attempted at each capture and must remain rejected while busy.
4. Decode the saved GIF, require 48 frames at 16×24 and 120ms per frame, recover all 48 camera bytes from every decoded frame, and compare exactly with both `plan.stateAtFrame(i)` and the captured camera. This discriminates state changes, reorder, duplicate/missing frames and resampling; it is not a production GPU image comparison.

Existing manual-only looper interpolation, module reset, GIF dimensions/duration, picker failure, state restoration, saved-file/share failure and publication cancellation tests remain in the selected suites.

## Fresh commands and results

Environment: provisioned Flutter 3.44.6 / Dart 3.12.2, `PUB_CACHE=$AUTOWORK_CACHE/pub-cache`; no dependency or lockfile changes. The test/analyzer commands used `autowork-run` for admission. Logs are task-local under `$TMPDIR`.

| Command | Exit / result |
| --- | --- |
| `flutter pub get --offline --enforce-lockfile` | 0; checkout-local metadata regenerated, lockfile unchanged |
| `autowork-run flutter test --no-pub test/features/looper/looper_controller_test.dart test/services/looper_controller_test.dart test/a11y/screens/looper_sheet_a11y_test.dart test/fractal/fractal_viewer_screen_widget_test.dart --reporter expanded` | 0; 267 tests passed on final code inputs (`task-tests-final.log`) |
| `flutter gen-l10n` | 0; EN/ES sources regenerated |
| `autowork-run flutter analyze --no-pub` | 0; no issues |
| `dart format --output=none --set-exit-if-changed lib/features/looper/ test/features/looper/ test/services/looper_controller_test.dart test/a11y/screens/looper_sheet_a11y_test.dart test/fractal/fractal_viewer_screen_widget_test.dart` | 0; no changes |
| `git diff --check` | 0 |
| `python3 "$TMPDIR/looper_docs_check.py"` | 0; scoped Maintain readback, 8 local links/anchors, shared accepted owners unchanged |
| bundled Docs Sync `docs.py check .` | 0; no role manifest, so no manifest-wide content verdict |
| `autowork tasks validate --worktree .` | 0; task store valid, no drafts; no task records modified |

An earlier union run encountered the untouched `random fractal FAB switches module` case's `StateError: No element` after choosing `perron_tree`: the existing fixture assumes the randomly selected module declares `colorScheme` and calls `firstWhere` without a fallback. Its one isolated rerun passed, and the final complete selected union above passed. This is unrelated flaky coverage, not a passing receipt for the earlier run. Independent read-only source review found no critical/important issue; it did not execute the checks.

## Documentation scope and remaining qualification

Scoped Docs Sync Maintain adds only this evidence owner. The shared PRD/spec/test-plan and coordinator task/history records are unchanged. The accepted sampler defaults and every original acceptance check remain in force. The shared documentation's eventual integration/status reconciliation belongs to DOCS-MAINTAINER, not this worker.

Still pending live: actual Android/web/Linux production-renderer visual composition, physical-device screen readers and keyboard/focus behavior, and real save/share destinations. Binary camera PNGs, widget semantics and decoded test GIFs do not qualify GPU appearance, bundled production typography, platform storage or aesthetic quality. No release, remote publication or full offline integration-gate result is claimed.
