// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0260_rauzy_fractal_l_system_form/f0260_rauzy_fractal_l_system_form_module.dart';

void main() {
  test('F0260RauzyFractalLSystemForm instantiates', () {
    final m = F0260RauzyFractalLSystemForm();
    expect(m.id, 'f0260_rauzy_fractal_l_system_form');
    expect(m.shader, 'shaders/f0260_rauzy_fractal_l_system_form_gpu.frag');
  });

  test('F0260RauzyFractalLSystemForm presets are well-formed', () {
    final m = F0260RauzyFractalLSystemForm();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0260RauzyFractalLSystemForm metadata is consistent', () {
    final m = F0260RauzyFractalLSystemForm();
    expect(m.metadata.id, m.id);
  });
}
