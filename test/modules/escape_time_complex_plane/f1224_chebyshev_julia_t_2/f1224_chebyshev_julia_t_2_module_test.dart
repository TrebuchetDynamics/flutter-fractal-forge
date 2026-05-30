// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1224_chebyshev_julia_t_2/f1224_chebyshev_julia_t_2_module.dart';

void main() {
  test('F1224ChebyshevJuliaT2 instantiates', () {
    final m = F1224ChebyshevJuliaT2();
    expect(m.id, 'f1224_chebyshev_julia_t_2');
    expect(m.shader, 'shaders/f1224_chebyshev_julia_t_2_gpu.frag');
  });

  test('F1224ChebyshevJuliaT2 presets are well-formed', () {
    final m = F1224ChebyshevJuliaT2();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1224ChebyshevJuliaT2 metadata is consistent', () {
    final m = F1224ChebyshevJuliaT2();
    expect(m.metadata.id, m.id);
  });
}
