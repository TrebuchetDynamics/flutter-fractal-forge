// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0811_sawtooth_map_alpha_1_5/f0811_sawtooth_map_alpha_1_5_module.dart';

void main() {
  test('F0811SawtoothMapAlpha15 instantiates', () {
    final m = F0811SawtoothMapAlpha15();
    expect(m.id, 'f0811_sawtooth_map_alpha_1_5');
    expect(m.shader, 'shaders/f0811_sawtooth_map_alpha_1_5_gpu.frag');
  });

  test('F0811SawtoothMapAlpha15 presets are well-formed', () {
    final m = F0811SawtoothMapAlpha15();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0811SawtoothMapAlpha15 metadata is consistent', () {
    final m = F0811SawtoothMapAlpha15();
    expect(m.metadata.id, m.id);
  });
}
