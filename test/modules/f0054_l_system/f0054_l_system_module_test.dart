// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0054_l_system/f0054_l_system_module.dart';

void main() {
  test('F0054LSystem instantiates', () {
    final m = F0054LSystem();
    expect(m.id, 'f0054_l_system');
    expect(m.shader, 'shaders/f0054_l_system_gpu.frag');
  });

  test('F0054LSystem presets are well-formed', () {
    final m = F0054LSystem();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0054LSystem metadata is consistent', () {
    final m = F0054LSystem();
    expect(m.metadata.id, m.id);
  });
}
