<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# wallpaper

## Purpose
Wallpaper export options for setting fractal images as device wallpaper.

## Key Files

| File | Description |
|------|-------------|
| `wallpaper_options_sheet.dart` | `WallpaperOptionsSheet` - bottom sheet for wallpaper export with screen type selection (home, lock, both) |

## For AI Agents

### Working In This Directory
- Uses `WallpaperService` to set the wallpaper via platform channel
- Resolution matched to device screen dimensions

## Dependencies

### Internal
- `core/services/wallpaper_service.dart` - Platform wallpaper API
- `core/services/export_service.dart` - Image capture

<!-- MANUAL: -->
