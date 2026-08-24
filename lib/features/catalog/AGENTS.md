<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# catalog

## Purpose

Fractal catalog browser screen. Displays all available fractals in a searchable grid with thumbnail previews. Users select a fractal here to open the viewer.

## Key Files

| File                           | Description                                                                                           |
| ------------------------------ | ----------------------------------------------------------------------------------------------------- |
| `fractal_catalog_screen.dart`  | `FractalCatalogScreen` - grid of fractal cards with search, category filtering, and thumbnail display |
| `data/catalog_entry.dart`      | `CatalogEntry` - data model for a catalog item (module reference + thumbnail path + metadata)         |
| `data/catalog_repository.dart` | `CatalogRepository` - data layer for catalog entries, manages thumbnail lookup and category grouping  |
| `data/catalog_thumbnail_cache.dart` | `CatalogThumbnailCache` - runtime-produced image cache (in-memory + on-disk) for rendered thumbnail PNGs, keyed by a render signature |
| `data/catalog_thumbnail_render_gate.dart` | `CatalogThumbnailRenderGate` - bounds concurrent live thumbnail renders (default 4, `RUNTIME_CATALOG_THUMBNAILS_MAX_CONCURRENT` dart-define); freed slots are handed to the next queued tile |

## For AI Agents

### Working In This Directory

- Thumbnails are rendered at runtime via the fractal renderer; static `assets/catalog_thumbs/` PNGs are deliberately not bundled (see `assets/AGENTS.md`).
- The first live GPU render of a thumbnail is captured and stored by `CatalogThumbnailCache` (in-memory for the session, best-effort on-disk in the app support dir for later launches/scroll-back/filter reuse). Entries are keyed by a render signature (catalogId + effective iteration/color caps + palette + schema version) so changing rendering invalidates stale artifacts.
- Live thumbnail renders are concurrency-bounded by `CatalogThumbnailRenderGate`: only `RUNTIME_CATALOG_THUMBNAILS_MAX_CONCURRENT` (default 4) renderers are live at once and freed slots pass straight to the next queued tile, so a full screen never compiles a grid of shaders simultaneously.
- The disk layer is production-only: `CatalogThumbnailCache` skips disk entirely under `RuntimeModeService.isAutomatedTest` (the path_provider channel never answers in tests, which would park futures forever). Widget tests exercise the in-memory layer; `CatalogRuntimeThumbnailCache.clearForTesting()` clears ready-marks, cached bytes, and queued render slots together.
- The disk cache is bounded: at most 1200 PNGs (the catalog has ~1000 modules) are kept; beyond that the oldest files are pruned (`CatalogThumbnailCache.diskPruneVictims`, unit-tested without a filesystem) so schema bumps do not orphan old generations forever.
- CPU/gradient fallback thumbnails can still show an approximate indicator (~) when runtime rendering is unavailable
- Search filters by fractal name (localized)
- Selecting a catalog entry navigates to FractalViewerScreen

### Testing Requirements

- Widget tests: `test/fractal/fractal_catalog_screen_widget_test.dart`, `test/catalog/catalog_search_widget_test.dart`
- Data tests: `test/catalog/catalog_repository_test.dart`
- Thumbnail bundle audit: `test/catalog/catalog_thumbnail_audit_test.dart`

## Dependencies

### Internal

- `core/modules/module_registry.dart` - Source of available fractals
- `viewer/` - Navigation target when fractal selected

<!-- MANUAL: -->

<!-- karpathy-guidelines:start -->

## Karpathy-Inspired Agent Guardrails

Source: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

These guardrails supplement the local instructions above. Local project, safety, and user-specific rules win on conflict.

Tradeoff: they bias toward caution over speed for non-trivial work; use judgment for obvious one-line fixes.

### Think Before Coding

- State assumptions before implementing; ask when uncertainty would change the solution.
- Surface multiple interpretations and tradeoffs instead of silently picking one.
- Push back when a simpler approach meets the goal.

### Simplicity First

- Build the minimum code that solves the requested problem.
- Avoid speculative features, single-use abstractions, and unnecessary configurability.
- If the solution is growing large, stop and simplify before continuing.

### Surgical Changes

- Touch only files and lines required by the request.
- Preserve existing style, comments, and nearby code unless the task requires changing them.
- Clean up only dead code introduced by your own change; mention unrelated dead code instead of deleting it.

### Goal-Driven Execution

- Convert the request into verifiable success criteria before editing.
- For multi-step work, state a short plan with a verification check for each step.
- Loop until the relevant tests, builds, or manual checks prove the goal is met.

<!-- karpathy-guidelines:end -->

<!-- karpathy-project-adjustment:start -->

## Project-Specific Karpathy Adjustment

This section localizes the Karpathy guardrails for `workspace-sidon/trebuchet-dynamics/flutter-fractal-forge/lib/features/catalog`. Source inspiration: https://github.com/forrestchang/andrej-karpathy-skills at commit `2c60614`.

- Project family: Sidon fractal/rendering and visual-app workspace.
- Local focus: GPU/fractal rendering, Flutter/Electron apps, shaders, accessibility, and measurable visual behavior.
- Stack cues: Flutter/Dart.
- Evidence to prefer: test output, analyzer/linter output, screenshot/pixel checks when relevant, shader compile logs, frame/performance metrics, and exact UI state text.
- Surgical boundary: do not rely on visual vibes; validate rendering numerically and describe results in screen-reader-friendly text.
- Stop and ask when: a visual requirement lacks measurable acceptance criteria or accessibility impact is uncertain.

<!-- karpathy-project-adjustment:end -->
