import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/features/history/history_entry.dart';

/// Persists exploration history and favorites to local storage.
///
/// History entries are stored in SharedPreferences as JSON.
/// Maintains separate storage for:
/// - Navigation history (limited size, auto-trimmed)
/// - Favorites (unlimited, user-managed)
///
/// {@category Services}
class HistoryStore {
  final SharedPreferences _prefs;

  static const String _historyKey = 'exploration_history';
  static const String _favoritesKey = 'exploration_favorites';
  static const int maxHistoryEntries = 100;
  static const int maxFavoriteEntries = 500;

  HistoryStore._(this._prefs);

  /// Creates a new [HistoryStore] instance.
  static Future<HistoryStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return HistoryStore._(prefs);
  }

  /// Loads the navigation history.
  ///
  /// Returns entries in chronological order (oldest first).
  List<HistoryEntry> loadHistory() => _loadEntries(_historySlot);

  /// Saves the navigation history.
  ///
  /// Automatically trims to [maxHistoryEntries].
  Future<void> saveHistory(List<HistoryEntry> entries) async {
    await _saveEntries(_historySlot, entries);
  }

  /// Loads the user's favorite locations.
  List<HistoryEntry> loadFavorites() => _loadEntries(_favoritesSlot);

  /// Saves the user's favorite locations.
  ///
  /// Capped at [maxFavoriteEntries] to prevent unbounded storage growth.
  Future<void> saveFavorites(List<HistoryEntry> favorites) async {
    await _saveEntries(_favoritesSlot, favorites);
  }

  /// Adds an entry to favorites.
  Future<void> addFavorite(HistoryEntry entry) async {
    final favorites = loadFavorites();
    // Check if already exists by ID
    if (favorites.any((f) => f.id == entry.id)) return;
    favorites.add(entry);
    await saveFavorites(favorites);
  }

  /// Removes an entry from favorites by ID.
  Future<void> removeFavorite(String entryId) async {
    final favorites = loadFavorites();
    final updated = favorites.where((f) => f.id != entryId).toList();
    await saveFavorites(updated);
  }

  /// Clears all navigation history.
  Future<void> clearHistory() async {
    await _prefs.remove(_historyKey);
  }

  /// Clears all favorites.
  Future<void> clearFavorites() async {
    await _prefs.remove(_favoritesKey);
  }

  List<HistoryEntry> _loadEntries(_HistoryStoreSlot slot) {
    final payload = _prefs.getString(slot.key);
    return _HistoryEntryCodec.parse(payload, slotLabel: slot.label);
  }

  Future<void> _saveEntries(
    _HistoryStoreSlot slot,
    List<HistoryEntry> entries,
  ) async {
    final bounded = slot.mostRecent(entries);
    await _prefs.setString(slot.key, _HistoryEntryCodec.serialize(bounded));
  }
}

const _historySlot = _HistoryStoreSlot(
  key: HistoryStore._historyKey,
  label: 'history',
  maxEntries: HistoryStore.maxHistoryEntries,
);

const _favoritesSlot = _HistoryStoreSlot(
  key: HistoryStore._favoritesKey,
  label: 'favorites',
  maxEntries: HistoryStore.maxFavoriteEntries,
);

/// Storage contract for one SharedPreferences-backed history collection.
///
/// Entries are expected oldest-first. When a slot exceeds its cap, the oldest
/// entries are dropped and the most recent tail is retained.
class _HistoryStoreSlot {
  final String key;
  final String label;
  final int maxEntries;

  const _HistoryStoreSlot({
    required this.key,
    required this.label,
    required this.maxEntries,
  }) : assert(maxEntries > 0);

  List<HistoryEntry> mostRecent(List<HistoryEntry> entries) {
    if (entries.length <= maxEntries) return entries;
    return entries.sublist(entries.length - maxEntries);
  }
}

class _HistoryEntryCodec {
  const _HistoryEntryCodec._();

  static List<HistoryEntry> parse(String? payload,
      {required String slotLabel}) {
    if (payload == null || payload.isEmpty) return [];
    try {
      final decoded = jsonDecode(payload) as List;
      final entries = <HistoryEntry>[];
      for (final item in decoded) {
        try {
          final entry =
              HistoryEntry.fromJson((item as Map).cast<String, Object?>());
          entries.add(entry);
        } catch (e) {
          // Skip corrupted entry, continue with others.
          if (kDebugMode) {
            debugPrint('Failed to parse $slotLabel entry: $e');
          }
        }
      }
      return entries;
    } catch (e) {
      // Corrupted JSON, return empty list.
      if (kDebugMode) debugPrint('Failed to parse $slotLabel JSON: $e');
      return [];
    }
  }

  static String serialize(List<HistoryEntry> entries) {
    return jsonEncode(entries.map((e) => e.toJson()).toList());
  }
}
