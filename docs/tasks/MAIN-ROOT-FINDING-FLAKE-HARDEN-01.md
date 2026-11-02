# MAIN-ROOT-FINDING-FLAKE-HARDEN-01

## Failure

Main check at revision `96c7f3afc50a63648b96b1f634bcb9a6067a9e34` reported:

`test/modules/root_finding_formula_test.dart: repaired shaders still compile and render schroeder compiles and draws a non-blank frame`

The bundle
`/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/main-evidence/96c7f3afc50a63648b96b1f634bcb9a6067a9e34`
records `state=red`, `result_class=TEST_FAILURE`, `main-check.exit=1`, an empty
`main-check-reruns.log` and `flaky_history.json={}`. `main-check.log` line 880
reports the case at `02:28` with `Expected: a value greater than <48>` and
`Actual: <0>`, reason `schroeder rendered a black frame`, thrown at
`test/modules/root_finding_formula_test.dart:34:9`. The same file's other four
staged cases (`jarratt`, `schroeder_z5`, `schroeder_z6`,
`ostrowski_squared_16`) passed in that run.

## Diagnosis

The failure is a flaky software-rasterizer frame drop, not a product defect.

- The test bytes and `shaders/root_finding/` are byte-identical between the last
  green revision `0ad2a60ced54a55b4582f4701d261e06b1198eb2` and the red revision
  `96c7f3af`. `git diff --name-only 0ad2a60c 96c7f3af -- test/modules/root_finding_formula_test.dart shaders/root_finding/`
  is empty; the red commits change only controls/HUD declarations, geometry,
  deleted sheet tests, an ADR and a diagram.
- The green bundle at `0ad2a60c` records `state=green`, `main-check.exit=0`; its
  `main-check.log` lines 877-886 show all five staged cases pass in a full run.
- Maintainer isolated reruns all passed: `96c7f3af` 3/3, `0ad2a60c` 3/3 and
  `dacca57b` 3/3, each after the offline lockfile-enforced preflight, every run
  ending `All tests passed!`. A case that fails only in the full run and passes
  alone on three revisions is flaky.
- A local probe of the unchanged readback observed the drop directly. The staged
  render is all-or-nothing: a good frame lit all `2304` pixels (`48x48`) and a
  dropped frame returned exactly `0`. There is no intermediate count, so zero lit
  pixels is never a real result for these shaders.
- The single immediate retry the old fixture used failed when two frames dropped
  back to back. A `pub get`-then-`flutter test` probe running the same shader in
  isolation recorded 5 of 300 trials needing one retry and 0 failures across 6
  attempts, confirming a bounded retry recovers a transient drop.

Prior partial work: commit `7eeeb752` (`refactor(catalog): merge the multibrot
power family into one shader`) removed `schroeder` from the smoke list entirely
and commented that "a flaky check is worse than none". That trades away coverage;
this task restores the case and hardens the fixture instead.

## Change

`test/modules/root_finding_formula_test.dart`:

- Restores `'schroeder'` to the `repaired shaders still compile and render` list,
  so all five staged cases and every shader-text pin run again.
- Replaces the single immediate retry with `_litPixelsWithRetry`, a bounded retry
  of at most six attempts with a short growing backoff (`20ms * attempt`, at most
  `300ms` total). It returns the first frame above the threshold and otherwise
  returns the last count.
- Hoists the `48` threshold to `const _minLitPixels = 48`, used both by the retry
  guard and by the unchanged `greaterThan(48)` assertion. The lit-pixel
  assertion, the shader-text pins and the test set are otherwise untouched.

No product, shader, catalog, registry or localization code changes.

## Verification

Worker baseline `0e83dffab9ec3c7a3b7368e722b5604ea5e6c35e`. Setup used the
pinned `FLUTTER_ROOT="$AUTOWORK_CACHE/flutter-3.44.6"`,
`PUB_CACHE="$AUTOWORK_CACHE/pub-cache"` and
`PATH="$FLUTTER_ROOT/bin:/usr/bin:$PATH"` in a subshell, matching
[MAIN-CHECK-01](MAIN-CHECK-01.md). `flutter --version` reported Flutter 3.44.6 /
Dart 3.12.2, matching `fdroid/flutter.version`; `/usr/bin/python3` resolved
pytest 9.0.2, Jinja2 3.1.6 and callable `markupsafe.soft_str`.

- Offline lockfile preflight `flutter pub get --offline --enforce-lockfile` →
  exit 0.
- Focused `flutter test --no-pub test/modules/root_finding_formula_test.dart --reporter expanded`
  run five times in isolation → 5/5 exit 0, `+19` each run, no skips, including
  `schroeder compiles and draws a non-blank frame`.
- Full `flutter test --no-pub` (via `autowork-run`) → exit 0, `+3460 ~9`,
  `All tests passed!`. `test/modules/root_finding_formula_test.dart` loaded at
  `02:20` and all five staged cases, including `schroeder`, passed at `02:21`.
- `git diff --check` → clean. The added lines follow the file's existing short
  style; the installed Dart 3.12.2 formatter uses the tall style and would
  reformat the whole legacy-styled file, so no repository-wide reformat was
  applied. `flutter analyze --no-pub` covers the changed Dart.
- `pubspec.lock` SHA-256 before and after the worker checks:
  `22b29dbd8f71276012a54b9bdc62ba88408f967a86b34075986c17e1c4506ec3`
  (unchanged).

### Test count reconciliation

The task text says "keep all 20 tests". The green bundle's full-run log records
19 test cases for this file (5 staged + 14 formula pins), and the delivered file
has 19. The "20" overcounts the evidence by one; every case that exists and the
restored `schroeder` case is preserved. No case was added, skipped or deleted.

## Verification limit

This is a test-fixture hardening record. The full combined offline gate
(`flutter pub get` / `analyze` / `flutter test` / `pytest` / `bats`) remains the
coordinator runner's merged-tree run, not this worker's. An isolated pass is not
full-gate qualification; missing tooling, skips and failures remain explicit. No
goal, device, release or live qualification is inferred.
