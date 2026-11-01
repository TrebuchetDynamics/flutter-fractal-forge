# MAIN-CONTROLS-PRESENTATION-HARDEN-01 — CWD-relative package-config fixture

## Evidence and classification

MAIN reports **red / TEST_FAILURE** on checked revision
`78df85b885446918321a6475c0c97a43fa3db9c8`; the last recorded green is
`a7a28c6950b3c2070a627aa81f0216d2ea7c58f7`. The bundle was read in place, not
copied or changed:
`/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/main-evidence/78df85b885446918321a6475c0c97a43fa3db9c8/`.

- `main_check.json`: `state=red`, `result_class=TEST_FAILURE`, one failure
  (`test/fractal/controls_presentation_test.dart: (setUpAll)`), the single commit
  since green (`78df85b8 chore(release): prepare 1.1.118`), `flaky=[]`,
  `flaky_history={}`, `repair_pending=[]`; `main-check.exit` is `1`;
  `main-check-reruns.log` is empty.
- `main-check.log:11730-11736`: the file loads, then `(setUpAll) [E]`
  `PathNotFoundException: Cannot open file, path =
  '…/.worktrees/pi-scratch-main-check-sn253lpb/.dart_tool/package_config.json'
  (OS Error: No such file or directory, errno = 2)`, thrown from
  `_File.readAsStringSync` at
  `test/fractal/controls_presentation_test.dart:23:31`. The result counter drops
  to `-1` and every case in the file is skipped; the terminal log lists only this
  file under `Failing tests`.
- The surrounding tests keep passing (`+3030 ~8` before the file, `+3031 ~8 -1`
  after `fractal_controls_comprehensive_test.dart`), so the config was present
  when the tool started and the whole suite compiled and ran; it was gone only at
  this file's runtime read.
- The only commit since green changes
  `fastlane/metadata/android/en-US/changelogs/118.txt` and
  `fdroid/version.properties`; the test bytes are unchanged from the four green
  full runs (`0385a1a4db11e2c15b65aeab12eb0e6cf45ac280`,
  `0b53d8e37f37fb20aaefed70b23fcb0eba8ee35f`,
  `b90f0576072695b9b3400b55f7b2c4b56f3c061d`,
  `a7a28c6950b3c2070a627aa81f0216d2ea7c58f7`), each of which logs the `setUpAll`
  and all 18 cases passing. The maintainer's isolated run on `78df85b8` with
  pinned Flutter 3.44.6 produced 18 passed, so the red result is an
  intermittent/environmental fixture failure, not committed product code.

## Source-supported investigation

The fragile element is a *runtime, CWD-relative read of a generated file*.
`test/fractal/controls_presentation_test.dart:21-27` did
`File('.dart_tool/package_config.json').absolute`, parsed it with `jsonDecode` and
derived the SDK material-font path from the `flutter` package root. No other test
in the suite reads `.dart_tool`; this was the only such dependency.

- `flutter` changes its own process working directory to the project root
  (`flutter_tools` `flutter_command.dart`, when the pubspec is in an ancestor) and
  starts `flutter_tester` without an explicit `workingDirectory`
  (`flutter_tester_device.dart`), so the test process inherits that project root.
  Running `flutter test` from `test/` therefore does not exercise "CWD without the
  config": the process CWD is still the checkout root.
- Renaming the project `.dart_tool/package_config.json` away *before* the tool
  starts does not reach the test: the pinned Flutter 3.44.6 fails earlier in
  `testCompilerBuildNativeAssets` with `Bad state: No element`
  (`native_assets.dart:37`), because the native-assets builder looks the project
  package up in that config. This was reconfirmed here: three unrelated widget
  tests each abort with that `tool_crash` when the config is absent before the
  run, and each passes in isolation once `flutter pub get` restores it
  (`test/app/deferred_startup_app_test.dart`, 2 passed;
  `test/screens/navigation_flow_widget_test.dart`, 8 passed;
  `test/screens/debug_mode_test.dart`, 5 passed). The red run itself compiled and
  ran 3,369 tests, so the config existed at tool start and disappeared while the
  suite was running.
- `Isolate.resolvePackageUri` (the suggested example) is **not** usable here: in
  `flutter_tester` both `Isolate.resolvePackageUri` and
  `Isolate.resolvePackageUriSync` throw
  `Unsupported operation: Isolate.resolvePackageUriSync`. This was checked
  directly with a throwaway probe test.
- Two stable mechanisms resolve the SDK font without the generated file:
  `Platform.environment['FLUTTER_ROOT']`, exported by the `flutter` launcher
  (`bin/internal/shared.sh`) and inherited by the test process, or the
  `flutter_tester` executable location
  (`<sdk>/bin/cache/artifacts/engine/<os>/flutter_tester`), whose
  `parent.parent.parent` is `<sdk>/bin/cache/artifacts`. Both were confirmed to
  contain `material_fonts/Roboto-Regular.ttf` under the pinned SDK. The fix uses
  `FLUTTER_ROOT` first and falls back to the executable layout.

## Repair

Replace only the fixture lookup. `_resolveSdkRobotoFont()` builds an ordered list
of candidate `File`s (`FLUTTER_ROOT` then the `flutter_tester` layout), returns the
first one that exists, and throws a descriptive `StateError` if none does. The
now-unused `dart:convert` import is dropped. Every case, locale (en/es), width
(320/360/390px), scale (1.0x/2.0x/3.0x), assertion and the
`AppTypography.bodyFont` `FontLoader` call are unchanged; no case is skipped and
nothing is weakened. No product, shader, catalog, registry, localization,
dependency or SDK source is touched. The `fastlane`/`fdroid` Touches are
provenance only and were not edited.

Delivered Dart file: Git blob `d268cdbc99a8df36691f49a5939a334bf48b4d70`,
SHA-256 `69bb4af216a68b20712cbcdbb927fb6de82c6d6781cf224a2517c6e5c82ea990`.

## Verification boundary

Worker checks use MAIN-CHECK-01's process-local invocation and the common offline
gate. From the execution checkout root:

```sh
export FLUTTER_ROOT="$AUTOWORK_CACHE/flutter-3.44.6"
export PUB_CACHE="$AUTOWORK_CACHE/pub-cache"
export PATH="$FLUTTER_ROOT/bin:/usr/bin:$PATH"
```

(These exports are scoped to command subshells, not the host/profile.)

The complete unchanged offline gate on the delivered tree is reserved for the
coordinator runner and is **NOT_RUN by this worker**; the execution instructions
reserve it for the merged tree. A focused pass is not full-gate qualification,
and no goal, device, release or live qualification is claimed. The historical red
bundle above remains a failure; these focused results do not relabel it green.

## Delivered evidence

Pinned Flutter 3.44.6 / Dart 3.12.2 (matches `fdroid/flutter.version`); the
`flutter` launcher's `FLUTTER_ROOT` points at
`$AUTOWORK_CACHE/flutter-3.44.6`; `/usr/bin/python3` 3.12.3 with pytest 9.0.2,
Jinja2 3.1.6 and callable `markupsafe.soft_str`. The offline lockfile-enforced
preflight `flutter pub get --offline --enforce-lockfile` exited `0` and left
`pubspec.lock` SHA-256 unchanged before and after:
`22b29dbd8f71276012a54b9bdc62ba88408f967a86b34075986c17e1c4506ec3`.

- After fix, checkout root, five consecutive
  `flutter test --no-pub test/fractal/controls_presentation_test.dart --reporter expanded`
  runs: exit `0` each, 18 `SDK Roboto reset geometry and callbacks` cases each,
  ending `+18: All tests passed!`.
- After fix, `flutter test --no-pub fractal/controls_presentation_test.dart` from
  `test/` (a CWD with no `.dart_tool/package_config.json`): exit `0`, 18 cases.
- Before/after reproduction of the red signature with a same-file probe: a copy of
  the test that deletes `.dart_tool/package_config.json` in the first registered
  `setUpAll` (config present at compile, absent at the fixture read).
  - Baseline `f3929fd8` bytes: exit `1`,
    `PathNotFoundException: Cannot open file, path =
    '<scratch>/.dart_tool/package_config.json' (OS Error: No such file or
    directory, errno = 2)` from `readAsStringSync`, `+0 -1`, `Some tests failed.`
    — the red bundle's exact failure class with zero cases run.
  - Delivered bytes: the identical probe scenario exits `0` with
    `+18: All tests passed!`.
- After fix, cross-file scenario `flutter test --no-pub --concurrency=1
  <delete-config probe> controls_presentation_test.dart --reporter expanded`:
  the probe deletes the config during the run and the controls file still runs all
  18 cases (`+19: All tests passed!`).
- `flutter analyze --no-pub test/fractal/controls_presentation_test.dart`:
  `No issues found!`; `dart format` changed nothing; `git diff --check` clean.

The scratch baseline worktree and probe files used above were removed; nothing
under `.worktrees` or `$TMPDIR` is part of the delivered commit.
