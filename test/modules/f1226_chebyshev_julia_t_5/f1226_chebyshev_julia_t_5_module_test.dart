// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f1226_chebyshev_julia_t_5/f1226_chebyshev_julia_t_5_module.dart';

void main() {
  test('F1226ChebyshevJuliaT5 instantiates', () {
    final m = F1226ChebyshevJuliaT5();
    expect(m.id, 'f1226_chebyshev_julia_t_5');
    expect(m.shader, 'shaders/f1226_chebyshev_julia_t_5_gpu.frag');
  });

  test('F1226ChebyshevJuliaT5 presets are well-formed', () {
    final m = F1226ChebyshevJuliaT5();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1226ChebyshevJuliaT5 metadata is consistent', () {
    final m = F1226ChebyshevJuliaT5();
    expect(m.metadata.id, m.id);
  });
}
