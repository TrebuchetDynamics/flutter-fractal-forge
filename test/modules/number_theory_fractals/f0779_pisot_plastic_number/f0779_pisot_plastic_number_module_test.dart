// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/number_theory_fractals/f0779_pisot_plastic_number/f0779_pisot_plastic_number_module.dart';

void main() {
  test('F0779PisotPlasticNumber instantiates', () {
    final m = F0779PisotPlasticNumber();
    expect(m.id, 'f0779_pisot_plastic_number');
    expect(m.shader, 'shaders/f0779_pisot_plastic_number_gpu.frag');
  });

  test('F0779PisotPlasticNumber presets are well-formed', () {
    final m = F0779PisotPlasticNumber();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0779PisotPlasticNumber metadata is consistent', () {
    final m = F0779PisotPlasticNumber();
    expect(m.metadata.id, m.id);
  });
}
