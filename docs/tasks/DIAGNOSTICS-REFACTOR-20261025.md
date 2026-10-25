# Diagnostics refactor and main integration

## Source and scope

- Refactor: `eb4b9d96c91bdbc688a526249a5669774fd7746b`, based on `5558c33898c247d241553c426324338170ccca7c`.
- Main predecessor: `697406ffe0a22cb711b325cc928531d80d2098ae`.
- Clean native merge: `c0db6cb3000cf838c43618245f3aaf4738179857`.
- User authorization: merge all completed work into main and push. Existing completed music synthesis/playback separation, deep-link codec separation, finite Perron-tree evidence reconciliation and reserved-port native driver work are retained, with their original commits and task evidence.
- No historical set-aside candidate, unfinished concurrent work, runtime transcript, secret, cache or ignored build/evidence output is added to the delivery.

## Complete diagnostics topology

Nine implementations moved under `lib/core/services/diagnostics/`:

- `logging/`: app logger, crash reporter and diagnostic event logger. A new `event_retention.dart` shares the identical append-and-trim policy between `CrashReporter.record` and `TestLogger.log`.
- `profiling/`: frame telemetry and the conditional process-memory reader with IO and stub adapters.
- `runs/`: debug-run orchestration and screenshot capture.

Every remaining root file is an intentional public compatibility export:

```text
app_logger_service.dart
crash_reporter.dart
debug_runner_service.dart
performance_service.dart
process_memory_reader.dart
process_memory_reader_io.dart
process_memory_reader_stub.dart
test_logger.dart
test_screenshot_service.dart
```

There are no unclassified root files or remaining move candidates. All original paths re-export the original declarations without forwarding classes or duplicate singleton implementations. Public symbols, schemas, privacy sanitization, persistence and lifecycle behavior remain unchanged. Heterogeneous recursive metadata snapshots, string-only crash tags and Queue-based app-log retention deliberately remain separate.

A source audit reconstructs all nine original implementations byte-for-byte after reversing only the documented internal import redirects and two retention extractions. Its original-source baseline hash is `5c2769e7db5ee3ee200f673b3ee6f54da83a51d9840b1a9469e378f00c674e9e`. Existing lifecycle/logging-policy assertions are preserved; only their source-owner paths changed. The crash-history test additionally asserts the complete chronological newest suffix.

## Verification and reuse boundaries

Pinned Flutter 3.44.6 / Dart 3.12.2 and the existing offline package cache were used. `/usr/bin/python3` provisioned imports were checked. `pubspec.lock` remained unchanged (SHA-256 `22b29dbd8f71276012a54b9bdc62ba88408f967a86b34075986c17e1c4506ec3`).

On the refactor source, the offline lockfile-enforced preflight, analyzer, full Flutter suite, Python and Bats gate passed: **3,048 Flutter tests / 8 skips; 282 Python tests / 1 skip / 103 subtests; 25 Bats tests**. Each of the three move-only slices and the retention extraction also passed the same 190 related tests. A retain-oldest mutation failed both retention tests before extraction; the mutation was restored. An earlier 600-second full-gate attempt timed out after 1,639 passes / 1 skip and is retained as a failed attempt, not passing evidence. The complete unchanged rerun passed with an 1,800-second bound.

Independent fresh-context read-only review found no defects in compatibility, conditional platform selection, retention edge semantics or source scope. Zero and negative caller-limit behavior is preserved, not silently repaired.

The merged production `lib/` tree is **identical** to the fully checked refactor tree: Git tree `fe30c255e57084038d8ed0d61826cc6740850e3f`. Shader/assets/platform trees, dependency declarations/lockfile, analyzer/test configuration and all other Flutter tests are unchanged. The only Flutter-test change since that full run is the already-reviewed Perron PNG-decoding test; the other new test file is Python native-driver coverage. Existing Flutter tests do not consume the changed native-driver/runbook/task/changelog paths.

On merged source `c0db6cb3`, offline resolution and analyzer passed; the diagnostics/app/lifecycle/screenshot/performance and Perron model/module checks passed **202 tests**. The complete Python and Bats families were rerun: **294 Python tests / 1 skip / 103 subtests; 25 Bats tests**. Native-driver shell syntax/help and whitespace checks passed. These are fresh affected-input checks plus source-bound reuse of the full Flutter result, **not a claim that the entire Flutter suite was rerun on the merged test tree**.

Local receipts remain under `.worktrees/refactor-diagnostics-20261025/release-artifacts/diagnostics-refactor/` and `.worktrees/ship-diagnostics-20261025/release-artifacts/diagnostics-delivery/`; logs and runtime artifacts are intentionally not versioned.

## Qualification limits

Git delivery is not a release or platform publication. No new device/browser/hardware-GPU, assistive-technology or production qualification follows from these offline checks. Existing live qualification tasks and the native driver's original source-bound fixture evidence retain their own limits; this delivery does not close Number Walls device or live journey gates. Active workers and their candidate worktrees are preserved.
