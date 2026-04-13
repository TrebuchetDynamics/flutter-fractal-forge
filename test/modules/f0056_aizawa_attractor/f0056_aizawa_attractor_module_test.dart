// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0056_aizawa_attractor/f0056_aizawa_attractor_module.dart';

void main() {
  test('F0056AizawaAttractor instantiates', () {
    final m = F0056AizawaAttractor();
    expect(m.id, 'f0056_aizawa_attractor');
    expect(m.shader, 'shaders/f0056_aizawa_attractor_gpu.frag');
  });

  test('F0056AizawaAttractor presets are well-formed', () {
    final m = F0056AizawaAttractor();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0056AizawaAttractor metadata is consistent', () {
    final m = F0056AizawaAttractor();
    expect(m.metadata.id, m.id);
  });
}
