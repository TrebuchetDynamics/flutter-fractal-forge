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

The [failing fixture](../../test/diagnostics/test_logger_test.dart) registers
per-test directory deletion with `addTearDown`, while the outer teardown awaits
singleton disposal. Its write test explicitly disposes before reading and its
re-initialization test disposes before directory deletion, but the first test
relies on the separate teardown callbacks. The
[logger implementation](../../lib/core/services/diagnostics/test_logger.dart)
creates the file, starts an asynchronous `openWrite` sink and marks initialization
complete; disposal awaits flush/close before resetting singleton state.

Investigate callback ordering, outstanding sink-open/flush/close work, assertion
failure cleanup, singleton state carried into subsequent cases, and loaded-suite
resource timing. This is a hypothesis supported by the stack and fixtures, not a
reproduced root cause. Prefer deterministic fixture lifetime/cleanup if confirmed.
Repair existing product lifecycle code only if a reproduced defect requires it,
with a failing-before/passing-after regression; no logging redesign is authorized.
Preserve custom-path creation, written content, no-op reinitialization, singleton
reset and buffer assertions. No skips, swallowed asynchronous errors, relaxed
assertions or arbitrary sleep/yield increases.

## Existing task reconciliation

[MAIN-MUSIC-REFRESH-01](../../tasks/items/MAIN-MUSIC-REFRESH-01.md) is already
coordinator-closed. Its saved `attempt-1/report.json` identifies candidate
`9dc722b1` and only two changed files: its test and diagnosis document. Candidate
diff and report contain no task-file edits to replay. Its closure evidence and
accepted contract remain unchanged. That report's focused passes and worker
NOT_RUN full-gate boundary do not qualify this later failed revision. The new
logger task is distinct from NUM-WALL-02's screenshot-service fixture repair.

## Verification boundary

The worker must follow [MAIN-CHECK-01](MAIN-CHECK-01.md#reproducible-process-local-invocation)
and the [common offline gate](../../AGENTS.md#common-offline-integration-gate),
revalidate pinned Flutter/Dart and provisioned Python imports, preserve
`pubspec.lock`, repeat the logger file alone and with adjacent diagnostics tests,
and run the unchanged full offline gate. Retain source, exact repetitions,
commands, terminal stages/exits and before/after lock hashes. Missing tools,
timeouts, skips and failures remain explicit; separately running families after
a short-circuit is diagnosis, not a passing chained gate. No coordinator receipt
is a prerequisite for local diagnosis or repair.

This docs-maintainer pass inspected sources and retained evidence only; Flutter,
Python and Bats suites were **NOT_RUN**. Ledger validation is separate from code
verification. No goal, device/browser, production or live qualification is claimed.
Revisit this record when new source-bound reruns or a delivered repair are available.
