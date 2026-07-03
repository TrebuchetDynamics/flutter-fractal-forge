import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('escape-time catalog built-in preset provenance', () {
    test('every curated preset uses the stable builtInPresetCreatedAt', () {
      // Built-in catalog data must be replayable across registry rebuilds and
      // test runs (see built_in_preset_contract.dart). Using DateTime.now() in
      // the catalog literals bakes a non-deterministic timestamp into "built-in"
      // data, which this guards against.
      final offenders = <String>[];
      for (final config in escapeTimeCatalog) {
        for (final preset in config.extraPresets) {
          if (preset.createdAt != builtInPresetCreatedAt) {
            offenders.add('${config.id}/${preset.id} -> ${preset.createdAt}');
          }
        }
      }
      expect(
        offenders,
        isEmpty,
        reason: 'Catalog presets must use builtInPresetCreatedAt, not '
            'DateTime.now() or other runtime values:\n${offenders.join('\n')}',
      );
    });

    test('the provenance marker itself is a stable UTC instant', () {
      expect(builtInPresetCreatedAt.isUtc, isTrue);
      expect(builtInPresetCreatedAt, DateTime.utc(2025, 1, 1));
    });
  });
}
