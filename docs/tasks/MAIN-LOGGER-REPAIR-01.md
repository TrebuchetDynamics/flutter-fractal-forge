# MAIN-LOGGER-REPAIR-01 — TestLogger file-I/O gate repair

## Evidence and classification

MAIN reports **red / TEST_FAILURE** on checked revision
`6ab8dae423f45cccb7b8cbdf0e117dbe130261fc`; last recorded green is
`80375294186cf82bbd0bde2542b946e2e323d30e`.
The original bundle was inspected in place, not copied or changed:
`/home/xel/git/trebuchet-dynamics/flutter-fractal-forge/.git/autowork-execution/main-evidence/6ab8dae423f45cccb7b8cbdf0e117dbe130261fc/`.

- `main_check.json` names three failures in `test/diagnostics/test_logger_test.dart`:
  `TestLogger — file I/O init with customPath creates file at that path`,
  `TestLogger — file I/O log writes to file when initialized`, and
  `TestLogger — file I/O init skips re-initialization when already initialized`.
- `main-check.log:1–53` records completed dependency preparation and clean analysis.
  Lines 12987–13022 show `PathNotFoundException` opening the first fixture's
  `test_logger_…/test.log`, then `Bad state: StreamSink is closed`, then repeated
  missing-path errors using that same first fixture path. The first stack names
  `TestLogger.init` at implementation line 77 and test line 182; later stacks
  include the global test teardown at line 11.
- Lines 13813–13818 end with `+2983 ~8 -3`, `Some tests failed`, and the three
  names above. `main-check.exit` is **1**. Python and Bats were not reached by
  the chained gate; no result for those families is inferred.
- `main-check-reruns.log` is empty; `flaky_history.json` is `{}` and metadata has
  `flaky=[]`. No isolated reruns or three-revision flaky classification were
  supplied. A future focused pass alone does not establish a green full gate.

Commits since that green revision:

1. `9dc722b10b4e32d56167289839d2bd0c2d39a887` — test(viewer): drive missing-frame music refresh with fake time.
2. `934902b80688559c3abee5ab20e2edf7d41473c3` — merge of that candidate.
3. `6ab8dae423f45cccb7b8cbdf0e117dbe130261fc` — docs(tasks): close MAIN-MUSIC-REFRESH-01 (pi-autowork).

Their combined changed paths are the music coordinator test, its diagnosis doc,
its task and closure-evidence records, and `CHANGELOG.md`. Neither the failing
logger test nor its implementation changed in this range. Those paths in
Touches declare provenance, not permission to reopen the music task or rewrite
its evidence. Causation is unproven.

## Source-supported investigation

At worker baseline `deb4d66909daa13227dd3d2beae72d03d5ca234c`, the
[failing fixture](../../test/diagnostics/test_logger_test.dart) registered
per-test directory deletion with `addTearDown`, while the outer teardown awaited
singleton disposal. The custom-path case therefore deleted the directory before
settling the sink. The write case disposed before reading only on success; the
re-initialization case's inline disposal/deletion was also skipped on assertion
failure.

The installed `test_api` 0.7.11 sources confirm the ordering:
`lib/src/backend/declarer.dart:241–248` registers outer teardowns before the body;
`lib/src/backend/invoker.dart:282–301` executes callbacks in reverse registration
order. A temporary guard checking singleton reset immediately before directory
deletion failed on the baseline (exit 1, two other file-I/O cases passed). The
same guard after the repaired cleanup passed all three cases (exit 0). This
confirms the unsafe fixture ordering, not a deterministic reproduction of the
original asynchronous missing-path exception. One complete baseline logger run
and ten baseline file-I/O runs passed in isolation; no flaky classification is
inferred from those passes.

The [unchanged logger](../../lib/core/services/diagnostics/test_logger.dart)
creates the file and starts asynchronous `openWrite` work at lines 75–78.
`dispose` awaits flush/close before resetting the singleton at lines 145–155.
Deleting the parent before that work settles explains the retained first-path
error; a rejected flush exits before singleton reset, explaining subsequent
closed-sink/stale-path failures. No independent product lifecycle defect was
reproduced with a valid directory lifetime, so product code remains unchanged.
No evidence attributes this fixture race to the completed music change or
establishes resource load as a necessary cause.

The repair creates one fresh directory per file-I/O case and immediately
registers a single asynchronous cleanup that awaits disposal before deletion.
It runs even if a case's assertion fails. The write case still explicitly
disposes before reading. All existing custom-path, content, no-op
reinitialization, singleton and buffer assertions are unchanged. No new test
cases, skips, swallowed errors, sleeps or polling were added.

## Existing task reconciliation

[MAIN-MUSIC-REFRESH-01](../../tasks/items/MAIN-MUSIC-REFRESH-01.md) is already
coordinator-closed. Its saved `attempt-1/report.json` identifies candidate
`9dc722b1` and only two changed files: its test and diagnosis document. Candidate
diff and report contain no task-file edits to replay. Its closure evidence and
accepted contract remain unchanged. That report's focused passes and worker
NOT_RUN full-gate boundary do not qualify this later failed revision. The new
logger task is distinct from NUM-WALL-02's screenshot-service fixture repair.

## Verification boundary

Worker checks use [MAIN-CHECK-01](MAIN-CHECK-01.md#reproducible-process-local-invocation)
and the [common offline gate](../../AGENTS.md#common-offline-integration-gate)
bindings below, from this execution checkout's root:

```sh
export FLUTTER_ROOT="$AUTOWORK_CACHE/flutter-3.44.6"
export PUB_CACHE="$AUTOWORK_CACHE/pub-cache"
export PATH="$FLUTTER_ROOT/bin:/usr/bin:$PATH"
```

These exports were scoped to command subshells, not the host/profile.

| Worker check | Actual result |
| --- | --- |
| `flutter --version`, compared with `fdroid/flutter.version` | Exit 0; Flutter 3.44.6, framework `ee80f08bbf`, Dart 3.12.2. |
| `/usr/bin/python3 -c 'import sys, pytest, jinja2, markupsafe; print(sys.executable, sys.version, pytest.__version__, jinja2.__version__); assert callable(markupsafe.soft_str)'` | Exit 0; Python 3.12.3, pytest 9.0.2, Jinja2 3.1.6. No packages installed. |
| `flutter pub get --offline --enforce-lockfile` | Exit 0; checkout-local package metadata regenerated. |
| `flutter test --no-pub test/diagnostics/test_logger_test.dart --reporter expanded` | Ten consecutive repaired runs, each exit 0, 15 passed, no skips. All three file-I/O cases run sequentially in each process. |
| `flutter test --no-pub test/diagnostics/ --reporter expanded` | Exit 0; 119 passed, no skips. CrashReporter fixtures intentionally print fatal/error stacks; these were not failed tests. |
| Failure-path probes using `flutter test --no-pub test/diagnostics/test_logger_test.dart --plain-name 'TestLogger — file I/O' --reporter expanded` | Temporarily inserted `fail('intentional fixture-cleanup probe')` before each case's main assertion/disposal, one case per run. Each run exited 1 with only that intentional failure and two passing cases. Readback verified all three initialized paths' directories were gone and no missing-path/closed-sink error occurred. All probe edits were removed. |

Diagnostic logs remain in the worker's `$TMPDIR`: `logger-baseline.log`,
`logger-baseline-{1..10}.log`, `logger-order-probe.log`,
`logger-order-after.log`, `logger-failure-{creation,write,reinit}.log`,
`logger-final-{1..10}.log` and `diagnostics-final.log`. They are scratch evidence,
not copied main-evidence records or repository artifacts.

`pubspec.lock` SHA-256 before and after the offline preflight and focused checks:
`22b29dbd8f71276012a54b9bdc62ba88408f967a86b34075986c17e1c4506ec3`.
Formatting, analyzer and documentation validation results accompany the worker
report.

The complete unchanged offline gate is **NOT_RUN by this worker**: the execution
instructions reserve it for the coordinator on the merged tree. The original red
gate above remains a failure, and focused passes do not establish a green full
gate. Python and Bats suites were not run by this worker. Coordinator integration,
full-gate verification and task closure remain pending; no goal, device/browser,
production or live qualification is claimed. The docs maintainer owns closeout
synchronization with that terminal gate result.
