import 'package:flutter_fractals/features/history/history_entry.dart';

/// Result of applying a history-list mutation.
class HistoryWindow {
  /// History entries in display order (oldest first).
  final List<HistoryEntry> entries;

  /// Current selected index into [entries], or -1 when empty.
  final int currentIndex;

  const HistoryWindow({
    required this.entries,
    required this.currentIndex,
  });
}

/// Restored history and favorite lists after applying in-memory caps.
class HistoryRestoreSnapshot {
  final List<HistoryEntry> history;
  final int currentIndex;
  final List<HistoryEntry> favorites;

  const HistoryRestoreSnapshot({
    required this.history,
    required this.currentIndex,
    required this.favorites,
  });

  HistoryEntry? get currentEntry =>
      currentIndex >= 0 && currentIndex < history.length
          ? history[currentIndex]
          : null;
}

/// Pure storage-restore policy shared by provider boot and tests.
///
/// Storage writes are capped, but older/corrupted preferences can still contain
/// too many entries. Normalize immediately so first-frame UI state matches the
/// same bounded contract as persisted writes.
class HistoryRestorePolicy {
  const HistoryRestorePolicy._();

  static HistoryRestoreSnapshot restore({
    required List<HistoryEntry> history,
    required List<HistoryEntry> favorites,
    required int maxHistoryEntries,
    required int maxFavoriteEntries,
  }) {
    assert(maxHistoryEntries > 0);
    assert(maxFavoriteEntries > 0);

    final restoredHistory = _mostRecent(history, maxHistoryEntries);
    return HistoryRestoreSnapshot(
      history: restoredHistory,
      currentIndex: restoredHistory.isEmpty ? -1 : restoredHistory.length - 1,
      favorites: _mostRecent(favorites, maxFavoriteEntries),
    );
  }

  static List<HistoryEntry> _mostRecent(
    List<HistoryEntry> entries,
    int maxEntries,
  ) {
    if (entries.length <= maxEntries) return List<HistoryEntry>.of(entries);
    return entries.sublist(entries.length - maxEntries);
  }
}

/// Pure history append policy shared by recording and tests.
///
/// The in-memory provider must enforce the same maximum depth as persistence;
/// otherwise entries silently disappear only after app restart.
class HistoryWindowPolicy {
  const HistoryWindowPolicy._();

  static HistoryWindow append({
    required List<HistoryEntry> entries,
    required int currentIndex,
    required HistoryEntry entry,
    required int maxEntries,
  }) {
    assert(maxEntries > 0);

    final nextEntries = currentIndex >= 0 && currentIndex < entries.length - 1
        ? entries.sublist(0, currentIndex + 1)
        : List<HistoryEntry>.of(entries);

    nextEntries.add(entry);

    if (nextEntries.length > maxEntries) {
      nextEntries.removeRange(0, nextEntries.length - maxEntries);
    }

    return HistoryWindow(
      entries: nextEntries,
      currentIndex: nextEntries.length - 1,
    );
  }
}
