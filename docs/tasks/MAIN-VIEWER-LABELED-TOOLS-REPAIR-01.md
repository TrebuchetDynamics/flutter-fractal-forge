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

## Retry execution evidence (2026-11-06)

Execution baseline: `9ae7366f6569fc9980749a26a6bcbabd38e4006a`, branch
`autowork/MAIN-VIEWER-LABELED-TOOLS-REPAIR-01-r2`. The `d05b7822` reference above
is the historical discovery checkout, not this execution source. The original
42-failure bundle above was read in place, including metadata, exit, empty
rerun log, flaky history and failure/terminal log sections. No bundle was copied.

### Diagnosis and bounded repair

The baseline already includes `156bf7fd`'s short-screen caption fallback,
word-aware cell sizing, random-action captions and dismissible editing hint.
The historical 8 responsive failures and 29 toolbar failures no longer reproduce
on this source. All 63 responsive cases pass unchanged. No new production
geometry fix is justified by this reproduction.

The before run uses the five-module command below **plus**
`test/a11y/screens/viewer_screen_a11y_test.dart`, before `--reporter expanded`.
It exits 1 with **224 passed, 3 failed**:

- Both original short-landscape palette cases still fail at the hit-testability
  assertion before opening the picker. The helper reveals the palette only if
  its key is absent. `FractalViewControls` eagerly builds all wrapped rows inside
  `SingleChildScrollView`; a present cell can be offscreen. Reveal the actual
  palette cell unconditionally before asserting hit testing and long-pressing it.
  At EN/ES, 3x high contrast, retain the whole final label inside the scroll
  viewport, select palette 63 through that visible label, then reveal and tap
  Close. No production callback is invoked directly. All other picker cases stay.
- The retry's reported accessibility failure also reproduces on the baseline:
  `FractalViewerScreen accessibility every control is named exactly once` expects
  7 operable names but sees 8, including the shipped `Dismiss tip` button.
  `_RandomActionHint` owns a real `AppToolButton` with that localized name and
  focus order 7. Include it in the explicit toolbar inventory and require its
  presence. Use the common `AppToolButton` base type for callback inspection,
  because the hint is not the compatibility `FloatingActionButtonWidget`
  subclass. Keep exactly one name per action, the exact total, and the existing
  unnamed-control, stacked-stop and slider assertions. Do not hide the tip or
  discard its semantics to satisfy the old count.

Reuse the inspected earlier candidate `d204a7d8769525a343351395d8de17d6886207e4`'s
relevant test corrections, not its historical verification claims:

- Extend the existing mobile cases to check all seven captions, 2/2/2/1 wrapping,
  the stricter safe bottom (716), 4px cell margins, 12px rounded cells, content
  within the actual input cell, and the surfaced/elevated 20px-rounded rail.
- Extend the existing EN/ES 1x/2x/3x label matrix to reveal each actual cell before
  measuring its safe bounds and hit testing. Check each caption's paragraph and
  full bounds inside its cell; retain the short-screen fallback, callbacks and
  long-press assertions. Pin the desktop fixture to its shipped 720px maximum.
- Snapshot input-cell rectangles in one frame before checking reading order and
  traversing with Tab. Focus reveal can scroll the enclosing viewport. Comparing
  pre-scroll and post-scroll coordinates caused the historical 770/766 mismatch.
  Retain the original order/non-overlap tolerances, semantic sort keys and every
  Tab-focus assertion. No production reorder is needed.

Original-to-final name mapping (all other original inventory names stay unchanged):

| Original mobile test | Final mobile test |
| --- | --- |
| primary controls are icon-only and compact above system navigation | primary controls are labeled and wrap above system navigation |
| large targets keep circular actions balanced inside a narrow phone | large targets keep labeled actions balanced inside a narrow phone |
| primary icon cells fill their full hit regions | primary labeled cells keep their paint inside full hit regions |

No tests were added, deleted or skipped. Reuse the existing regression matrices,
`ensureVisible` and shared input/semantics owner. No dependency, new helper,
visual redesign, shader change or layout rewrite is needed. Both production
viewer files, the responsive module and the controls module stay unchanged.

### Commands and results

All commands run at the execution checkout root with the pinned exports above.
`flutter --version` reports Flutter **3.47.9**, framework `c197ca5199`, Dart
**3.13.7**, matching `fdroid/flutter.version`. The Python probe passes with
`/usr/bin/python3`, Python 3.12.3, pytest 9.0.2, jinja2 3.1.6 and callable
`markupsafe.soft_str`. `flutter pub get --offline --enforce-lockfile` exits 0.
No packages or host tooling were installed. No sharded check runner exists here.

Exact required focused command:

```sh
flutter test --no-pub test/fractal/palette_picker_test.dart test/fractal/viewer_mobile_toolbar_test.dart test/fractal/viewer_responsive_controls_test.dart test/fractal/viewer_toolbar_layout_test.dart test/fractal/fractal_view_controls_test.dart --reporter expanded
```

| Run | Result | Exit |
| --- | --- | --- |
| Baseline five modules plus accessibility module | +224 -3, 47s test time | 1 |
| Intermediate five modules plus accessibility module | +226 -1, hint inventory exposed the subclass cast described above | 1 |
| Final required five modules, repetition 1 | +200, 41s test time | 0 |
| Final required five modules, repetition 2 | +200, 43s test time | 0 |
| Final accessibility module alone | +27, 4s test time | 0 |

The final five-module union has 32 picker, 5 mobile, 63 responsive, 60 toolbar
layout and 40 controls tests. Every original failure maps to a passing final
case. No skips, unrelated failures, load-dependent variation or timing changes
were observed. Two focused passes are not full-gate or three-revision flakiness
proof. Logs remain task-local under `$TMPDIR`: `preflight.log`, `before.log`,
`after-1.log`, `final-focused-1.log`, `final-focused-2.log`, `final-a11y.log`
and `analyze.log`.

`autowork-run flutter analyze --no-pub` exits 0: **No issues found**.
`dart format --output=none --set-exit-if-changed` on the four changed Dart files
and `git diff --check` exit 0. Before preflight and after testing/analysis,
`pubspec.lock` SHA-256 is unchanged:
`d759c63037e4d4f29a7c09b14886854fb8caa832c41f1172ec684a5cdcb7145b`.
Tested changed Dart blobs (`git hash-object`, delivered by the worker commit):

| Path | Blob |
| --- | --- |
| `test/fractal/palette_picker_test.dart` | `f1f433f18f8edb338497c1bf5df5491b6f763f5c` |
| `test/fractal/viewer_mobile_toolbar_test.dart` | `5ed4e98b6797c796515f70e022f534379267ac2e` |
| `test/fractal/viewer_toolbar_layout_test.dart` | `9b79e6a444153e5b2605382f5a1150ad076f6092` |
| `test/a11y/screens/viewer_screen_a11y_test.dart` | `16868cdfe10c75ff447014dc6568fb8ad63df863` |

### Scoped Docs Sync Maintain and remaining gates

Maintain updates only this existing evidence owner. The linked
[PRD](../../PRD.md#mcp-assisted-architecture-and-ui-improvement),
[spec](../engineering/spec.md#mcp-assisted-app-quality) and
[test plan](../engineering/test-plan.md#mcp-assisted-app-quality-verification)
were inspected. They already preserve localized accessible controls and separate
offline checks from runtime qualification. No product or architecture contract
changed. Source, test-name mapping, result inventories, blob hashes, local links
and lockfile were checked with
`/usr/bin/python3 "$TMPDIR/verify_viewer_repair_evidence.py"` (exit 0).
Scoped `docs.py stale .` and `docs.py check .` exit 0 but report **no manifest**;
they do not certify content. A repeat readback leaves the document bytes stable.

The complete offline chain above is **NOT_RUN by this worker**, as required by
the retry prompt. The coordinator runs it on the merged tree before review.
The separate focused and analyzer passes are not a combined gate pass.
DOCS-MAINTAINER closeout must retain the merged-tree gate's source revision,
terminal result and lockfile hash. No task, goal, closed-task state, shared
history or `ACAD-013-4142ef42` device scope was changed. Device/browser/GPU,
production, release and human visual/accessibility qualification remain unrun
and separate; these widget tests do not qualify rendering or whole-app visuals.
