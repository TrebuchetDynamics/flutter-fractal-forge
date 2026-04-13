// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0078_yu_wang/f0078_yu_wang_module.dart';

void main() {
  test('F0078YuWang instantiates', () {
    final m = F0078YuWang();
    expect(m.id, 'f0078_yu_wang');
    expect(m.shader, 'shaders/f0078_yu_wang_gpu.frag');
  });

  test('F0078YuWang presets are well-formed', () {
    final m = F0078YuWang();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0078YuWang metadata is consistent', () {
    final m = F0078YuWang();
    expect(m.metadata.id, m.id);
  });
}
