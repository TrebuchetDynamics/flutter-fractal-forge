import 'package:flutter_fractals/features/history/history_entry.dart';

/// Pure favorite-list append policy shared by provider mutations.
///
/// Persistence caps favorites to keep local storage bounded. The provider must
/// apply the same cap before notifying listeners so in-memory UI state and the
/// next app launch agree about which favorites still exist.
class HistoryFavoritesPolicy {
  const HistoryFavoritesPolicy._();

  static List<HistoryEntry> append({
    required List<HistoryEntry> favorites,
    required HistoryEntry favorite,
    required int maxFavorites,
  }) {
    assert(maxFavorites > 0);

    final nextFavorites = List<HistoryEntry>.of(favorites)..add(favorite);
    if (nextFavorites.length > maxFavorites) {
      nextFavorites.removeRange(0, nextFavorites.length - maxFavorites);
    }
    return nextFavorites;
  }
}
