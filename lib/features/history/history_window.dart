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
