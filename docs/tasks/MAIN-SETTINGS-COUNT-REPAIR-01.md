# MAIN-SETTINGS-COUNT-REPAIR-01 — stale About-dialog fractal count

## Evidence and classification

MAIN reports **red / TEST_FAILURE** on checked revision
`4089eccfea23d28593737c2bf280fa6f16fbac28`; the last recorded green is
`2a4363cbb08e55f0be31fe8665a3ff2fa8de29cd`. The bundle was read in place, not
copied or changed:
`/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/main-evidence/4089eccfea23d28593737c2bf280fa6f16fbac28/`.

- `main_check.json` reports `state=red`, `result_class=TEST_FAILURE`, one failure
  (`test/screens/settings_screen_a11y_test.dart: SettingsScreen content shows the
  real app version, not a stale literal`) and three commits since green
  (`4089eccf refactor(catalog): split escape_time_catalog parts into families and
  research_batches`; `08d27a52 Merge commit '3d7579d7…'`; `3d7579d7
  feat(catalog): add batch 30 high-impact visuals and research evidence`).
- `main-check.log:286-309`: the case at line 215 expects
  `find.textContaining('1025 production fractals')` to find one widget and finds
  `0` (`Found 0 widgets with text containing 1025 production fractals`), marking
  only that case `[E]`.
- `main-check.log:1297`: the app renders the current catalog badge as
  `label: "1029 fractals"`; the About blurb comes from the same regenerated
  localization source (`lib/l10n/app_en.arb`).
- `main-check.log:53`: `flutter analyze --no-pub` printed `No issues found!`.
  `main-check.exit` is `1`; the chained Flutter test stage then failed, so the
  later Python and Bats families were not reached and no result for those
  families is inferred.
- `main-check-reruns.log` is empty; `flaky_history.json` is `{}` and metadata has
  `flaky=[]`. No isolated reruns or three-revision flake classification was
  supplied, so this is a red gate, not a recorded flake.

## Source-supported investigation

`test/screens/settings_screen_a11y_test.dart:204-218` is the only stale carrier.
Its About-dialog case hardcodes `1025 production fractals` while
`lib/features/settings/settings_screen.dart:250-251` renders
`l10n.settingsAboutBlurb` from the generated localizations, which are rebuilt
from `lib/l10n/app_en.arb`.

Commit `3d7579d7` (batch 30) changed the count from 1025 to 1029 in
`lib/l10n/app_en.arb`, `lib/l10n/app_es.arb`, `README.md`,
`test/modules/readme_catalog_claims_test.dart` (and the landing/store copy), but
did not update this test's literal and did not regenerate the tracked
`lib/l10n/app_localizations*.dart` output (still 1025 at that commit). The
gate's pinned build regenerates those localizations from the arb, so the About
dialog rendered 1029 while the test still expected 1025. The later `4089eccf`
catalog split did not change the count. `test/modules/readme_catalog_claims_test.dart:14-27` already
derives the count from `ModuleRegistry().modules`, excluding
`shaders/diagnostic/` assets and `hydrogen_orbital`, and asserts 1029; the
registry, `app_en.arb`, `README.md` and that claims test agree. Only
`test/screens/settings_screen_a11y_test.dart:215` remains at 1025, so this is a
stale test defect, not a product, registry or localization defect.

## Repair plan

Repair only the test assertion. Prefer deriving the expected count from
`ModuleRegistry` with the same production filter used by
`test/modules/readme_catalog_claims_test.dart`, so the assertion tracks the real
catalog and cannot go stale again; updating the literal to the registry-derived
1029 is acceptable when it keeps the assertion meaningful. Either way, keep the
`Version $kAppVersion` subtitle checks, the `Source code` and GitHub-link
assertions, and every other case and locale in the file unchanged. Do not edit
the arb, registry or README source. The generated
`lib/l10n/app_localizations*.dart` files are build output: let the pinned build
refresh them from the arb and commit only if that keeps the delivered tree
self-consistent; never hand-edit them.

## Existing task reconciliation

No open task covers this failure. `MAIN-CHECK-01`,
`MAIN-CONTROLS-HUD-REPAIR-01`, `MAIN-MILNOR-REPAIR-01`, `MAIN-RANDOM-FAB-01` and
`MAIN-LOGGER-REPAIR-01` are coordinator-closed and address different failures.
The only other open task, `ACAD-013-4142ef42`, is unrelated Waydroid device work.
`NUM-WALL-02` (done) declared this test in its Touches for the earlier catalog
count work but its delivered result left the 1025 literal; that history is
evidence, not an open contract.

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
| `flutter test --no-pub test/screens/settings_screen_a11y_test.dart --reporter expanded`, repeated, plus `--plain-name 'shows the real app version, not a stale literal'`; `flutter test --no-pub test/modules/readme_catalog_claims_test.dart --reporter expanded` | Failing-before and passing-after commands, repetitions and exits, with the registry-derived count agreeing. |
| `flutter pub get --offline --enforce-lockfile && flutter analyze --no-pub && flutter test --no-pub && /usr/bin/python3 -m pytest test/research test/scripts -q && bats test/scripts/*.bats` | Complete unchanged gate on delivered bytes, `pubspec.lock` SHA-256 before/after, `git diff --check`. If a stage fails, retain it and diagnose the remaining families separately. |

This document and the task record are a bounded repair contract, not a passing
suite result. The complete unchanged offline gate is **NOT_RUN by this worker**;
the execution instructions reserve it for the coordinator on the merged tree.
The original red gate above remains a failure and focused passes do not establish
a green full gate; no goal, device, production or live qualification is claimed.

## Delivered evidence

The test assertion now derives the production count from `ModuleRegistry` with
the same filter as `test/modules/readme_catalog_claims_test.dart` (exclude
`shaders/diagnostic/` and `hydrogen_orbital`). The pinned offline `pub get`
refreshed the tracked generated localizations from the arb (1025 → 1029) without
hand edits; `pubspec.lock` SHA-256 was unchanged
(`22b29dbd8f71276012a54b9bdc62ba88408f967a86b34075986c17e1c4506ec3`).

- Before: `flutter test --no-pub test/screens/settings_screen_a11y_test.dart
  --reporter expanded` exited 1; `SettingsScreen content shows the real app
  version, not a stale literal` found 0 widgets for `1025 production fractals`
  (`test/screens/settings_screen_a11y_test.dart:215`).
- After: the same file exited 0 with `+20: All tests passed!`, and the isolated
  case (`--plain-name 'shows the real app version, not a stale literal'`) passed
  three consecutive runs (exit 0 each).
- `flutter test --no-pub test/modules/readme_catalog_claims_test.dart --reporter
  expanded` exited 0 (`+4: All tests passed!`), confirming registry-derived 1029.
- `flutter analyze --no-pub` reported `No issues found!`; `dart format` and
  `git diff --check` passed.
