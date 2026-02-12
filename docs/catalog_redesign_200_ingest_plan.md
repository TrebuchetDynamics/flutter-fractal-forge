# Catalog Redesign + PRD-200 Ingest Plan

_Last updated: 2026-02-11_

## Goals
- Redesign Explore catalog for scale (200 entries) with fast browsing/search.
- Keep **stable IDs** for every catalog item from day one.
- Add per-item preview thumbnails.
- Ingest PRD list in a staged, testable rollout without breaking existing module selection.

## Stable ID policy (must not change)
- Format: `<namespace>.<slug>`
- Existing implemented modules use `core.<module_id>` (e.g. `core.mandelbrot`).
- Future PRD-only entries should use `prd.<slug>`.
- IDs are immutable once released; title/localization can change, ID cannot.

## Data model
1. `CatalogEntry`
   - `catalogId` (stable)
   - `module` (runtime renderer mapping)
   - `aliases` (search synonyms)
2. `CatalogRepository`
   - Source of truth for Explore list ordering/filtering.
   - Phase 1 built from `ModuleRegistry` while preserving stable IDs.
   - Phase 2 loads PRD manifest and maps each entry to a module (or gated unavailable state).

## Thumbnail strategy
- Phase 1: deterministic generated thumbnail from `catalogId` hash (implemented now).
  - Benefit: immediate per-item visual distinction without asset pipeline blockers.
- Phase 2: replace with curated assets (`assets/catalog/thumbs/*.webp`) for top entries.
- Phase 3: optional cached live-render snapshots for high-fidelity previews.

## PRD-200 ingest stages
1. **Stage A (done in this first slice)**
   - Introduce catalog domain layer (`CatalogEntry`, `CatalogRepository`).
   - Wire Explore screen to repository.
   - Stable IDs + generated preview thumbnails.
2. **Stage B (next)**
   - Add `assets/catalog/prd_catalog.json` with full PRD list + stable IDs.
   - Build validation script/test:
     - IDs unique
     - IDs immutable snapshot check
     - each entry has title, dimension, module mapping
3. **Stage C**
   - Add browse affordances for scale:
     - section chips / filters / tags
     - sort modes (popular/new/classic)
     - list/grid toggle
4. **Stage D**
   - Curated thumbnail pack and lazy loading/cache.
5. **Stage E**
   - Deep links and analytics keyed by `catalogId`.

## Risks and mitigations
- **Risk:** ID churn during PRD edits.
  - **Mitigation:** ID lockfile snapshot test in CI.
- **Risk:** 200-item UI performance regressions.
  - **Mitigation:** lightweight item model, deferred thumbnail decode, list virtualization.
- **Risk:** mismatch between PRD entries and implemented modules.
  - **Mitigation:** explicit `moduleId` mapping + test coverage for broken links.

## Immediate next commits (recommended)
1. `feat(catalog): add PRD manifest loader + stable-id integrity tests`
2. `feat(catalog): add tag filters and list/grid switch for 200-item browsing`
3. `feat(catalog): add asset-backed thumbnails for top 40 entries`
4. `test(catalog): lock stable IDs and validate module mapping coverage`
