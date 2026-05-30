// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0048_lorenz_84/f0048_lorenz_84_module.dart';

void main() {
  test('F0048Lorenz84 instantiates', () {
    final m = F0048Lorenz84();
    expect(m.id, 'f0048_lorenz_84');
    expect(m.shader, 'shaders/f0048_lorenz_84_gpu.frag');
  });

  test('F0048Lorenz84 presets are well-formed', () {
    final m = F0048Lorenz84();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0048Lorenz84 metadata is consistent', () {
    final m = F0048Lorenz84();
    expect(m.metadata.id, m.id);
  });
}
