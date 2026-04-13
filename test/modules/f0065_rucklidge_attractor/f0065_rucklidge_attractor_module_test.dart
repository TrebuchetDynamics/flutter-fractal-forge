// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0065_rucklidge_attractor/f0065_rucklidge_attractor_module.dart';

void main() {
  test('F0065RucklidgeAttractor instantiates', () {
    final m = F0065RucklidgeAttractor();
    expect(m.id, 'f0065_rucklidge_attractor');
    expect(m.shader, 'shaders/f0065_rucklidge_attractor_gpu.frag');
  });

  test('F0065RucklidgeAttractor presets are well-formed', () {
    final m = F0065RucklidgeAttractor();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0065RucklidgeAttractor metadata is consistent', () {
    final m = F0065RucklidgeAttractor();
    expect(m.metadata.id, m.id);
  });
}
