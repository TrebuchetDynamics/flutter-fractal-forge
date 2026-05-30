// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0212_standard_map_chirikov/f0212_standard_map_chirikov_module.dart';

void main() {
  test('F0212StandardMapChirikov instantiates', () {
    final m = F0212StandardMapChirikov();
    expect(m.id, 'f0212_standard_map_chirikov');
    expect(m.shader, 'shaders/f0212_standard_map_chirikov_gpu.frag');
  });

  test('F0212StandardMapChirikov presets are well-formed', () {
    final m = F0212StandardMapChirikov();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0212StandardMapChirikov metadata is consistent', () {
    final m = F0212StandardMapChirikov();
    expect(m.metadata.id, m.id);
  });
}
