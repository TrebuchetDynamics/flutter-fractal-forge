+++
schema = 1
id = "EXPORT-001-f3"
title = "Commit native exports without partial completed files.**"
short = "Commit native exports without partial completed files.**"
status = "open"
goal = "REL-JOURNEY-001"
section = "Next"
rank = 14000
depends_on = []
touches = ["lib/core/services/export/export_service.dart", "lib/core/services/export/batch_export_service.dart", "test/export/export_service_test.dart", "test/export/batch_export_service_test.dart", "docs/engineering/test-plan.md"]
resources = []
kind = "implementation"
ownership = "worker"
scope = "Use one small same-directory staging/commit primitive in the existing export services for native single images, batch items and contact sheets. Preserve validated names/directories, existing APIs/metadata/encoded bytes/size policy and separate MediaStore behavior. Add a minimal injected write/commit seam for deterministic tests rather than real full-disk tests. No general persistence framework, preference-save changes, resumable exports, startup cleanup sweep, web download changes or live service operations."
acceptance = ["For native single-image, batch-item and contact-sheet outputs, a partial stage write, commit/replace failure, cancellation before commit or destination collision leaves no partial completed filename, preserves any prior destination byte-for-byte, and cleans only this attempt’s stage. Commit only by a same-directory operation whose replacement semantics are supported and safe; never delete the destination first, and fail closed without changing it when safe replacement is unavailable. The successful commit is the cancellation boundary: complete committed outputs may remain and are reported truthfully, never premature item-success. Deterministic tests exercise each failure mode separately in all three output paths, plus successful retry and recreated-service behavior; abandoned stages are never treated as completed exports and unrelated files are never deleted. Successful retry yields expected decodable bytes; existing cancellation/metadata/filename guards pass. A mirror/gallery failure does not erase or falsely qualify an already committed local file."]
checks = ["`flutter test test/export/export_service_test.dart test/export/batch_export_service_test.dart --reporter expanded`; in both suites, verify partial-write/commit-failure/pre-commit-cancel/collision/old-destination-preservation/retry/recreated-service cases independently for single-image, batch-item and contact-sheet outputs; `dart format --output=none --set-exit-if-changed lib/core/services/export/export_service.dart lib/core/services/export/batch_export_service.dart test/export/export_service_test.dart test/export/batch_export_service_test.dart`; `flutter analyze`; `git diff --check`. Real filesystem/provider/device qualification remains separate; tests and platform qualification are not claimed passed by this task text."]
exclusions = []
+++

- Section: Next.
- Sources: [Accepted gap-closure contract](docs/engineering/spec.md#native-export-commit-boundary), [verification](docs/engineering/test-plan.md#plan-gap-completion-checks).
- Ownership: Repository backlog, unassigned; preserve live writers and existing gates. Planning does not dispatch.
- Next action: First reproduce failed-write/final-path behavior with deterministic service-level fault seams, then route the three existing native image paths through same-directory staging and a commit boundary. Preserve any active release worker’s contract and the retained release candidates; this docs pass observed no running repository workers and grants no execution or preference-storage changes.
