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
  static const int _maxFavorites = 500;

  HistoryStore._(this._prefs);

  /// Creates a new [HistoryStore] instance.
  static Future<HistoryStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return HistoryStore._(prefs);
  }

  /// Loads the navigation history.
  ///
  /// Returns entries in chronological order (oldest first).
  List<HistoryEntry> loadHistory() {
    final payload = _prefs.getString(_historyKey);
    return _parseEntries(payload);
  }

  /// Saves the navigation history.
  ///
  /// Automatically trims to [maxHistoryEntries].
  Future<void> saveHistory(List<HistoryEntry> entries) async {
    final trimmed = entries.length > maxHistoryEntries
        ? entries.sublist(entries.length - maxHistoryEntries)
        : entries;
    await _prefs.setString(_historyKey, _serializeEntries(trimmed));
  }

  /// Loads the user's favorite locations.
  List<HistoryEntry> loadFavorites() {
    final payload = _prefs.getString(_favoritesKey);
    return _parseEntries(payload);
  }

  /// Saves the user's favorite locations.
  ///
  /// Capped at [_maxFavorites] to prevent unbounded storage growth.
  Future<void> saveFavorites(List<HistoryEntry> favorites) async {
    final capped = favorites.length > _maxFavorites
        ? favorites.sublist(favorites.length - _maxFavorites)
        : favorites;
    await _prefs.setString(_favoritesKey, _serializeEntries(capped));
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

  List<HistoryEntry> _parseEntries(String? payload) {
    if (payload == null || payload.isEmpty) return [];
    try {
      final decoded = jsonDecode(payload) as List;
      final entries = <HistoryEntry>[];
      for (final item in decoded) {
        try {
          final entry = HistoryEntry.fromJson((item as Map).cast<String, Object?>());
          entries.add(entry);
        } catch (e) {
          // Skip corrupted entry, continue with others
          debugPrint('Failed to parse history entry: $e');
        }
      }
      return entries;
    } catch (e) {
      // Corrupted JSON, return empty list
      debugPrint('Failed to parse history JSON: $e');
      return [];
    }
  }

  String _serializeEntries(List<HistoryEntry> entries) {
    return jsonEncode(entries.map((e) => e.toJson()).toList());
  }
}
