// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0024_sprott_k/f0024_sprott_k_module.dart';

void main() {
  test('F0024SprottK instantiates', () {
    final m = F0024SprottK();
    expect(m.id, 'f0024_sprott_k');
    expect(m.shader, 'shaders/f0024_sprott_k_gpu.frag');
  });

  test('F0024SprottK presets are well-formed', () {
    final m = F0024SprottK();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0024SprottK metadata is consistent', () {
    final m = F0024SprottK();
    expect(m.metadata.id, m.id);
  });
}
