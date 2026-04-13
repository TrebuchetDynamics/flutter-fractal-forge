// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0166_chebyshev_julia/f0166_chebyshev_julia_module.dart';

void main() {
  test('F0166ChebyshevJulia instantiates', () {
    final m = F0166ChebyshevJulia();
    expect(m.id, 'f0166_chebyshev_julia');
    expect(m.shader, 'shaders/f0166_chebyshev_julia_gpu.frag');
  });

  test('F0166ChebyshevJulia presets are well-formed', () {
    final m = F0166ChebyshevJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0166ChebyshevJulia metadata is consistent', () {
    final m = F0166ChebyshevJulia();
    expect(m.metadata.id, m.id);
  });
}
