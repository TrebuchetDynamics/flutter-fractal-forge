import 'dart:async' show Timer, unawaited;
import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/services/storage/history_store.dart';
import 'package:flutter_fractals/features/history/history_entry.dart';
import 'package:flutter_fractals/features/history/history_favorites.dart';
import 'package:flutter_fractals/features/history/history_location.dart';
import 'package:flutter_fractals/features/history/history_replay.dart';
import 'package:flutter_fractals/features/history/history_window.dart';

/// Manages exploration history with back/forward navigation and favorites.
///
/// [HistoryProvider] tracks the user's journey through fractal space,
/// allowing them to:
/// - Navigate back to previously visited locations
/// - Navigate forward after going back
/// - Save favorite spots with custom names
/// - View and jump to any point in history
///
/// History is automatically persisted to local storage.
///
/// {@category State Management}
///
/// Example usage:
/// ```dart
/// final history = HistoryProvider(store: historyStore);
///
/// // Record current location
/// history.recordLocation(
///   moduleId: 'mandelbrot',
///   view: controller.view,
///   params: controller.params,
/// );
///
/// // Navigate back
/// if (history.canGoBack) {
///   final entry = history.goBack();
///   // Apply entry to controller
/// }
/// ```
class HistoryProvider extends ChangeNotifier {
  final HistoryStore _store;

  /// All recorded history entries (oldest first).
  List<HistoryEntry> _history = [];

  /// Current position in history (index into _history).
  /// -1 means no history, 0+ is the index.
  int _currentIndex = -1;

  /// User's saved favorite locations.
  List<HistoryEntry> _favorites = [];

  /// Debounce timer to avoid recording too many entries during quick navigation.
  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  /// Last recorded state to detect meaningful changes.
  HistoryEntry? _lastRecorded;

  bool _disposed = false;

  void _notifyIfAlive() {
    if (!_disposed) notifyListeners();
  }

  /// Creates a new [HistoryProvider].
  HistoryProvider({required HistoryStore store}) : _store = store {
    _loadFromStorage();
  }

  /// Whether navigation to a previous location is possible.
  bool get canGoBack => _currentIndex > 0;

  /// Whether navigation to a later location is possible.
  ///
  /// Only available after going back.
  bool get canGoForward => _currentIndex < _history.length - 1;

  /// The current history entry, if any.
  HistoryEntry? get currentEntry =>
      _currentIndex >= 0 && _currentIndex < _history.length
          ? _history[_currentIndex]
          : null;

  /// All history entries (oldest first).
  List<HistoryEntry> get history => List.unmodifiable(_history);

  /// Number of entries in history.
  int get historyCount => _history.length;

  /// Current position in history (1-indexed for display).
  int get currentPosition => _currentIndex + 1;

  /// All saved favorites.
  List<HistoryEntry> get favorites => List.unmodifiable(_favorites);

  /// Number of saved favorites.
  int get favoritesCount => _favorites.length;

  void _loadFromStorage() {
    final restored = HistoryRestorePolicy.restore(
      history: _store.loadHistory(),
      favorites: _store.loadFavorites(),
      maxHistoryEntries: HistoryStore.maxHistoryEntries,
      maxFavoriteEntries: HistoryStore.maxFavoriteEntries,
    );
    _history = restored.history;
    _favorites = restored.favorites;
    _currentIndex = restored.currentIndex;
    _lastRecorded = restored.currentEntry;
  }

  /// Records the current location in history.
  ///
  /// If the user has gone back and then makes a change,
  /// forward history is discarded (like a browser).
  ///
  /// Debounces rapid changes to avoid cluttering history
  /// with intermediate positions during smooth navigation.
  void recordLocation({
    required String moduleId,
    required FractalViewState view,
    required Map<String, Object> params,
  }) {
    final viewSnapshot = snapshotHistoryView(view);
    final paramsSnapshot = snapshotHistoryParams(params);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      _doRecordLocation(moduleId, viewSnapshot, paramsSnapshot);
    });
  }

  void _doRecordLocation(
    String moduleId,
    FractalViewState view,
    Map<String, Object> params,
  ) {
    final entry = HistoryEntry.fromState(
      moduleId: moduleId,
      view: view,
      params: params,
    );

    // Skip if essentially the same location as the last entry
    if (_lastRecorded != null && _lastRecorded!.isSameLocation(entry)) {
      return;
    }

    final window = HistoryWindowPolicy.append(
      entries: _history,
      currentIndex: _currentIndex,
      entry: entry,
      maxEntries: HistoryStore.maxHistoryEntries,
    );
    _history = window.entries;
    _currentIndex = window.currentIndex;
    _lastRecorded = entry;

    unawaited(_store.saveHistory(_history));
    _notifyIfAlive();
  }

  /// Navigates back to the previous location in history.
  ///
  /// Returns the entry to navigate to, or null if [canGoBack] is false.
  HistoryEntry? goBack() {
    if (!canGoBack) return null;
    return jumpToIndex(_currentIndex - 1);
  }

  /// Navigates forward to the next location in history.
  ///
  /// Returns the entry to navigate to, or null if [canGoForward] is false.
  HistoryEntry? goForward() {
    if (!canGoForward) return null;
    return jumpToIndex(_currentIndex + 1);
  }

  /// Jumps to a specific entry in history by index.
  HistoryEntry? jumpToIndex(int index) {
    if (index < 0 || index >= _history.length) return null;
    _selectHistoryIndex(index);
    _notifyIfAlive();
    return _history[_currentIndex];
  }

  void _selectHistoryIndex(int index) {
    assert(index >= 0 && index < _history.length);
    // A debounced record captures pre-navigation controller state. If it fires
    // after an explicit history jump, it can silently truncate forward history
    // and move the current entry away from the user's selected replay point.
    cancelPendingRecord();
    _currentIndex = index;
    _lastRecorded = _history[index];
  }

  /// Jumps to a specific entry in history by ID.
  HistoryEntry? jumpToEntry(String entryId) {
    final index = _history.indexWhere((e) => e.id == entryId);
    if (index < 0) return null;
    return jumpToIndex(index);
  }

  /// Saves the current location as a favorite.
  ///
  /// Creates a named copy of the current history entry.
  Future<void> saveCurrentAsFavorite(String name) async {
    if (currentEntry == null) return;

    final favorite = currentEntry!.copyWith(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      visitedAt: DateTime.now(),
    );

    _favorites = HistoryFavoritesPolicy.append(
      favorites: _favorites,
      favorite: favorite,
      maxFavorites: HistoryStore.maxFavoriteEntries,
    );
    await _store.saveFavorites(_favorites);
    _notifyIfAlive();
  }

  /// Saves a specific entry as a favorite.
  Future<void> saveAsFavorite(HistoryEntry entry, String name) async {
    final favorite = entry.copyWith(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      visitedAt: DateTime.now(),
    );

    _favorites = HistoryFavoritesPolicy.append(
      favorites: _favorites,
      favorite: favorite,
      maxFavorites: HistoryStore.maxFavoriteEntries,
    );
    await _store.saveFavorites(_favorites);
    _notifyIfAlive();
  }

  /// Removes a favorite by ID.
  Future<void> removeFavorite(String favoriteId) async {
    _favorites.removeWhere((f) => f.id == favoriteId);
    await _store.saveFavorites(_favorites);
    _notifyIfAlive();
  }

  /// Renames a favorite.
  Future<void> renameFavorite(String favoriteId, String newName) async {
    final index = _favorites.indexWhere((f) => f.id == favoriteId);
    if (index < 0) return;

    _favorites[index] = _favorites[index].copyWith(name: newName);
    await _store.saveFavorites(_favorites);
    _notifyIfAlive();
  }

  /// Checks if the current location is saved as a favorite.
  bool isCurrentFavorite() {
    if (currentEntry == null) return false;
    return _favorites.any((f) => f.isSameLocation(currentEntry!));
  }

  void _clearInMemoryHistory() {
    cancelPendingRecord();
    _history.clear();
    _currentIndex = -1;
    _lastRecorded = null;
  }

  /// Clears all history.
  Future<void> clearHistory() async {
    _clearInMemoryHistory();
    await _store.clearHistory();
    _notifyIfAlive();
  }

  /// Clears all favorites.
  Future<void> clearFavorites() async {
    _favorites.clear();
    await _store.clearFavorites();
    _notifyIfAlive();
  }

  /// Applies a history entry to a controller-like object.
  ///
  /// Complete-state controllers should expose `loadState` so replay switches to
  /// the recorded module before applying module-specific params. Legacy test
  /// doubles without `loadState` keep the old structural update sequence.
  void applyToController(HistoryEntry entry, Object controller) {
    applyHistoryEntryToController(entry, controller);
  }

  /// Cancels any pending debounced history record.
  void cancelPendingRecord() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  @override
  void dispose() {
    _disposed = true;
    cancelPendingRecord();
    super.dispose();
  }
}
