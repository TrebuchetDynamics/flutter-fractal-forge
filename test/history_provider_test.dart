import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/services/history_store.dart';
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
  });
}
