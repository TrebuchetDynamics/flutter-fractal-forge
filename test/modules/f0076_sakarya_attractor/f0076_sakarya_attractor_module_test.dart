// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0076_sakarya_attractor/f0076_sakarya_attractor_module.dart';

void main() {
  test('F0076SakaryaAttractor instantiates', () {
    final m = F0076SakaryaAttractor();
    expect(m.id, 'f0076_sakarya_attractor');
    expect(m.shader, 'shaders/f0076_sakarya_attractor_gpu.frag');
  });

  test('F0076SakaryaAttractor presets are well-formed', () {
    final m = F0076SakaryaAttractor();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0076SakaryaAttractor metadata is consistent', () {
    final m = F0076SakaryaAttractor();
    expect(m.metadata.id, m.id);
  });
}
