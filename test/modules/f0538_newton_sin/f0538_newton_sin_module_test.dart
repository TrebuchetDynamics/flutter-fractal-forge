// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0538_newton_sin/f0538_newton_sin_module.dart';

void main() {
  test('F0538NewtonSin instantiates', () {
    final m = F0538NewtonSin();
    expect(m.id, 'f0538_newton_sin');
    expect(m.shader, 'shaders/f0538_newton_sin_gpu.frag');
  });

  test('F0538NewtonSin presets are well-formed', () {
    final m = F0538NewtonSin();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0538NewtonSin metadata is consistent', () {
    final m = F0538NewtonSin();
    expect(m.metadata.id, m.id);
  });
}
