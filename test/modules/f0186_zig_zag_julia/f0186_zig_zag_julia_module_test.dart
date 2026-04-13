// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0186_zig_zag_julia/f0186_zig_zag_julia_module.dart';

void main() {
  test('F0186ZigZagJulia instantiates', () {
    final m = F0186ZigZagJulia();
    expect(m.id, 'f0186_zig_zag_julia');
    expect(m.shader, 'shaders/f0186_zig_zag_julia_gpu.frag');
  });

  test('F0186ZigZagJulia presets are well-formed', () {
    final m = F0186ZigZagJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0186ZigZagJulia metadata is consistent', () {
    final m = F0186ZigZagJulia();
    expect(m.metadata.id, m.id);
  });
}
