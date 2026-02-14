<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# catalog

## Purpose
Fractal catalog browser screen. Displays all available fractals in a searchable grid with thumbnail previews. Users select a fractal here to open the viewer.

## Key Files

| File | Description |
|------|-------------|
| `fractal_catalog_screen.dart` | `FractalCatalogScreen` - grid of fractal cards with search, category filtering, and thumbnail display |
| `catalog_entry.dart` | `CatalogEntry` - data model for a catalog item (module reference + thumbnail path + metadata) |
| `catalog_repository.dart` | `CatalogRepository` - data layer for catalog entries, manages thumbnail lookup and category grouping |

## For AI Agents

### Working In This Directory
- Thumbnails loaded from `assets/catalog_thumbs/{fractal_id}.png`
- CPU-fallback thumbnails show an approximate indicator (~) when GPU rendering unavailable
- Search filters by fractal name (localized)
- Selecting a catalog entry navigates to FractalViewerScreen

### Testing Requirements
- Widget tests: `test/fractal_catalog_screen_widget_test.dart`, `test/catalog_search_widget_test.dart`
- Data tests: `test/catalog_repository_test.dart`
- Thumbnail audit: `test/catalog_thumbnail_audit_test.dart`

## Dependencies

### Internal
- `core/modules/module_registry.dart` - Source of available fractals
- `viewer/` - Navigation target when fractal selected

<!-- MANUAL: -->
