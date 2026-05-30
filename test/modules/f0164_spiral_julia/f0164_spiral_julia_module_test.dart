// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0164_spiral_julia/f0164_spiral_julia_module.dart';

void main() {
  test('F0164SpiralJulia instantiates', () {
    final m = F0164SpiralJulia();
    expect(m.id, 'f0164_spiral_julia');
    expect(m.shader, 'shaders/f0164_spiral_julia_gpu.frag');
  });

  test('F0164SpiralJulia presets are well-formed', () {
    final m = F0164SpiralJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0164SpiralJulia metadata is consistent', () {
    final m = F0164SpiralJulia();
    expect(m.metadata.id, m.id);
  });
}
