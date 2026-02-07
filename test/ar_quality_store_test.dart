import 'package:flutter_fractals/core/models/ar_quality_preset.dart';
import 'package:flutter_fractals/core/services/ar_quality_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ArQualityStore', () {
    test('getPreset defaults to medium for null/unknown values', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await ArQualityStore.create();
      expect(store.getPreset(), ArQualityPreset.medium);

      SharedPreferences.setMockInitialValues({'ar_quality_preset': 'weird'});
      final store2 = await ArQualityStore.create();
      expect(store2.getPreset(), ArQualityPreset.medium);
    });

    test('getPreset maps low/high/medium correctly', () async {
      SharedPreferences.setMockInitialValues({'ar_quality_preset': 'low'});
      final lowStore = await ArQualityStore.create();
      expect(lowStore.getPreset(), ArQualityPreset.low);

      SharedPreferences.setMockInitialValues({'ar_quality_preset': 'high'});
      final highStore = await ArQualityStore.create();
      expect(highStore.getPreset(), ArQualityPreset.high);

      SharedPreferences.setMockInitialValues({'ar_quality_preset': 'medium'});
      final medStore = await ArQualityStore.create();
      expect(medStore.getPreset(), ArQualityPreset.medium);
    });

    test('setPreset persists using preset.name', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await ArQualityStore.create();

      await store.setPreset(ArQualityPreset.high);
      expect(store.getPreset(), ArQualityPreset.high);

      await store.setPreset(ArQualityPreset.low);
      expect(store.getPreset(), ArQualityPreset.low);
    });
  });

  group('arQualityParamsForModule', () {
    test('returns module-specific overrides and empty for unsupported modules', () {
      expect(arQualityParamsForModule(ArQualityPreset.low, 'unknown'), isEmpty);

      expect(
        arQualityParamsForModule(ArQualityPreset.low, 'mandelbrot'),
        containsPair('iterations', 80),
      );

      final mandelbulbHigh = arQualityParamsForModule(ArQualityPreset.high, 'mandelbulb');
      expect(mandelbulbHigh, containsPair('iterations', 80));
      expect(mandelbulbHigh, containsPair('steps', 160));
    });
  });
}
