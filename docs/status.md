## Status Update — 2026-03-21

### Summary
- Refreshed stale repository docs to match the current app and release scope.
- Aligned the main docs with the current catalog/browser architecture and the non-AR, image-export-only release.
- Marked older planning docs as archived where they intentionally preserve superseded scope.

### Changes
- `README.md`: rewritten around the current 370-module catalog, viewer flow, and current source-of-truth docs.
- `AGENTS.md`, `lib/AGENTS.md`, and feature `AGENTS.md` files: updated architecture notes, counts, and responsibilities.
- `STORE_LISTING.md`, `store_listing/`, and `store-listing/`: removed stale 350+/video/deep-zoom claims and synced Play copy with the current release.
- `docs/privacy_policy.md` and `privacy-policy.html`: updated to image-export-only wording and current local-storage/privacy behavior.
- `PRD.md`, `docs/play_store_listing.md`, `docs/AR_ARCHITECTURE_FULL_REPORT.md`, `docs/END_VISION.md`, and `PLAYTEST_REPORT.md`: marked as archived historical references where applicable.
- `TODO.md` and `CHANGELOG.md`: refreshed counts and recorded the documentation sync.

### Validation
- `test/catalog_id_integrity_test.dart` remains the source of truth for catalog counts referenced in docs.
