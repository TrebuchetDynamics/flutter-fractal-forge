// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0077_bouali_attractor/f0077_bouali_attractor_module.dart';

void main() {
  test('F0077BoualiAttractor instantiates', () {
    final m = F0077BoualiAttractor();
    expect(m.id, 'f0077_bouali_attractor');
    expect(m.shader, 'shaders/f0077_bouali_attractor_gpu.frag');
  });

  test('F0077BoualiAttractor presets are well-formed', () {
    final m = F0077BoualiAttractor();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0077BoualiAttractor metadata is consistent', () {
    final m = F0077BoualiAttractor();
    expect(m.metadata.id, m.id);
  });
}
