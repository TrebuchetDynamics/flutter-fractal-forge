import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_fractals/core/services/renderer_settings_service.dart';

void main() {
  group('RendererSettingsService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('defaults to auto backend mode when no value stored', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = RendererSettingsService(prefs);
      expect(service.backendMode, equals(RendererBackendMode.auto));
    });

    test('setBackendMode persists to SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = RendererSettingsService(prefs);

      await service.setBackendMode(RendererBackendMode.cpuOnly);

      // Re-create service from same prefs to verify persistence.
      final service2 = RendererSettingsService(prefs);
      expect(service2.backendMode, equals(RendererBackendMode.cpuOnly));
    });

    test('setBackendMode notifies listeners', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = RendererSettingsService(prefs);

      var notified = false;
      service.addListener(() => notified = true);

      await service.setBackendMode(RendererBackendMode.gpuOnly);

      expect(notified, isTrue);
    });

    test('setBackendMode does not notify if mode is unchanged', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = RendererSettingsService(prefs);

      var callCount = 0;
      service.addListener(() => callCount++);

      await service.setBackendMode(RendererBackendMode.auto);

      expect(callCount, equals(0));
    });

    test('decodes cpuOnly from stored string', () async {
      SharedPreferences.setMockInitialValues({
        'renderer_backend_mode': 'cpuOnly',
      });
      final prefs = await SharedPreferences.getInstance();
      final service = RendererSettingsService(prefs);
      expect(service.backendMode, equals(RendererBackendMode.cpuOnly));
    });

    test('decodes gpuOnly from stored string', () async {
      SharedPreferences.setMockInitialValues({
        'renderer_backend_mode': 'gpuOnly',
      });
      final prefs = await SharedPreferences.getInstance();
      final service = RendererSettingsService(prefs);
      expect(service.backendMode, equals(RendererBackendMode.gpuOnly));
    });

    test('decodes unknown string as auto', () async {
      SharedPreferences.setMockInitialValues({
        'renderer_backend_mode': 'notAValidMode',
      });
      final prefs = await SharedPreferences.getInstance();
      final service = RendererSettingsService(prefs);
      expect(service.backendMode, equals(RendererBackendMode.auto));
    });
  });
}
