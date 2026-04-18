// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/newton_root_finding/f1201_newton_sin_z/f1201_newton_sin_z_module.dart';

void main() {
  test('F1201NewtonSinZ instantiates', () {
    final m = F1201NewtonSinZ();
    expect(m.id, 'f1201_newton_sin_z');
    expect(m.shader, 'shaders/f1201_newton_sin_z_gpu.frag');
  });

  test('F1201NewtonSinZ presets are well-formed', () {
    final m = F1201NewtonSinZ();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1201NewtonSinZ metadata is consistent', () {
    final m = F1201NewtonSinZ();
    expect(m.metadata.id, m.id);
  });
}
