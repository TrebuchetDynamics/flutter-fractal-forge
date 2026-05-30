// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0055_halvorsen_attractor/f0055_halvorsen_attractor_module.dart';

void main() {
  test('F0055HalvorsenAttractor instantiates', () {
    final m = F0055HalvorsenAttractor();
    expect(m.id, 'f0055_halvorsen_attractor');
    expect(m.shader, 'shaders/f0055_halvorsen_attractor_gpu.frag');
  });

  test('F0055HalvorsenAttractor presets are well-formed', () {
    final m = F0055HalvorsenAttractor();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0055HalvorsenAttractor metadata is consistent', () {
    final m = F0055HalvorsenAttractor();
    expect(m.metadata.id, m.id);
  });
}
