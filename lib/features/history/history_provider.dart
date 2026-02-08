import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/services/history_store.dart';
import 'package:flutter_fractals/features/history/history_entry.dart';
import 'package:flutter_fractals/features/renderer/providers/fractal_provider.dart';

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
    _history = _store.loadHistory();
    _favorites = _store.loadFavorites();
    _currentIndex = _history.isEmpty ? -1 : _history.length - 1;
    if (_history.isNotEmpty) {
      _lastRecorded = _history.last;
    }
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
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      _doRecordLocation(moduleId, view, params);
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

    // If we're not at the end of history, truncate forward history
    if (_currentIndex >= 0 && _currentIndex < _history.length - 1) {
      _history = _history.sublist(0, _currentIndex + 1);
    }

    _history.add(entry);
    _currentIndex = _history.length - 1;
    _lastRecorded = entry;

    _store.saveHistory(_history);
    notifyListeners();
  }

  /// Navigates back to the previous location in history.
  ///
  /// Returns the entry to navigate to, or null if [canGoBack] is false.
  HistoryEntry? goBack() {
    if (!canGoBack) return null;
    _currentIndex--;
    notifyListeners();
    return _history[_currentIndex];
  }

  /// Navigates forward to the next location in history.
  ///
  /// Returns the entry to navigate to, or null if [canGoForward] is false.
  HistoryEntry? goForward() {
    if (!canGoForward) return null;
    _currentIndex++;
    notifyListeners();
    return _history[_currentIndex];
  }

  /// Jumps to a specific entry in history by index.
  HistoryEntry? jumpToIndex(int index) {
    if (index < 0 || index >= _history.length) return null;
    _currentIndex = index;
    notifyListeners();
    return _history[_currentIndex];
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
    
    _favorites.add(favorite);
    await _store.saveFavorites(_favorites);
    notifyListeners();
  }

  /// Saves a specific entry as a favorite.
  Future<void> saveAsFavorite(HistoryEntry entry, String name) async {
    final favorite = entry.copyWith(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      visitedAt: DateTime.now(),
    );
    
    _favorites.add(favorite);
    await _store.saveFavorites(_favorites);
    notifyListeners();
  }

  /// Removes a favorite by ID.
  Future<void> removeFavorite(String favoriteId) async {
    _favorites.removeWhere((f) => f.id == favoriteId);
    await _store.saveFavorites(_favorites);
    notifyListeners();
  }

  /// Renames a favorite.
  Future<void> renameFavorite(String favoriteId, String newName) async {
    final index = _favorites.indexWhere((f) => f.id == favoriteId);
    if (index < 0) return;
    
    _favorites[index] = _favorites[index].copyWith(name: newName);
    await _store.saveFavorites(_favorites);
    notifyListeners();
  }

  /// Checks if the current location is saved as a favorite.
  bool isCurrentFavorite() {
    if (currentEntry == null) return false;
    return _favorites.any((f) => f.isSameLocation(currentEntry!));
  }

  /// Clears all history.
  Future<void> clearHistory() async {
    _history.clear();
    _currentIndex = -1;
    _lastRecorded = null;
    await _store.clearHistory();
    notifyListeners();
  }

  /// Clears all favorites.
  Future<void> clearFavorites() async {
    _favorites.clear();
    await _store.clearFavorites();
    notifyListeners();
  }

  /// Applies a history entry to a FractalController.
  void applyToController(HistoryEntry entry, FractalController controller) {
    // Update parameters
    for (final paramEntry in entry.params.entries) {
      try {
        controller.updateParam(paramEntry.key, paramEntry.value);
      } catch (_) {
        // Parameter may not exist in current module
      }
    }
    
    // Update view state
    controller.updateZoom(entry.view.zoom);
    controller.updatePan(entry.view.pan);
    controller.updateRotation(entry.view.rotation);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
