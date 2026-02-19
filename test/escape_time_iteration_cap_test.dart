import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_fractals/core/modules/builders/escape_time_builder.dart';
import 'package:flutter_fractals/core/modules/builders/escape_time_catalog.dart';

void main() {
  group('Escape-time iteration cap consistency', () {
    test('default EscapeTimeConfig maxIterations matches shader loop cap', () {
      const cfg = EscapeTimeConfig(
        id: 'test',
        name: 'Test',
        shaderAsset: 'shaders/test.frag',
      );
      expect(cfg.maxIterations, 500);
    });

    test('catalog-generated modules keep iterations slider <= 500', () {
      for (final cfg in escapeTimeCatalog) {
        final module = buildEscapeTimeModule(cfg);
        final iterParam =
            module.parameters.firstWhere((p) => p.id == 'iterations');
        expect(
          iterParam.max,
          lessThanOrEqualTo(500.0),
          reason:
              '${cfg.id} exposes iteration max above shader cap: ${iterParam.max}',
        );
      }
    });
  });
}
