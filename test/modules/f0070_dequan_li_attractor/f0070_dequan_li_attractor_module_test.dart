// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0070_dequan_li_attractor/f0070_dequan_li_attractor_module.dart';

void main() {
  test('F0070DequanLiAttractor instantiates', () {
    final m = F0070DequanLiAttractor();
    expect(m.id, 'f0070_dequan_li_attractor');
    expect(m.shader, 'shaders/f0070_dequan_li_attractor_gpu.frag');
  });

  test('F0070DequanLiAttractor presets are well-formed', () {
    final m = F0070DequanLiAttractor();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0070DequanLiAttractor metadata is consistent', () {
    final m = F0070DequanLiAttractor();
    expect(m.metadata.id, m.id);
  });
}
