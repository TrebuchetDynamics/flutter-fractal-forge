// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/tiling_aperiodic/f0683_penrose_p1_tiling/f0683_penrose_p1_tiling_module.dart';

void main() {
  test('F0683PenroseP1Tiling instantiates', () {
    final m = F0683PenroseP1Tiling();
    expect(m.id, 'f0683_penrose_p1_tiling');
    expect(m.shader, 'shaders/f0683_penrose_p1_tiling_gpu.frag');
  });

  test('F0683PenroseP1Tiling presets are well-formed', () {
    final m = F0683PenroseP1Tiling();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0683PenroseP1Tiling metadata is consistent', () {
    final m = F0683PenroseP1Tiling();
    expect(m.metadata.id, m.id);
  });
}
