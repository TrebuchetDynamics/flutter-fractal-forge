// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0430_quad_spiral/f0430_quad_spiral_module.dart';

void main() {
  test('F0430QuadSpiral instantiates', () {
    final m = F0430QuadSpiral();
    expect(m.id, 'f0430_quad_spiral');
    expect(m.shader, 'shaders/f0430_quad_spiral_gpu.frag');
  });

  test('F0430QuadSpiral presets are well-formed', () {
    final m = F0430QuadSpiral();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0430QuadSpiral metadata is consistent', () {
    final m = F0430QuadSpiral();
    expect(m.metadata.id, m.id);
  });
}
