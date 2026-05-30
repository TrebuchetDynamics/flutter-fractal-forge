// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/tiling_aperiodic/f0688_ammann_a3_tiling/f0688_ammann_a3_tiling_module.dart';

void main() {
  test('F0688AmmannA3Tiling instantiates', () {
    final m = F0688AmmannA3Tiling();
    expect(m.id, 'f0688_ammann_a3_tiling');
    expect(m.shader, 'shaders/f0688_ammann_a3_tiling_gpu.frag');
  });

  test('F0688AmmannA3Tiling presets are well-formed', () {
    final m = F0688AmmannA3Tiling();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0688AmmannA3Tiling metadata is consistent', () {
    final m = F0688AmmannA3Tiling();
    expect(m.metadata.id, m.id);
  });
}
