import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math.dart';
import 'package:flutter_fractals/core/services/storage/history_store.dart';
import 'package:flutter_fractals/features/history/history_entry.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';

HistoryEntry _makeEntry(String id, {String moduleId = 'mandelbrot'}) {
  return HistoryEntry(
    id: id,
    moduleId: moduleId,
    view: FractalViewState(
      pan: Vector2(0.0, 0.0),
      zoom: 1.0,
      rotation: Vector3.zero(),
    ),
    params: {},
    visitedAt: DateTime.utc(2024, 1, 1),
  );
}

void main() {
  group('HistoryStore', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
    });

    test('create() factory returns a valid store', () async {
      final store = await HistoryStore.create();
      expect(store, isNotNull);
    });

    test('loadHistory returns empty list when no data stored', () async {
      final store = await HistoryStore.create();
      expect(store.loadHistory(), isEmpty);
    });

    test('saveHistory and loadHistory round-trip entries', () async {
      final store = await HistoryStore.create();
      final entries = [
        _makeEntry('1', moduleId: 'mandelbrot'),
        _makeEntry('2', moduleId: 'julia'),
      ];

      await store.saveHistory(entries);
      final loaded = store.loadHistory();

      expect(loaded, hasLength(2));
      expect(loaded[0].id, equals('1'));
      expect(loaded[0].moduleId, equals('mandelbrot'));
      expect(loaded[1].id, equals('2'));
      expect(loaded[1].moduleId, equals('julia'));
    });

    test('history entries maintain insertion order', () async {
      final store = await HistoryStore.create();
      final entries = [
        _makeEntry('first', moduleId: 'mandelbrot'),
        _makeEntry('second', moduleId: 'julia'),
        _makeEntry('third', moduleId: 'burning_ship'),
      ];

      await store.saveHistory(entries);
      final loaded = store.loadHistory();

      expect(loaded, hasLength(3));
      expect(loaded[0].id, equals('first'));
      expect(loaded[1].id, equals('second'));
      expect(loaded[2].id, equals('third'));
    });

    test('saveHistory caps oldest-first history to most recent entries',
        () async {
      final store = await HistoryStore.create();
      final entries = [
        for (var i = 0; i < HistoryStore.maxHistoryEntries + 2; i++)
          _makeEntry('history_$i'),
      ];

      await store.saveHistory(entries);
      final loaded = store.loadHistory();

      expect(loaded, hasLength(HistoryStore.maxHistoryEntries));
      expect(loaded.first.id, 'history_2');
      expect(loaded.last.id, 'history_${HistoryStore.maxHistoryEntries + 1}');
    });

    test('loadFavorites returns empty list when no data stored', () async {
      final store = await HistoryStore.create();
      expect(store.loadFavorites(), isEmpty);
    });

    test('addFavorite appends entry to favorites', () async {
      final store = await HistoryStore.create();
      final entry = _makeEntry('fav1');

      await store.addFavorite(entry);
      final favorites = store.loadFavorites();

      expect(favorites, hasLength(1));
      expect(favorites.first.id, equals('fav1'));
    });

    test('addFavorite does not duplicate existing entry', () async {
      final store = await HistoryStore.create();
      final entry = _makeEntry('fav1');

      await store.addFavorite(entry);
      await store.addFavorite(entry);
      final favorites = store.loadFavorites();

      expect(favorites, hasLength(1));
    });

    test('saveFavorites caps oldest-first favorites to most recent entries',
        () async {
      final store = await HistoryStore.create();
      final entries = [
        for (var i = 0; i < HistoryStore.maxFavoriteEntries + 2; i++)
          _makeEntry('favorite_$i'),
      ];

      await store.saveFavorites(entries);
      final loaded = store.loadFavorites();

      expect(loaded, hasLength(HistoryStore.maxFavoriteEntries));
      expect(loaded.first.id, 'favorite_2');
      expect(loaded.last.id, 'favorite_${HistoryStore.maxFavoriteEntries + 1}');
    });

    test('removeFavorite removes entry by ID', () async {
      final store = await HistoryStore.create();
      await store.addFavorite(_makeEntry('fav1'));
      await store.addFavorite(_makeEntry('fav2'));

      await store.removeFavorite('fav1');
      final favorites = store.loadFavorites();

      expect(favorites, hasLength(1));
      expect(favorites.first.id, equals('fav2'));
    });

    test('clearHistory removes all history', () async {
      final store = await HistoryStore.create();
      await store.saveHistory([_makeEntry('1'), _makeEntry('2')]);

      await store.clearHistory();
      expect(store.loadHistory(), isEmpty);
    });

    test('loadHistory handles corrupted JSON gracefully', () async {
      SharedPreferences.setMockInitialValues({
        'exploration_history': 'not valid json {{{',
      });
      final store = await HistoryStore.create();
      expect(store.loadHistory(), isEmpty);
    });

    test('loadHistory skips corrupted individual entries', () async {
      // Valid JSON array but one entry has missing required fields.
      SharedPreferences.setMockInitialValues({
        'exploration_history':
            '[{"id":"1","moduleId":"mandelbrot","view":{"panX":0,"panY":0,"zoom":1,"rotX":0,"rotY":0,"rotZ":0},"params":{},"visitedAt":"2024-01-01T00:00:00.000Z"},{"bad":"entry"}]',
      });
      final store = await HistoryStore.create();
      final loaded = store.loadHistory();
      // The valid entry should be present; the corrupted one silently skipped.
      expect(loaded, hasLength(1));
      expect(loaded.first.id, equals('1'));
    });
  });
}
