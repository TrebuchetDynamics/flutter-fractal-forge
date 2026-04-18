// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/tiling_aperiodic/f0689_ammann_a4_tiling/f0689_ammann_a4_tiling_module.dart';

void main() {
  test('F0689AmmannA4Tiling instantiates', () {
    final m = F0689AmmannA4Tiling();
    expect(m.id, 'f0689_ammann_a4_tiling');
    expect(m.shader, 'shaders/f0689_ammann_a4_tiling_gpu.frag');
  });

  test('F0689AmmannA4Tiling presets are well-formed', () {
    final m = F0689AmmannA4Tiling();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0689AmmannA4Tiling metadata is consistent', () {
    final m = F0689AmmannA4Tiling();
    expect(m.metadata.id, m.id);
  });
}
