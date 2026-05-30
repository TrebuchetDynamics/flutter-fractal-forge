// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/tiling_aperiodic/f0716_thue_morse_2d_tiling/f0716_thue_morse_2d_tiling_module.dart';

void main() {
  test('F0716ThueMorse2dTiling instantiates', () {
    final m = F0716ThueMorse2dTiling();
    expect(m.id, 'f0716_thue_morse_2d_tiling');
    expect(m.shader, 'shaders/f0716_thue_morse_2d_tiling_gpu.frag');
  });

  test('F0716ThueMorse2dTiling presets are well-formed', () {
    final m = F0716ThueMorse2dTiling();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0716ThueMorse2dTiling metadata is consistent', () {
    final m = F0716ThueMorse2dTiling();
    expect(m.metadata.id, m.id);
  });
}
