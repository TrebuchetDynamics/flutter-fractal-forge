import 'package:flutter_fractals/core/services/engine/rust_engine_adapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fractal_engine_bridge/fractal_engine_bridge.dart' as native;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native version, capabilities and isolated handle lifecycle',
      (tester) async {
    expect(const bool.fromEnvironment('RUST_CORE'), isTrue,
        reason: 'This fixture must exercise the real opt-in native bridge');
    final adapter = (await RustEngineAdapter.create())!;
    try {
      expect(adapter.version, '0.1.0');
      expect(adapter.rendering, isFalse);
      final first = native.Engine();
      final second = native.Engine();
      try {
        first.shutdown();
        first.shutdown();
        expect(
            () => first.capabilities(), throwsA(contains('session is closed')));
        expect(second.capabilities().rendering, isFalse);
      } finally {
        first.shutdown();
        second.shutdown();
        first.dispose();
        second.dispose();
      }
    } finally {
      adapter.shutdown();
      adapter.shutdown();
    }
    expect(() => adapter.rendering, throwsStateError);
  });
}
