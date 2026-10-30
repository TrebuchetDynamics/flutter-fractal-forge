# MAIN-RANDOM-FAB-01 — Deterministic random-fractal FAB coverage

## Scope and source identity

This is fixture-only candidate evidence on baseline
`ddeb80dd7681849a83f960186a0b4a19e809aedd`, not main integration or live
qualification. The delivered Dart file has SHA-256
`06c5063dbf094380be571be1923f5d5500cfa7526b1f4081e21d84902cedfe58`
and Git blob `0b5d6d8dd8c54154ea3039519e66435c12fc1fdb`.
The commit containing this note identifies the complete candidate.

The change supports the accepted [app-quality outcome](../../PRD.md#mcp-assisted-architecture-and-ui-improvement)
and [verification contract](../engineering/test-plan.md#mcp-assisted-app-quality-verification).
It changes only the [viewer widget fixture](../../test/fractal/fractal_viewer_screen_widget_test.dart).
No product selection, palette, shader, dependency, release or Waydroid policy changed.

## Diagnosis

Inspected the original runner bundle in place at checked revision
`023865160875371e8100d8561cec9b05b091b1ca`: `main_check.json`,
`main-check.log`, `main-check.exit`, `main-check-reruns.log` and
`flaky_history.json`. No evidence files were copied or modified.
Last green was `0ca4a01f169bd7ccd71ace8677db8da3851eefa2`.
The failed gate exited 1 after 3,161 Flutter passes, 8 skips and one failure.
Preflight and analysis passed; the chained Python/Bats checks were not reached.
The isolated-rerun log is empty and flakiness history is empty.

The FAB selected `perron_tree`, then the test's unconditional
`firstWhere(colorScheme)` threw `StateError: Bad state: No element`.
The [production action](../../lib/features/viewer/navigation/viewer_interactions.dart)
already guards absent palette parameters and publishes module and palette in
one controller update. [Perron Tree](../../lib/core/modules/fractals/perron_tree_module.dart)
validly declares `hue`, not `colorScheme`. The intervening Waydroid documentation
commit is not evidence of product causation and is not rolled back.
The [older same-fixture observation](LOOPER-001-58-verification.md) is historical,
not qualification of this candidate or three-revision flakiness evidence.

### Isolation, load and timing

- The group creates a fresh registry, controller and mocked stores in each
  `setUp`. Each new case narrows only that registry's mutable module list.
  Both controller and provider receive the same registry. No global catalog or
  production eligibility filter changes.
- A deterministic isolated failure and a complete-file failure reproduce the
  missing-parameter lookup without whole-suite load. Resource pressure is not
  necessary to cause this defect. This does not measure or rule out unrelated
  loaded-suite resource problems; the merged full gate remains required.
- The history provider owns a 500ms debounce timer. Widget disposal cancels viewer
  timers, animations and controller listeners. Both cases now use `finally` to
  cancel pending history and unmount/pump inside the widget fake-async scope.
  The palette observer is removed there, before group disposal, even on failure.
- Settling retains the normal 100ms pump interval and semantics phase, but has
  an explicit five-second fake-time timeout. The old 400ms/50ms teardown waits
  are removed, not increased. No sleeps, extra yields or exception suppression
  were added. Repeated complete-file passes found no pending-timer or framework
  exceptions from these cases.

## Delivered coverage

Both named cases run on every invocation of the existing test-name prefix:

- `FractalViewerScreen random fractal FAB switches module with palette`:
  registry contains only `mandelbrot` and `julia`. The real FAB must switch from
  `mandelbrot` to `julia`. It retains the non-default selected palette assertion,
  nonempty controller-publication history, first publication equal to the chosen
  palette, and every publication equal to it. Julia's parameter and preset
  palette defaults are both zero. Palette randomness remains unrestricted among
  the valid non-default choices; module identity is deterministic.
- `FractalViewerScreen random fractal FAB switches module without palette`:
  registry contains only `mandelbrot` and `perron_tree`. The real FAB must switch
  to `perron_tree`, with no palette parameter, no stale `colorScheme` controller
  value and no framework exception. This is a separate always-run case, not a
  conditional escape from palette assertions after a random module draw.

These tests observe widget interaction and controller state, not GPU pixels,
physical-device photosensitivity safety or installed-app behavior.

## Executed commands and results

All Flutter/Dart commands used the process-local setup from
[MAIN-CHECK-01](MAIN-CHECK-01.md#reproducible-process-local-invocation):

```sh
export FLUTTER_ROOT="$AUTOWORK_CACHE/flutter-3.44.6"
export PUB_CACHE="$AUTOWORK_CACHE/pub-cache"
export PATH="$FLUTTER_ROOT/bin:/usr/bin:$PATH"
```

`flutter --version` matched `fdroid/flutter.version`: Flutter 3.44.6,
Dart 3.12.2. The provisioned SDK reports channel `[user-branch]` and framework
revision `ee80f08bbf`; no SDK modification was made.
`/usr/bin/python3` is Python 3.12.3 with pytest 9.0.2 and Jinja2 3.1.6;
`import sys, pytest, jinja2, markupsafe` and callable `markupsafe.soft_str`
validation exited 0. Nothing was installed.

| Command | Repetitions and final outcome |
| --- | --- |
| `flutter pub get --offline --enforce-lockfile` | 1; exit 0, checkout-local metadata regenerated |
| `flutter test --no-pub test/fractal/fractal_viewer_screen_widget_test.dart --plain-name 'FractalViewerScreen random fractal FAB switches module' --reporter expanded` | Before: 1, exit 1, deterministic Perron Tree lookup failure. After: 3, exit 0 each, 2 passes each, no skips |
| `autowork-run` with `timeout 180 flutter test --no-pub test/fractal/fractal_viewer_screen_widget_test.dart --reporter expanded` | Before: 1, exit 1, 207 passes / 1 failure / no skips. After: 2, exit 0 each, 209 passes each / no skips |
| `autowork-run` with `timeout 180 flutter analyze --no-pub` | 1; exit 0, no issues |
| `dart format --output=none --set-exit-if-changed test/fractal/fractal_viewer_screen_widget_test.dart` | Exit 0; final format unchanged |
| `git diff --check` | Exit 0 |
| `/usr/bin/python3 "$TMPDIR/random_fab_docs_readback.py"` | Exit 0; scoped evidence readback, local links/anchors and source/lock hashes checked |
| Bundled Docs Sync `docs.py check .` | Exit 0; no role manifest, so no manifest-wide content verdict |
| `autowork tasks validate --worktree .` | Exit 0; read-only task-store validation |

Before runs used baseline source plus only this fixture injection, with all
original assertions retained:

```dart
registry.modules.removeWhere(
  (module) => module.id != 'mandelbrot' && module.id != 'perron_tree',
);
```

The complete-file before run reconstructed those same baseline fixture bytes
in this checkout, then restored the delivered test block. Other viewer cases
were unchanged. The final source hash above matches the passing after runs.
Task-local logs are `$TMPDIR/fab-before.log`, `$TMPDIR/viewer-before.log`,
`$TMPDIR/fab-after-{1,2,3}.log`, `$TMPDIR/viewer-after-{1,2}.log`,
`$TMPDIR/preflight.log` and `$TMPDIR/analyze.log`. They are scratch evidence,
not committed copies of the private runner bundle.
Independent read-only source review found no correctness or coverage issue;
it did not rerun tests.

The `pubspec.lock` SHA-256 before preflight and after all worker checks is
`22b29dbd8f71276012a54b9bdc62ba88408f967a86b34075986c17e1c4506ec3`.
The lockfile is unchanged.

## Documentation and remaining gate

Scoped Docs Sync Maintain updates only this task's verification owner.
The existing shared PRD/spec/test-plan contracts remain applicable and unchanged.
The read-only prepare check preserved the in-flight contract and made no task
changes. No coordinator history or task closure is edited. A changelog proposal
is supplied in the worker report for the coordinator.

The worker instructions reserve the unchanged full offline integration gate
for the coordinator's merged-tree run. It is **NOT_RUN by this worker**.
The repeated focused passes do not qualify that gate or establish three distinct
passing revisions. The coordinator must retain the exact merged source revision,
full command/output, per-stage exits, skips and before/after lock hashes.
If it short-circuits, retain the failed chained result and diagnose remaining
unchanged families separately. DOCS-MAINTAINER owns the eventual shared evidence
and status reconciliation after integration.

No device, browser, hardware, release or production acceptance is inferred or
required to complete this fixture-only local repair.
