// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/tiling_aperiodic/f0687_ammann_a2_tiling/f0687_ammann_a2_tiling_module.dart';

void main() {
  test('F0687AmmannA2Tiling instantiates', () {
    final m = F0687AmmannA2Tiling();
    expect(m.id, 'f0687_ammann_a2_tiling');
    expect(m.shader, 'shaders/f0687_ammann_a2_tiling_gpu.frag');
  });

  test('F0687AmmannA2Tiling presets are well-formed', () {
    final m = F0687AmmannA2Tiling();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0687AmmannA2Tiling metadata is consistent', () {
    final m = F0687AmmannA2Tiling();
    expect(m.metadata.id, m.id);
  });
}
