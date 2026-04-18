// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/tiling_aperiodic/f0690_ammann_a5_tiling/f0690_ammann_a5_tiling_module.dart';

void main() {
  test('F0690AmmannA5Tiling instantiates', () {
    final m = F0690AmmannA5Tiling();
    expect(m.id, 'f0690_ammann_a5_tiling');
    expect(m.shader, 'shaders/f0690_ammann_a5_tiling_gpu.frag');
  });

  test('F0690AmmannA5Tiling presets are well-formed', () {
    final m = F0690AmmannA5Tiling();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0690AmmannA5Tiling metadata is consistent', () {
    final m = F0690AmmannA5Tiling();
    expect(m.metadata.id, m.id);
  });
}
