# MAIN-VIEWER-LABELED-TOOLS-REPAIR-01

## Evidence and boundary

Main's offline check is red at `393c45ac957550b08de291104b877f7c56423414`;
last green is `ebb178c23f8eaf20b4d2cb870190d57220dd2d6e`.
The sole reported commit since green is `393c45ac feat(viewer): add
Canva-inspired labeled tool buttons`; current checkout `d05b7822` merges it.
Read the retained bundle **in place**, never copy it into a checkout or commit:

`/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/main-evidence/393c45ac957550b08de291104b877f7c56423414`

All five files were inspected: `main_check.json`, relevant failure and terminal
sections of `main-check.log`, `main-check.exit`, `main-check-reruns.log`,
and `flaky_history.json`. Metadata: red / TEST_FAILURE, 42 failures,
flaky=[], repair_pending=[]; exit 1; reruns log empty; flaky history {}.
Log line 49 reports clean analysis; line 16305 ends +3425 ~9 -42,
Some tests failed. Python/Bats were not reached in the chained check.
There is no isolated passing-rerun or three-revision flakiness evidence.
This is a main-red repair, not a tool-crash or established flaky-test task.

The commit changes exactly:
- `lib/features/viewer/chrome/fractal_view_controls.dart`
- `lib/features/viewer/fractal_viewer_screen.dart`
- `test/fractal/fractal_view_controls_test.dart`

The controls now paint captions and a surfaced rounded toolbar, raise its maximum
width from 440 to 720, and change cell sizing/wrapping. Viewer chrome height
estimation also changed. Existing sibling tests still assert an icon-only,
transparent rail, while other failures expose geometry/reachability obligations
that must not be weakened. No open repair covers these failures: the only open
task at inspection is the unrelated `ACAD-013-4142ef42`. Closed repair records
remain closed. No worker report exists for this new task.

## Failure inventory (names at the checked revision)

### `test/fractal/viewer_mobile_toolbar_test.dart` (3)

- `primary controls are icon-only and compact above system navigation`
- `large targets keep circular actions balanced inside a narrow phone`
- `primary icon cells fill their full hit regions`

### `test/fractal/viewer_responsive_controls_test.dart` (8)

- `short real viewer HUD en scale=3.0 large=false`
- `short real viewer HUD en scale=3.0 large=true`
- `short real viewer HUD es scale=3.0 large=false`
- `short real viewer HUD es scale=3.0 large=true`
- `HUD Size(320.0, 200.0) and header reserve left gesture only`
- `HUD Size(320.0, 200.0) and header reserve left consumed padding`
- `HUD Size(320.0, 200.0) and header reserve right gesture only`
- `HUD Size(320.0, 200.0) and header reserve right consumed padding`

### `test/fractal/viewer_toolbar_layout_test.dart` (29)

- `whole primary labels en Size(320.0, 780.0) x1.0`
- `whole primary labels en Size(320.0, 780.0) x2.0`
- `whole primary labels en Size(320.0, 780.0) x3.0`
- `whole primary labels en Size(360.0, 780.0) x1.0`
- `whole primary labels en Size(360.0, 780.0) x2.0`
- `whole primary labels en Size(360.0, 780.0) x3.0`
- `whole primary labels en Size(390.0, 780.0) x1.0`
- `whole primary labels en Size(390.0, 780.0) x2.0`
- `whole primary labels en Size(390.0, 780.0) x3.0`
- `whole primary labels en Size(640.0, 240.0) x1.0`
- `whole primary labels es Size(320.0, 780.0) x1.0`
- `whole primary labels es Size(320.0, 780.0) x2.0`
- `whole primary labels es Size(320.0, 780.0) x3.0`
- `whole primary labels es Size(360.0, 780.0) x1.0`
- `whole primary labels es Size(360.0, 780.0) x2.0`
- `whole primary labels es Size(360.0, 780.0) x3.0`
- `whole primary labels es Size(390.0, 780.0) x1.0`
- `whole primary labels es Size(390.0, 780.0) x2.0`
- `whole primary labels es Size(390.0, 780.0) x3.0`
- `whole primary labels es Size(640.0, 240.0) x1.0`
- `adaptive labeled primaries Size(1200.0, 400.0) large=false en scale=1.0`
- `adaptive labeled primaries Size(1200.0, 400.0) large=false en scale=3.0`
- `adaptive labeled primaries Size(1200.0, 400.0) large=false es scale=1.0`
- `adaptive labeled primaries Size(1200.0, 400.0) large=false es scale=3.0`
- `adaptive labeled primaries Size(1200.0, 400.0) large=true en scale=1.0`
- `adaptive labeled primaries Size(1200.0, 400.0) large=true en scale=3.0`
- `adaptive labeled primaries Size(1200.0, 400.0) large=true es scale=1.0`
- `adaptive labeled primaries Size(1200.0, 400.0) large=true es scale=3.0`
- `visual, tab and semantic order follow visible primary groups`

### `test/fractal/palette_picker_test.dart` (2)

- `palette picker short landscape retains final palette and close (en)`
- `palette picker short landscape retains final palette and close (es)`

## Source-supported execution

1. Reproduce the four failing modules on the execution revision after the pinned
   offline preflight. Retain exact names above as evidence even if tests are renamed.
   Read the changed implementation and sibling regression tests before editing.
2. Separate obsolete presentation pins from behavioral failures. Log 11375+
   finds painted Play where none was expected; 11407+ expects transparent but
   gets an opaque surface; 12750+ expects <=440 but gets 720. Reconcile these
   presentation assertions with the landed labeled-tool implementation, not with
   a new visual preference. Preserve coverage through concrete caption, surface,
   sizing and interaction assertions rather than deleting tests.
3. Diagnose real geometry and fixture issues: short real-viewer cases report
   bottom 176 > safe bottom 152 (11525+ and 11873+); some toolbar cases exceed
   safe bounds (12156+); visual-order test compares left 766 against >=770
   (12964+). Repair production geometry only for a reproduced defect, or fix a
   fixture measuring painted child bounds instead of actual layout cells when
   source evidence demonstrates that distinction. Keep non-overlap and visual,
   keyboard and semantic reading-order guarantees.
4. Both short-landscape palette cases fail before opening the picker:
   `viewerPaletteButton` is not hit-testable at helper line 100 (13101–13164).
   The helper scrolls only when the palette key is absent, not when present but
   offscreen. Investigate actual rail scrolling and viewport reservation before
   choosing a fixture-reveal or geometry fix. Preserve final palette selection,
   visible full label, close action, 48/56px targets, EN/ES and 3x high-contrast
   coverage; do not bypass pointer interaction with direct callbacks.
5. Retain quick/long-press callbacks, export locking, localized tooltip/semantics,
   target sizes, system padding/gesture insets, keyboard activation/focus and
   existing viewport/text-scale matrices. Investigate fixture isolation, resource
   load and timing if reproduction varies; no arbitrary sleeps, assertion
   weakening, skips or speculative shader/product repair.
6. Run the focused union including `fractal_view_controls_test.dart`, then the
   unchanged full offline check. Record exact source, commands, repetitions,
   exits and lockfile hashes here. No coordinator receipt is needed. Missing
   tooling and failed checks stay failures; device/browser/release and goal
   qualification remain separate.

## Verification setup

Use current `AGENTS.md#common-offline-integration-gate` and
`fdroid/flutter.version` (Flutter 3.47.9 / Dart 3.13.7), not the historical
3.44.6 example in `docs/tasks/MAIN-CHECK-01.md`. In a subshell set
`FLUTTER_ROOT="$AUTOWORK_CACHE/flutter-3.47.9"` and
`PUB_CACHE="$AUTOWORK_CACHE/pub-cache"`, then
`PATH="$FLUTTER_ROOT/bin:/usr/bin:$PATH"`.
Compare `flutter --version` to the pin; revalidate the provisioned interpreter:

```sh
/usr/bin/python3 -c 'import sys, pytest, jinja2, markupsafe; print(sys.executable, sys.version, pytest.__version__, jinja2.__version__); assert callable(markupsafe.soft_str)'
```

Preserve and hash `pubspec.lock` before and after the full check:

```sh
flutter pub get --offline --enforce-lockfile && flutter analyze --no-pub && flutter test --no-pub && /usr/bin/python3 -m pytest test/research test/scripts -q && bats test/scripts/*.bats
```

Maintainer executable app checks: **NOT_RUN** (documentation-only repair).
Task-store validation and diff checks are separate from a passing application gate.
