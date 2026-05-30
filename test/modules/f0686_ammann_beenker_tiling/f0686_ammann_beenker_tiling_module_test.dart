// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/tiling_aperiodic/f0686_ammann_beenker_tiling/f0686_ammann_beenker_tiling_module.dart';

void main() {
  test('F0686AmmannBeenkerTiling instantiates', () {
    final m = F0686AmmannBeenkerTiling();
    expect(m.id, 'f0686_ammann_beenker_tiling');
    expect(m.shader, 'shaders/f0686_ammann_beenker_tiling_gpu.frag');
  });

  test('F0686AmmannBeenkerTiling presets are well-formed', () {
    final m = F0686AmmannBeenkerTiling();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0686AmmannBeenkerTiling metadata is consistent', () {
    final m = F0686AmmannBeenkerTiling();
    expect(m.metadata.id, m.id);
  });
}
