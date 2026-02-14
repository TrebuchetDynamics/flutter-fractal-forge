<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-13 | Updated: 2026-02-13 -->

# history

## Purpose
Exploration history tracking and browsing. Records fractal configurations as the user explores, enabling undo/redo and history browsing.

## Key Files

| File | Description |
|------|-------------|
| `history.dart` | Core history data structures and operations |
| `history_entry.dart` | `HistoryEntry` - single history record (module + params + view state + timestamp) |
| `history_provider.dart` | `HistoryProvider` - ChangeNotifier managing the history list with undo/redo |
| `history_sheet.dart` | `HistorySheet` - bottom sheet UI for browsing and restoring history entries |

## For AI Agents

### Working In This Directory
- History is per-session (not persisted across app restarts by default)
- `HistoryProvider` wraps `HistoryStore` for reactive updates
- Maximum history depth is configurable
- Each entry captures full state snapshot for exact restoration

## Dependencies

### Internal
- `core/services/history_store.dart` - Persistence layer
- `core/models/fractal_preset.dart` - Snapshot format

<!-- MANUAL: -->
