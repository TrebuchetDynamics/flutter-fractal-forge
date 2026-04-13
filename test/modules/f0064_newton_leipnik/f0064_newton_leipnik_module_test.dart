// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0064_newton_leipnik/f0064_newton_leipnik_module.dart';

void main() {
  test('F0064NewtonLeipnik instantiates', () {
    final m = F0064NewtonLeipnik();
    expect(m.id, 'f0064_newton_leipnik');
    expect(m.shader, 'shaders/f0064_newton_leipnik_gpu.frag');
  });

  test('F0064NewtonLeipnik presets are well-formed', () {
    final m = F0064NewtonLeipnik();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0064NewtonLeipnik metadata is consistent', () {
    final m = F0064NewtonLeipnik();
    expect(m.metadata.id, m.id);
  });
}
