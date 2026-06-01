import 'dart:convert';

import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/services/history_store.dart';
import 'package:flutter_fractals/features/history/history_entry.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math.dart';

FractalViewState _view(double zoom) {
  return FractalViewState(
    pan: Vector2.zero(),
    zoom: zoom,
    rotation: Vector3.zero(),
  );
}

Map<String, Object?> _entryJson(double zoom) {
  return HistoryEntry.fromState(
    moduleId: 'mandelbrot',
    view: _view(zoom),
    params: const <String, Object>{'iterations': 100},
  ).toJson();
}

Future<void> _recordAndFlush(
  WidgetTester tester,
  HistoryProvider provider, {
  required double zoom,
}) async {
  provider.recordLocation(
    moduleId: 'mandelbrot',
    view: _view(zoom),
    params: const <String, Object>{'iterations': 100},
  );
  await tester.pump(const Duration(milliseconds: 501));
}

void main() {
  group('HistoryProvider navigation recording', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets(
        'replaying the current back entry does not truncate forward history',
        (tester) async {
      final store = await HistoryStore.create();
      final provider = HistoryProvider(store: store);
      addTearDown(provider.dispose);

      await _recordAndFlush(tester, provider, zoom: 1);
      await _recordAndFlush(tester, provider, zoom: 2);
      await _recordAndFlush(tester, provider, zoom: 3);

      final restored = provider.goBack();
      expect(restored, isNotNull);
      expect(provider.currentPosition, 2);
      expect(provider.canGoForward, isTrue);

      await _recordAndFlush(tester, provider, zoom: 2);

      expect(provider.historyCount, 3);
      expect(provider.currentPosition, 2);
      expect(provider.canGoForward, isTrue);
      expect(provider.currentEntry, same(restored));
    });

    testWidgets('history navigation cancels pending pre-navigation records',
        (tester) async {
      final store = await HistoryStore.create();
      final provider = HistoryProvider(store: store);
      addTearDown(provider.dispose);

      await _recordAndFlush(tester, provider, zoom: 1);
      await _recordAndFlush(tester, provider, zoom: 2);

      provider.recordLocation(
        moduleId: 'mandelbrot',
        view: _view(3),
        params: const <String, Object>{'iterations': 100},
      );

      final restored = provider.goBack();
      expect(restored, isNotNull);
      expect(restored!.view.zoom, 1);
      expect(provider.currentPosition, 1);
      expect(provider.canGoForward, isTrue);

      await tester.pump(const Duration(milliseconds: 501));

      expect(provider.historyCount, 2);
      expect(provider.currentPosition, 1);
      expect(provider.currentEntry, same(restored));
      expect(provider.canGoForward, isTrue);
      expect(provider.history.map((entry) => entry.view.zoom), [1, 2]);
    });

    testWidgets('records the state passed to the debounced record call',
        (tester) async {
      final store = await HistoryStore.create();
      final provider = HistoryProvider(store: store);
      addTearDown(provider.dispose);

      final pan = Vector2(1, 2);
      final rotation = Vector3(3, 4, 5);
      final params = <String, Object>{'iterations': 100};
      provider.recordLocation(
        moduleId: 'mandelbrot',
        view: FractalViewState(pan: pan, zoom: 6, rotation: rotation),
        params: params,
      );

      pan.setValues(7, 8);
      rotation.setValues(9, 10, 11);
      params['iterations'] = 250;
      await tester.pump(const Duration(milliseconds: 501));

      final entry = provider.currentEntry;
      expect(entry, isNotNull);
      expect(entry!.view.pan.x, 1);
      expect(entry.view.pan.y, 2);
      expect(entry.view.rotation.x, 3);
      expect(entry.view.rotation.y, 4);
      expect(entry.view.rotation.z, 5);
      expect(entry.params, {'iterations': 100});
    });

    testWidgets('keeps in-memory history capped to the persisted max depth',
        (tester) async {
      final store = await HistoryStore.create();
      final provider = HistoryProvider(store: store);
      addTearDown(provider.dispose);

      for (var i = 0; i < HistoryStore.maxHistoryEntries + 2; i++) {
        await _recordAndFlush(tester, provider, zoom: i + 1.0);
      }

      expect(provider.historyCount, HistoryStore.maxHistoryEntries);
      expect(provider.currentPosition, HistoryStore.maxHistoryEntries);
      expect(provider.history.first.view.zoom, 3.0);
      expect(provider.currentEntry!.view.zoom, 102.0);
    });

    testWidgets('keeps in-memory favorites capped to persisted max depth',
        (tester) async {
      final store = await HistoryStore.create();
      final provider = HistoryProvider(store: store);
      addTearDown(provider.dispose);

      await _recordAndFlush(tester, provider, zoom: 1);

      for (var i = 0; i < HistoryStore.maxFavoriteEntries + 2; i++) {
        await provider.saveCurrentAsFavorite('favorite $i');
      }

      expect(provider.favoritesCount, HistoryStore.maxFavoriteEntries);
      expect(provider.favorites.first.name, 'favorite 2');
      expect(provider.favorites.last.name, 'favorite 501');
      expect(store.loadFavorites().length, HistoryStore.maxFavoriteEntries);
    });

    testWidgets('restored history and favorites are capped before display',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'exploration_history': jsonEncode([
          for (var i = 0; i < HistoryStore.maxHistoryEntries + 2; i++)
            _entryJson(i + 1.0),
        ]),
        'exploration_favorites': jsonEncode([
          for (var i = 0; i < HistoryStore.maxFavoriteEntries + 2; i++)
            _entryJson(i + 1.0),
        ]),
      });

      final store = await HistoryStore.create();
      final provider = HistoryProvider(store: store);
      addTearDown(provider.dispose);

      expect(provider.historyCount, HistoryStore.maxHistoryEntries);
      expect(provider.currentPosition, HistoryStore.maxHistoryEntries);
      expect(provider.history.first.view.zoom, 3.0);
      expect(provider.currentEntry!.view.zoom, 102.0);
      expect(provider.favoritesCount, HistoryStore.maxFavoriteEntries);
      expect(provider.favorites.first.view.zoom, 3.0);
      expect(provider.favorites.last.view.zoom, 502.0);
    });

    testWidgets('clearHistory cancels pending debounced records',
        (tester) async {
      final store = await HistoryStore.create();
      final provider = HistoryProvider(store: store);
      addTearDown(provider.dispose);

      provider.recordLocation(
        moduleId: 'mandelbrot',
        view: _view(6),
        params: const <String, Object>{'iterations': 100},
      );
      await provider.clearHistory();
      await tester.pump(const Duration(milliseconds: 501));

      expect(provider.historyCount, 0);
      expect(provider.currentEntry, isNull);
      expect(store.loadHistory(), isEmpty);
    });
  });
}
