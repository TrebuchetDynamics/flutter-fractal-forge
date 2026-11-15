import 'dart:async';
import 'dart:convert';

import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/services/storage/history_store.dart';
import 'package:flutter_fractals/core/models/history/history_entry.dart';
import 'package:flutter_fractals/features/history/history_provider.dart';
import 'package:flutter_fractals/core/controllers/fractal_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math_64.dart';

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

final class _LegacyReplayController {
  final params = <String, Object>{};
  double? zoom;
  Vector2? pan;
  Vector3? rotation;

  void updateParam(String id, Object value) {
    params[id] = value;
  }

  void updateZoom(double value) {
    zoom = value;
  }

  void updatePan(Vector2 value) {
    pan = Vector2.copy(value);
  }

  void updateRotation(Vector3 value) {
    rotation = Vector3.copy(value);
  }
}

// Gate the real controller commit seam, not a simulated provider outcome.
class _ControlledReplayController extends FractalController {
  _ControlledReplayController() : super(ModuleRegistry());

  Completer<void>? gate;

  @override
  Future<bool> loadState({
    FractalModule? module,
    String? moduleId,
    required Map<String, Object> params,
    required FractalViewState view,
    bool transparentBackground = false,
    bool animateModule = false,
    void Function()? onCommitted,
    bool Function()? shouldCommit,
  }) async {
    final pending = gate;
    if (pending != null) await pending.future;
    return super.loadState(
      module: module,
      moduleId: moduleId,
      params: params,
      view: view,
      transparentBackground: transparentBackground,
      animateModule: animateModule,
      onCommitted: onCommitted,
      shouldCommit: shouldCommit,
    );
  }
}

void _recordController(HistoryProvider provider, FractalController controller) {
  provider.recordLocation(
      moduleId: controller.module.id,
      view: controller.view,
      params: controller.params);
}

void main() {
  group('HistoryProvider navigation recording', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets(
        'pending rejected replay keeps the committed cursor and forward entries',
        (tester) async {
      final store = await HistoryStore.create();
      final provider = HistoryProvider(store: store);
      final controller = _ControlledReplayController();
      addTearDown(provider.dispose);
      addTearDown(controller.dispose);
      await _recordAndFlush(tester, provider, zoom: 1);
      provider.recordLocation(
        moduleId: 'number_wall',
        view: _view(2),
        params: const {'prime': '15'},
      );
      await tester.pump(const Duration(milliseconds: 501));
      await _recordAndFlush(tester, provider, zoom: 3);
      await _recordAndFlush(tester, provider, zoom: 4);
      provider.goBack();
      await controller.loadState(
          moduleId: 'mandelbrot',
          params: const {'iterations': 100},
          view: _view(3));
      controller.addListener(() => _recordController(provider, controller));
      final committed = provider.currentEntry;
      final ids = provider.history.map((e) => e.id).toList();
      final persisted =
          jsonEncode(store.loadHistory().map((e) => e.toJson()).toList());
      controller.gate = Completer<void>();
      final replay = provider.replayBack(controller);
      expect(provider.currentEntry, same(committed));
      expect(provider.currentPosition, 3);
      expect(provider.canGoForward, isTrue);
      controller.notifyListeners(); // Unchanged pending status must not record.
      await tester.pump(const Duration(milliseconds: 501));
      expect(provider.history.map((e) => e.id), ids);
      expect(provider.currentEntry, same(committed));
      await provider.saveCurrentAsFavorite('during pending');
      expect(provider.favorites.single.view.zoom, 3);
      controller.gate!.complete();
      await tester.pump();
      expect(await replay, isFalse);
      await tester.pump(const Duration(milliseconds: 501));
      expect(controller.module.id, 'mandelbrot');
      expect(controller.view.zoom, 3);
      expect(provider.currentEntry, same(committed));
      expect(provider.history.map((e) => e.id), ids);
      expect(jsonEncode(store.loadHistory().map((e) => e.toJson()).toList()),
          persisted);
    });

    testWidgets(
        'accepted normalized entries select before observers without truncation',
        (tester) async {
      final store = await HistoryStore.create();
      final provider = HistoryProvider(store: store);
      final controller = _ControlledReplayController();
      addTearDown(provider.dispose);
      addTearDown(controller.dispose);
      await _recordAndFlush(tester, provider, zoom: 1);
      provider.recordLocation(
          moduleId: 'julia',
          view: _view(2),
          params: const {'iterations': 999999999});
      await tester.pump(const Duration(milliseconds: 501));
      await _recordAndFlush(tester, provider, zoom: 3);
      final target = provider.history[1];
      final original = jsonEncode(target.toJson());
      controller.addListener(() {
        expectSync(provider.currentEntry, same(target));
        expectSync(provider.currentPosition, 2);
        _recordController(provider, controller);
      });
      controller.gate = Completer<void>();
      final replay = provider.replayBack(controller);
      expect(provider.currentPosition, 3);
      controller.gate!.complete();
      await tester.pump();
      expect(await replay, isTrue);
      expect(controller.module.id, 'julia');
      expect(controller.params['iterations'], isNot(999999999));
      await tester.pump(const Duration(milliseconds: 501));
      expect(provider.historyCount, 3);
      expect(provider.canGoForward, isTrue);
      expect(jsonEncode(target.toJson()), original);
      expect(store.loadHistory().length, 3);
    });

    testWidgets(
        'repeated pending Back resolves committed cursor and newest wins',
        (tester) async {
      final provider = HistoryProvider(store: await HistoryStore.create());
      final controller = _ControlledReplayController();
      addTearDown(provider.dispose);
      addTearDown(controller.dispose);
      for (final zoom in [1.0, 2.0, 3.0]) {
        await _recordAndFlush(tester, provider, zoom: zoom);
      }
      final oldGate = Completer<void>();
      controller.gate = oldGate;
      final old = provider.replayBack(controller);
      controller.gate = Completer<void>();
      final newest = provider.replayBack(controller);
      controller.gate!.complete();
      await tester.pump();
      expect(await newest, isTrue);
      expect(provider.currentPosition, 2);
      expect(controller.view.zoom, 2);
      oldGate.complete();
      await tester.pump();
      expect(await old, isFalse);
      expect(provider.currentPosition, 2);
      controller.gate = null;
      expect(await provider.replayForward(controller), isTrue);
      expect(provider.currentPosition, 3);
      expect(await provider.replayEntry(provider.history.first, controller),
          isTrue);
      expect(provider.currentPosition, 1);
    });

    for (final interruption in [
      'ordinary',
      'manual',
      'clear',
      'dispose',
      'owner',
      'cursor'
    ]) {
      testWidgets('pending replay invalidated by $interruption',
          (tester) async {
        final store = await HistoryStore.create();
        final provider = HistoryProvider(store: store);
        final controller = _ControlledReplayController();
        addTearDown(controller.dispose);
        if (interruption != 'dispose') addTearDown(provider.dispose);
        for (final zoom in [1.0, 2.0, 3.0]) {
          await _recordAndFlush(tester, provider, zoom: zoom);
        }
        await controller
            .loadState(params: const {'iterations': 100}, view: _view(3));
        controller.addListener(() => _recordController(provider, controller));
        var owns = true;
        final gate = Completer<void>();
        controller.gate = gate;
        final old = provider.replayBack(controller, shouldCommit: () => owns);
        switch (interruption) {
          case 'ordinary':
            controller.gate = null;
            expect(
                await provider.replayEntry(provider.history.first, controller),
                isTrue);
          case 'manual':
            controller.updateZoom(4);
          case 'clear':
            await provider.clearHistory();
          case 'dispose':
            provider.dispose();
          case 'owner':
            owns = false;
          case 'cursor':
            provider.goBack();
        }
        gate.complete();
        await tester.pump();
        expect(await old, isFalse);
        await tester.pump(const Duration(milliseconds: 501));
        expect(
            controller.view.zoom,
            interruption == 'ordinary'
                ? 1
                : interruption == 'manual'
                    ? 4
                    : 3);
        expect(
            provider.historyCount,
            interruption == 'clear'
                ? 0
                : interruption == 'manual'
                    ? 4
                    : 3);
        expect(
            provider.currentPosition,
            interruption == 'ordinary'
                ? 1
                : interruption == 'cursor'
                    ? 2
                    : interruption == 'manual'
                        ? 4
                        : interruption == 'clear'
                            ? 0
                            : 3);
      });
    }

    testWidgets(
        'favorite records only normalized accepted state and deduplicates',
        (tester) async {
      final provider = HistoryProvider(store: await HistoryStore.create());
      final controller = _ControlledReplayController();
      addTearDown(provider.dispose);
      addTearDown(controller.dispose);
      _recordController(provider, controller);
      await tester.pump(const Duration(milliseconds: 501));
      final raw = HistoryEntry.fromState(
          moduleId: 'julia',
          view: _view(2),
          params: const {'iterations': 999999999});
      await provider.saveAsFavorite(raw, 'clamped');
      controller.addListener(() => _recordController(provider, controller));
      controller.gate = Completer<void>();
      final replay =
          provider.replayFavorite(provider.favorites.single, controller);
      expect(provider.historyCount, 1);
      controller.gate!.complete();
      await tester.pump();
      expect(await replay, isTrue);
      expect(provider.historyCount, 2);
      expect(provider.currentEntry!.params, controller.params);
      expect(provider.currentEntry!.params['iterations'], isNot(999999999));
      await tester.pump(const Duration(milliseconds: 501));
      controller.gate = null;
      expect(
          await provider.replayFavorite(provider.favorites.single, controller),
          isTrue);
      await tester.pump(const Duration(milliseconds: 501));
      expect(provider.historyCount, 2);
      await provider.saveAsFavorite(
          HistoryEntry.fromState(
              moduleId: 'number_wall',
              view: _view(7),
              params: const {'prime': '15'}),
          'invalid');
      final rejected =
          provider.replayFavorite(provider.favorites.last, controller);
      await tester.pump();
      expect(await rejected, isFalse);
      expect(provider.historyCount, 2);
    });

    testWidgets(
        'commit callback remains authoritative across reentrant false result and errors propagate',
        (tester) async {
      final provider = HistoryProvider(store: await HistoryStore.create());
      final controller = _ControlledReplayController();
      addTearDown(provider.dispose);
      addTearDown(controller.dispose);
      provider.recordLocation(
          moduleId: 'number_wall',
          view: _view(1),
          params: const {'prime': '7', 'rows': 4, 'columns': 16});
      await tester.pump(const Duration(milliseconds: 501));
      await _recordAndFlush(tester, provider, zoom: 2);
      final accepted = provider.history.first;
      var reentered = false;
      Future<bool>? newer;
      controller.addListener(() {
        if (controller.module.id == 'number_wall' && !reentered) {
          reentered = true;
          expectSync(provider.currentEntry, same(accepted));
          // Invalidates controller's Number Walls ingress generation after its
          // already-published commit; it can return false without undoing history.
          controller.cancelNumberWallRequest();
          newer = provider.replayEntry(accepted, controller,
              shouldCommit: () => false);
        }
      });
      final old = provider.replayBack(controller);
      var finished = false;
      old.then((_) => finished = true);
      for (var i = 0; i < 100 && !finished; i++) {
        await tester.pump(const Duration(milliseconds: 10));
      }
      expect(finished, isTrue, reason: 'bounded real Number Walls completion');
      expect(await old, isFalse);
      expect(await newer, isFalse);
      expect(provider.currentEntry, same(accepted));
      expect(provider.canGoForward, isTrue);
      controller.gate = Completer<void>();
      final error = provider.replayForward(controller);
      final expectation = expectLater(error, throwsStateError);
      controller.gate!.completeError(StateError('controlled replay failure'));
      await tester.pump();
      await expectation;
      expect(provider.currentEntry, same(accepted));
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

    testWidgets('disposed provider ignores async completion notifications',
        (tester) async {
      final store = await HistoryStore.create();
      final provider = HistoryProvider(store: store);

      provider.dispose();

      await expectLater(provider.clearHistory(), completes);
      await expectLater(provider.clearFavorites(), completes);
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

    testWidgets('restores the healthy slot when the other slot is mistyped',
        (tester) async {
      final healthyPayload = jsonEncode([_entryJson(1), _entryJson(2)]);
      for (final mistypedKey in [
        'exploration_history',
        'exploration_favorites',
      ]) {
        final historyIsMistyped = mistypedKey == 'exploration_history';
        final initialValues = <String, Object>{
          'exploration_history': historyIsMistyped ? 42 : healthyPayload,
          'exploration_favorites': historyIsMistyped ? healthyPayload : true,
        };
        SharedPreferences.setMockInitialValues(initialValues);
        final preferences = await SharedPreferences.getInstance();
        final store = await HistoryStore.create();
        final provider = HistoryProvider(store: store);
        addTearDown(provider.dispose);

        expect(provider.historyCount, historyIsMistyped ? 0 : 2);
        expect(provider.favoritesCount, historyIsMistyped ? 2 : 0);
        expect(provider.currentPosition, historyIsMistyped ? 0 : 2);
        expect(provider.canGoBack, !historyIsMistyped);
        expect(provider.canGoForward, isFalse);
        if (historyIsMistyped) {
          expect(provider.currentEntry, isNull);
          expect(provider.favorites.map((entry) => entry.view.zoom), [1, 2]);
        } else {
          expect(provider.currentEntry!.view.zoom, 2);
          expect(provider.goBack()!.view.zoom, 1);
          expect(provider.canGoForward, isTrue);
          expect(provider.goForward()!.view.zoom, 2);
        }

        await tester.pump(const Duration(milliseconds: 501));
        for (final entry in initialValues.entries) {
          expect(preferences.get(entry.key), entry.value);
        }
      }
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

    testWidgets('history replay switches to the recorded module before state',
        (tester) async {
      final store = await HistoryStore.create();
      final provider = HistoryProvider(store: store);
      addTearDown(provider.dispose);

      final registry = ModuleRegistry();
      final controller = FractalController(registry);
      addTearDown(controller.dispose);

      final entry = HistoryEntry(
        id: 'julia-replay',
        moduleId: 'julia',
        view: FractalViewState(
          pan: Vector2(0.25, -0.5),
          zoom: 2.5,
          rotation: Vector3(0.1, 0.2, 0.3),
        ),
        params: const <String, Object>{
          'iterations': 222,
          'bailout': 4.5,
          'colorScheme': 2,
        },
        visitedAt: DateTime.utc(2024),
      );

      provider.applyToController(entry, controller);

      expect(controller.module.id, 'julia');
      expect(controller.params['iterations'], 222);
      expect(controller.params['bailout'], closeTo(4.5, 1e-12));
      expect(controller.params['colorScheme'], 2);
      expect(controller.view.pan, Vector2(0.25, -0.5));
      expect(controller.view.zoom, 2.5);
      expect(controller.view.rotation, Vector3(0.1, 0.2, 0.3));
    });

    testWidgets('history replay keeps legacy structural controllers working',
        (tester) async {
      final store = await HistoryStore.create();
      final provider = HistoryProvider(store: store);
      addTearDown(provider.dispose);

      final controller = _LegacyReplayController();
      final entry = HistoryEntry(
        id: 'legacy-replay',
        moduleId: 'mandelbrot',
        view: FractalViewState(
          pan: Vector2(-0.25, 0.5),
          zoom: 3.5,
          rotation: Vector3(0.4, 0.5, 0.6),
        ),
        params: const <String, Object>{'iterations': 180},
        visitedAt: DateTime.utc(2024),
      );

      provider.applyToController(entry, controller);

      expect(controller.params, {'iterations': 180});
      expect(controller.zoom, 3.5);
      expect(controller.pan, Vector2(-0.25, 0.5));
      expect(controller.rotation, Vector3(0.4, 0.5, 0.6));
    });
  });
}
