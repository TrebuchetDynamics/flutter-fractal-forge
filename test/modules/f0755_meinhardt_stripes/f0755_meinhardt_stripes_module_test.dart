// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/reaction_diffusion_chemical/f0755_meinhardt_stripes/f0755_meinhardt_stripes_module.dart';

void main() {
  test('F0755MeinhardtStripes instantiates', () {
    final m = F0755MeinhardtStripes();
    expect(m.id, 'f0755_meinhardt_stripes');
    expect(m.shader, 'shaders/f0755_meinhardt_stripes_gpu.frag');
  });

  test('F0755MeinhardtStripes presets are well-formed', () {
    final m = F0755MeinhardtStripes();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0755MeinhardtStripes metadata is consistent', () {
    final m = F0755MeinhardtStripes();
    expect(m.metadata.id, m.id);
  });
}
