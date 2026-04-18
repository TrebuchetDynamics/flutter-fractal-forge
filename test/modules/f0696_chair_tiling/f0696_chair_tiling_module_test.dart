// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/tiling_aperiodic/f0696_chair_tiling/f0696_chair_tiling_module.dart';

void main() {
  test('F0696ChairTiling instantiates', () {
    final m = F0696ChairTiling();
    expect(m.id, 'f0696_chair_tiling');
    expect(m.shader, 'shaders/f0696_chair_tiling_gpu.frag');
  });

  test('F0696ChairTiling presets are well-formed', () {
    final m = F0696ChairTiling();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0696ChairTiling metadata is consistent', () {
    final m = F0696ChairTiling();
    expect(m.metadata.id, m.id);
  });
}
