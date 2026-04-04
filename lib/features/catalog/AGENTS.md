<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-03-21 -->

# catalog

## Purpose
Fractal catalog browser screen. Displays the current module registry in a searchable grid or list, with featured entries, dimension filtering, category chips, sort order, and persisted view mode preference.

## Key Files

| File | Description |
|------|-------------|
| `fractal_catalog_screen.dart` | Main catalog UI; handles search, filters, sort, category scoping, grid/list layout, and navigation into the viewer |
| `catalog_entry.dart` | `CatalogEntry` - data model for a catalog item (module reference + thumbnail path + metadata) |
| `catalog_repository.dart` | Builds stable `catalogId` entries from `ModuleRegistry` and assigns aliases/category metadata |
| `catalog_screen_data.dart` | Immutable presentation model and builder for filtered/grouped catalog state |
| `catalog_view_mode_store.dart` | SharedPreferences-backed persistence for the grid/list preference |

## For AI Agents

### Working In This Directory
- Stable IDs are `core.{moduleId}` so future catalog refactors do not break persisted references
- Search matches localized names, aliases, category text, and the stable catalog IDs
- Supporting chrome is intentionally reduced while the search field is focused
- The screen chooses between grid and list layouts and persists that preference through `CatalogViewModeStore`
- Selecting a catalog entry navigates to FractalViewerScreen

### Testing Requirements
- Widget tests: `test/fractal_catalog_screen_widget_test.dart`
- Data tests: `test/catalog_screen_data_test.dart`, `test/catalog_view_mode_store_test.dart`, `test/catalog_id_integrity_test.dart`

## Dependencies

### Internal
- `core/modules/module_registry.dart` - Source of available fractals
- `viewer/` - Navigation target when fractal selected

<!-- MANUAL: -->
