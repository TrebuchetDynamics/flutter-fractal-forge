# MAIN-CONTROLS-HUD-REPAIR-01 — Compact controls-panel HUD accessibility repair

## Evidence and classification

MAIN reports **red / TEST_FAILURE** at checked revision
`b291b15f3d846457e10933d5f9346dd6264d3664`; the last recorded green is
`3b2f09b8f3cdfe7007ddefd1a0b7c1e8789bc630`. The bundle was read in place, not
copied or changed:
`/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/main-evidence/b291b15f3d846457e10933d5f9346dd6264d3664/`.

- `main_check.json` reports `state=red`, `result_class=TEST_FAILURE`,
  `red_since=b291b15f3d846457e10933d5f9346dd6264d3664`, six failures — all in
  `test/fractal/fractal_controls_hud_accessibility_test.dart` — and one commit
  since green (`b291b15f feat(viewer): compact the controls panel and add
  transparent background`). `flaky=[]` and `flaky_history={}`.
- `main-check.log:11691-11878` records the six named cases:
  `live HUD keyboard reveals palettes and operates switches`,
  `live HUD preserves palette and extra-enum option subsets`, and the four
  `Ahem live HUD keeps 48px actions at 320px/{2.0x,3.0x} ({en,es})` cases.
  - The keyboard case throws `Bad state: No element` at test line 43 while
    evaluating `find.byType(ChoiceChip).last` (stack `_LastFinderMixin.filter`
    at `package:flutter_test/src/finders.dart:1410`).
  - The option-subset case reports `Actual: MappedIterable<ChoiceChip,
    String?>:[]` and `has too few elements (0 < 64)` at test line 82.
  - Each Ahem case reports `Found 0 widgets ... ancestors of widgets with text
    "Fire"` (`en`) or `"Fuego"` (`es`) at test line 157.
- `main-check.log:53` records clean analysis (`No issues found!`);
  `main-check.log:14931-14937` ends `Some tests failed.` with the six names and
  `... and 2 more`; `main-check.exit` is `1`. The chained Python and Bats
  families were not reached, so no result for them is inferred.
- `main-check-reruns.log` is empty; `flaky_history.json` is `{}`. No isolated
  reruns or three-revision flake classification was supplied, so this is a red
  gate, not a recorded flake.

## Diagnosis

Commit `b291b15f` deliberately compacts the controls HUD
(`lib/features/viewer/chrome/fractal_controls_hud.dart`): it removes the
`_CompactColorSchemeRow` palette chip row and the fluid-mode toggle plus its
intensity slider, and adds a **Transparent background** toggle. Its message says
palette selection already lives in the viewer tools and that it updated
`test/fractal/fractal_controls_hud_test.dart`, the semantics audit
(`test/a11y/semantics/interactive_name_audit_test.dart`), the mobile layout
regression (`test/fractal/viewer_mobile_hud_layout_test.dart`) and the Spanish
coverage.

`test/fractal/fractal_controls_hud_accessibility_test.dart` was **not** updated,
so it still probes a palette that the HUD no longer renders:

- line 43 probes `find.byType(ChoiceChip).last` — zero palette chips now exist,
  hence `Bad state: No element`;
- line 82 asserts the HUD's `ChoiceChip` labels equal the palette plus
  extra-enum options — only extra enums remain;
- line 157 asserts the palette label (`Fire`/`Fuego`) has a chip ancestor for the
  48px touch-target check.

The six failures are therefore an unmigrated accessibility test, not a shader,
rendering, localization or controller defect. The extra-enumeration chips are
still built by `_buildExtraParamControl` (`fractal_controls_hud.dart:327-364`),
the effect toggles still render (`:213-223`) and palette accessibility coverage
already exists at its new owner,
`test/fractal/palette_picker_test.dart` (48px targets at lines 277-278, plus
full-label, landscape and text-scale cases).

## Repair options and boundary

The evidence-backed resolution is to reconcile the HUD accessibility test with
the shipped compact panel: keep always-run keyboard Tab/Enter reachability for
the toggles and reset actions that remain, keep 48dp (56dp with large targets)
touch targets at 320px width with 2.0x and 3.0x Ahem text scale in `en` and `es`
without overflow or framework exceptions, keep the extra-enum chips asserted in
the HUD, and keep palette accessibility coverage at the viewer-tools palette
picker rather than deleting it. No assertion may be relaxed merely to pass.

Only if the worker reproduces an unintentional loss of keyboard or touch access
(for example the transparent-background or kaleidoscope toggle is no longer
Tab-reachable or below 48dp) may the HUD — and localization only where required —
be repaired so the original guarantees hold. That is not a new product decision;
the compact panel shipped in `b291b15f` and its sibling tests are the intended
behavior.

## Existing task reconciliation

No open task covers these failures. The only open task is
`ACAD-013-4142ef42` (unrelated Waydroid device work). `MAIN-CHECK-01`,
`MAIN-MILNOR-REPAIR-01`, `MAIN-RANDOM-FAB-01` and `MAIN-LOGGER-REPAIR-01` are
coordinator-closed and address different failures. This task is a bounded
accessibility-test reconciliation contract, not a passing suite result.

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
| `flutter test --no-pub test/fractal/fractal_controls_hud_accessibility_test.dart --reporter expanded`, repeated in isolation and by the six `--plain-name` cases | Failing-before and passing-after commands, repetitions, exits and the six test names. |
| Required full check: `flutter pub get --offline --enforce-lockfile && flutter analyze --no-pub && flutter test --no-pub && /usr/bin/python3 -m pytest test/research test/scripts -q && bats test/scripts/*.bats` | Complete unchanged gate on delivered bytes, `pubspec.lock` SHA-256 before/after, `git diff --check`. If a stage fails, retain it and diagnose the remaining families separately; never relabel the combined gate green. |

No device, browser, hardware, release or production acceptance is inferred or
required to complete this local accessibility-test repair.
