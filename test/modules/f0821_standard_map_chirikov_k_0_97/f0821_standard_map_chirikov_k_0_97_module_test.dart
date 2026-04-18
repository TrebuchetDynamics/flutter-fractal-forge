// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0821_standard_map_chirikov_k_0_97/f0821_standard_map_chirikov_k_0_97_module.dart';

void main() {
  test('F0821StandardMapChirikovK097 instantiates', () {
    final m = F0821StandardMapChirikovK097();
    expect(m.id, 'f0821_standard_map_chirikov_k_0_97');
    expect(m.shader, 'shaders/f0821_standard_map_chirikov_k_0_97_gpu.frag');
  });

  test('F0821StandardMapChirikovK097 presets are well-formed', () {
    final m = F0821StandardMapChirikovK097();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0821StandardMapChirikovK097 metadata is consistent', () {
    final m = F0821StandardMapChirikovK097();
    expect(m.metadata.id, m.id);
  });
}
