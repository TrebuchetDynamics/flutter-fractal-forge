# EXPORT-001-f3: native export commit verification

## Scope and sources

Baseline: `67c6545f13a7b0e0c23ed86764e28df81e7be694`.
This is task-candidate evidence, not an integration or release receipt.
Task-relevant service/viewer code and tests were reused from retained candidate
`d492f9e036e82d5c024057890d82f4764a548820`, inspected against this baseline, and
checked afresh. Its verification results and shared-document changes were not reused.

Accepted owners, inspected and unchanged:
- [Native export commit boundary](../engineering/spec.md#native-export-commit-boundary)
- [Plan-gap completion checks](../engineering/test-plan.md#plan-gap-completion-checks)
- [Task contract](../../tasks/items/EXPORT-001-f3.md)

## Reproduction and implemented boundary

Before applying the implementation, a scratch service-level fault fixture replaced
`createExportFile` with a file that writes two bytes and throws. At the baseline,
`saveBytes` left those two bytes at the existing completed filename instead of the
previous image. This expected red reproduction used only an owned temporary directory.
The committed fixtures inject faults at stage-write and commit seams instead.

[ExportService](../../lib/core/services/export/export_service.dart) now owns one
`commitBytesToFile` primitive for native single images, batch items and contact
sheets. Exclusive creation reserves a unique, hidden, same-directory stage with
a short basename independent of the destination name. Complete encoded bytes are
written and flushed before rename can publish the final name. Partial writes,
commit failures and pre-commit cancellation clean only the attempt's stage;
previous destinations remain intact. Cleanup is best-effort if the filesystem
also rejects deletion, and never masks the original error. No startup sweep runs.

Regular-file replacement uses the existing Dart rename operation without a
copy or delete-and-retry fallback. Links, directories and other unsupported
destination types are rejected before rename. The pinned Dart 3.12.2
[Windows implementation](https://raw.githubusercontent.com/dart-lang/sdk/3.12.2/runtime/bin/file_win.cc)
uses `MoveFileExW(REPLACE_EXISTING)` for ordinary files, but unlinks directory
links before moving; the destination-type guard excludes that special case.
This is source inspection, not Windows runtime qualification. The guard does not
provide protection against another process concurrently replacing the destination
path. Rename is not a promise of power-loss durability on every filesystem.

Successful commit is the cancellation boundary.
[BatchExportService](../../lib/core/services/export/batch_export_service.dart)
publishes item callbacks only after commit and returns earlier committed items
when a subsequent item or contact sheet is cancelled. Sheet failure does not
erase committed items. [Viewer export actions](../../lib/features/viewer/export/viewer_export_actions.dart)
pass the token into native fallback saving and retain saved-file feedback after
commit, separating cancelled optional sharing from local saving. Legacy method
signatures, validated filenames, selected directories, encoding, metadata and
size policy are retained. Web downloads and preferences are unchanged.
MediaStore remains a separate existing best-effort operation; a returned local
file is not a gallery receipt or a claim that mirroring succeeded.

## Independent fault coverage

[Single-image tests](../../test/export/export_service_test.dart) separately cover
partial stage writes, commit failure with collision and retry, pre-commit
cancellation, post-commit cancellation, unsupported link collision and recreated
service handling of abandoned/occupied production stage names. Retry output has
identical encoded bytes and decodes successfully. One additional regression
reproduced `ENAMETOOLONG` when a staging suffix was appended to a valid 255-byte
destination basename; the bounded independent staging basename fixes it without
shortening the final name. A separate regression catches a caller-chosen staging-like
final basename: production stage selection must skip that name (and case variants)
so even a partial write never exposes it before commit.

[Batch tests](../../test/export/batch_export_service_test.dart) cover item and
contact-sheet partial writes, commit failures and pre-commit cancellation
independently, preserving old output bytes and cleaning owned stages. Both paths
also exercise unsupported link collisions, regular-file replacement with expected
decoded dimensions/RGB pixels, recreated-service retries and unrelated abandoned
stages. Callback and coordinator cancellation boundaries, cancellation during a
later item, metadata and effective-format guards remain covered.

[Viewer widget tests](../../test/fractal/fractal_viewer_screen_widget_test.dart)
cover fallback save-token propagation and saved feedback after native commit.
These are widget fixtures, not real filesystem/provider or GPU journeys.

## Fresh checks

Host: Linux, Flutter 3.44.6 / Dart 3.12.2 selected from
`$AUTOWORK_CACHE/flutter-3.44.6/bin`, with `PUB_CACHE=$AUTOWORK_CACHE/pub-cache`
and `/usr/bin` preceding ambient tools. Provisioned Python imports were checked.
The enforced offline preflight regenerated checkout-local metadata and preserved
`pubspec.lock`. No full gate was run; the runner owns merged-tree validation.

| Command | Exit | Result |
| --- | --- | --- |
| `flutter pub get --offline --enforce-lockfile` | 0 | Existing lockfile preserved. |
| `flutter test test/export/export_service_test.dart test/export/batch_export_service_test.dart --reporter expanded` | 0 | 127 passed; no skips. |
| `autowork-run flutter test --no-pub test/fractal/fractal_viewer_screen_widget_test.dart --reporter expanded` | 0 | 194 passed; no skips. |
| `flutter test --no-pub test/diagnostics/crash_reporter_test.dart --reporter expanded` | 0 | 30 passed; no skips. |
| `dart format --output=none --set-exit-if-changed lib/core/services/export/export_service.dart lib/core/services/export/batch_export_service.dart test/export/export_service_test.dart test/export/batch_export_service_test.dart lib/features/viewer/export/viewer_export_actions.dart test/fractal/fractal_viewer_screen_widget_test.dart` | 0 | Six Dart files formatted. |
| `autowork-run flutter analyze` | 0 | No issues found. |
| `git diff --check` | 0 | No whitespace errors. |

The retained integration hold receipt identified `[FF_CRASH][FATAL][test]
Exception: Fatal error`. That text is intentionally emitted by
`test/diagnostics/crash_reporter_test.dart`'s `records fatal events` fixture.
The unchanged module passed in isolation both on this baseline and after the
export changes. This explains the cited line but does not establish why the old
aggregate command exited 1 or qualify a fresh merged-tree gate.

Source/test SHA-256 values for the checks above:

```text
014009908e568b18cc81ab4da3faca636bb9cdc65fd45303d1aa72021f85fc67  lib/core/services/export/export_service.dart
06150d5181b54a8bc97d3ee3d76d8ab9e23219c15a845ed7eeb70c1769f443a6  lib/core/services/export/batch_export_service.dart
5c97120f2256ebb74ad70160cd1a085b0aa35c3692feb5ff19bd39a1edc8c321  lib/features/viewer/export/viewer_export_actions.dart
020312dcff8e6bbe30c10b17a6445e9a2c11ac9a5813cdfc4b802d32f13e8b22  test/export/export_service_test.dart
4e8284b694cc032c941e114633134d4c76dc13f1ea500fdcfcd5bc97c6abc425  test/export/batch_export_service_test.dart
2db6fdef659ba1aa2ec6ac0bece4a8c51e73a3341c1803fddc4657a9f4f217b4  test/fractal/fractal_viewer_screen_widget_test.dart
```

Independent final read-only review found no Critical or Important findings after
the two staging-name fixes and independently reran all 127 focused service tests.

Scoped Docs Sync Maintain writes only this task-specific evidence owner. Shared
spec/plan/history/task records remain unchanged. Link, anchor, source-hash and
preservation checks ran through `python3 "$TMPDIR/check_export_docs.py"`
(exit 0; all local links/anchors resolved, six source hashes matched, accepted
owners and lockfile were unchanged, and repeated document reads were byte-stable).
The repository has no Docs Sync role manifest; its manifest checker is a no-op,
not evidence of document correctness. The coordinator's docs maintainer owns
closeout reconciliation after integration.

## Remaining qualification

Actual supported-target filesystem/provider behavior, especially Windows
replacement and physical Android MediaStore/gallery readback, remains NOT_RUN.
Real device/browser journeys, human review and power-loss durability are not
established by these offline service/widget fixtures. No production, publication
or live-service operation was performed. Integration and its full gate remain
coordinator-owned.
