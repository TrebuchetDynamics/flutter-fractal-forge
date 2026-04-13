// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0240_sierpinski_square_l_system/f0240_sierpinski_square_l_system_module.dart';

void main() {
  test('F0240SierpinskiSquareLSystem instantiates', () {
    final m = F0240SierpinskiSquareLSystem();
    expect(m.id, 'f0240_sierpinski_square_l_system');
    expect(m.shader, 'shaders/f0240_sierpinski_square_l_system_gpu.frag');
  });

  test('F0240SierpinskiSquareLSystem presets are well-formed', () {
    final m = F0240SierpinskiSquareLSystem();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0240SierpinskiSquareLSystem metadata is consistent', () {
    final m = F0240SierpinskiSquareLSystem();
    expect(m.metadata.id, m.id);
  });
}
