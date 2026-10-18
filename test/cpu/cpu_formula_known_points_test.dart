import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2;

import 'package:flutter_fractals/features/renderer/cpu/cpu_formulas.dart';

void main() {
  test('native captured formulas match fixed parameter-plane references', () {
    const references = <String, (double, double, double)>{
      'burning_ship': (
        249.4461968461563,
        36.13544329672172,
        101.36821196622824,
      ),
      'tricorn': (46.0, 120.0, 220.0),
      'celtic': (253.33328413655306, 48.872874255697795, 84.88558032040285),
      'buffalo': (203.7615624637723, 1.2211341737455894, 180.2999081737343),
      'multibrot3': (46.0, 120.0, 220.0),
    };

    for (final entry in references.entries) {
      expect(hasNativeCpuFormula(entry.key), isTrue, reason: entry.key);
      final color = cpuFormulaForModuleId(entry.key)(
        0.37,
        -0.62,
        80,
        4.0,
        Vector2.zero(),
      );
      final actualChannels = [color.$1, color.$2, color.$3];
      final expectedChannels = [
        entry.value.$1,
        entry.value.$2,
        entry.value.$3,
      ];
      for (var channel = 0; channel < actualChannels.length; channel++) {
        expect(
          actualChannels[channel],
          closeTo(expectedChannels[channel], 1e-9),
          reason: '${entry.key} channel $channel',
        );
      }
    }
  });
}
