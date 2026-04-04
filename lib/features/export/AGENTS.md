<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-03-21 -->

# export

## Purpose
Export-related UI and helper surfaces. The current viewer release is centered on still-image export; this directory also contains batch export and video/GIF scaffolding that is not the primary shipped flow.

## Key Files

| File | Description |
|------|-------------|
| `export_options_sheet.dart` | `ExportOptionsSheet` - bottom sheet for single-image export (resolution, transparency, format) |
| `video_export_sheet.dart` | Minimal UI scaffold for video/GIF export options |
| `batch_export_dialog.dart` | `BatchExportDialog` - dialog for exporting multiple fractals at once |

## For AI Agents

### Working In This Directory
- Export uses `RenderRepaintBoundary` to capture the rendered fractal
- Transparent PNG export sets alpha=0 for background pixels
- Video/GIF code exists, but store-facing docs should not assume it is part of the current primary release flow
- Batch export iterates through selected modules

### Testing Requirements
- `test/export_options_sheet_widget_test.dart`
- `test/export_service_test.dart`, `test/export_options_test.dart`

## Dependencies

### Internal
- `core/services/export_service.dart` - Export business logic
- `core/services/video_export_service.dart` - Video encoding
- `core/services/batch_export_service.dart` - Multi-fractal export
- `core/models/export_options.dart` - Export configuration model

<!-- MANUAL: -->
