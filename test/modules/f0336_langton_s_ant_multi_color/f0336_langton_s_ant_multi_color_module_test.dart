// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/cellular_stochastic/f0336_langton_s_ant_multi_color/f0336_langton_s_ant_multi_color_module.dart';

void main() {
  test('F0336LangtonSAntMultiColor instantiates', () {
    final m = F0336LangtonSAntMultiColor();
    expect(m.id, 'f0336_langton_s_ant_multi_color');
    expect(m.shader, 'shaders/f0336_langton_s_ant_multi_color_gpu.frag');
  });

  test('F0336LangtonSAntMultiColor presets are well-formed', () {
    final m = F0336LangtonSAntMultiColor();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0336LangtonSAntMultiColor metadata is consistent', () {
    final m = F0336LangtonSAntMultiColor();
    expect(m.metadata.id, m.id);
  });
}
