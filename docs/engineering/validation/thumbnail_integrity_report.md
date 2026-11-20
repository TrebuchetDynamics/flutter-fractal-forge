# Thumbnail Integrity Report

**Updated:** 2026-06-26
**Status:** Superseded by runtime-rendered catalog thumbnails

## Current shipping decision

Catalog thumbnails are rendered at runtime by the catalog UI. Static files under
`assets/catalog_thumbs/` are no longer bundled. The [current asset declarations](../../../pubspec.yaml) own the bundled artwork and native reference fixtures; do not infer the complete asset set from this dated report.

This makes the large `assets/catalog_thumbs/*.png` removal intentional for the
runtime-thumbnail migration, not a missing-asset regression.

## Why this changed

The previous report selected CPU-generated thumbnails because emulator GPU
captures were black under SwiftShader. That static thumbnail set later became a
second source of truth: generated files, asset manifests, catalog state, and
fallback labels could drift independently.

Runtime rendering is now the source of truth. The static-asset mapping remains
only for the disabled fallback path (`RUNTIME_CATALOG_THUMBNAILS=false`), and the
catalog checks the asset manifest before trying to load any fallback PNG.

## Current validation signals

- [`pubspec.yaml`](../../../pubspec.yaml) declares the actual static assets and shaders; catalog thumbnail PNGs remain excluded.
- `lib/features/catalog/AGENTS.md` documents runtime-rendered thumbnails.
- [`lib/features/catalog/data/catalog_thumbnail_plan.dart`](../../../lib/features/catalog/data/catalog_thumbnail_plan.dart) owns fallback asset
  availability state via `CatalogThumbnailAvailability`.
- `test/features/catalog/catalog_thumbnail_plan_test.dart` covers exact,
  missing, loading, and fallback/approximate states.
- `test/golden/catalog_golden_test.dart` exercises the catalog UI.
- The earlier runtime-thumbnail update recorded a full-suite/Linux build rerun; this report is not a fresh check result for the current tree.

## Historical note

The old static-thumbnail report from 2026-02-13 found:

- CPU thumbnails: 199 PNGs, valid but formula-limited.
- GPU emulator attempt: 197 PNGs, mostly black due to SwiftShader.
- Former shipping decision: bundle CPU thumbnails from `assets/catalog_thumbs/`.

That decision is no longer current.
