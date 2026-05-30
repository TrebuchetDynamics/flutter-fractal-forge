// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0181_twin_spiral_julia/f0181_twin_spiral_julia_module.dart';

void main() {
  test('F0181TwinSpiralJulia instantiates', () {
    final m = F0181TwinSpiralJulia();
    expect(m.id, 'f0181_twin_spiral_julia');
    expect(m.shader, 'shaders/f0181_twin_spiral_julia_gpu.frag');
  });

  test('F0181TwinSpiralJulia presets are well-formed', () {
    final m = F0181TwinSpiralJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0181TwinSpiralJulia metadata is consistent', () {
    final m = F0181TwinSpiralJulia();
    expect(m.metadata.id, m.id);
  });
}
