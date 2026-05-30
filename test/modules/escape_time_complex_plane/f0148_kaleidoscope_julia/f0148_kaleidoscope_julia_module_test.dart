// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0148_kaleidoscope_julia/f0148_kaleidoscope_julia_module.dart';

void main() {
  test('F0148KaleidoscopeJulia instantiates', () {
    final m = F0148KaleidoscopeJulia();
    expect(m.id, 'f0148_kaleidoscope_julia');
    expect(m.shader, 'shaders/f0148_kaleidoscope_julia_gpu.frag');
  });

  test('F0148KaleidoscopeJulia presets are well-formed', () {
    final m = F0148KaleidoscopeJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0148KaleidoscopeJulia metadata is consistent', () {
    final m = F0148KaleidoscopeJulia();
    expect(m.metadata.id, m.id);
  });
}
