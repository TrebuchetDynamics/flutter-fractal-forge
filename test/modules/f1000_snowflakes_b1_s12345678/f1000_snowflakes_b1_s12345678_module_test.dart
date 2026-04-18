// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f1000_snowflakes_b1_s12345678/f1000_snowflakes_b1_s12345678_module.dart';

void main() {
  test('F1000SnowflakesB1S12345678 instantiates', () {
    final m = F1000SnowflakesB1S12345678();
    expect(m.id, 'f1000_snowflakes_b1_s12345678');
    expect(m.shader, 'shaders/f1000_snowflakes_b1_s12345678_gpu.frag');
  });

  test('F1000SnowflakesB1S12345678 presets are well-formed', () {
    final m = F1000SnowflakesB1S12345678();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1000SnowflakesB1S12345678 metadata is consistent', () {
    final m = F1000SnowflakesB1S12345678();
    expect(m.metadata.id, m.id);
  });
}
