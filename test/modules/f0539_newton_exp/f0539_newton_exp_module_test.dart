// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0539_newton_exp/f0539_newton_exp_module.dart';

void main() {
  test('F0539NewtonExp instantiates', () {
    final m = F0539NewtonExp();
    expect(m.id, 'f0539_newton_exp');
    expect(m.shader, 'shaders/f0539_newton_exp_gpu.frag');
  });

  test('F0539NewtonExp presets are well-formed', () {
    final m = F0539NewtonExp();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0539NewtonExp metadata is consistent', () {
    final m = F0539NewtonExp();
    expect(m.metadata.id, m.id);
  });
}
