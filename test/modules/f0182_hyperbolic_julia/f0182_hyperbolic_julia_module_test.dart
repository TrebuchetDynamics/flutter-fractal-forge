// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0182_hyperbolic_julia/f0182_hyperbolic_julia_module.dart';

void main() {
  test('F0182HyperbolicJulia instantiates', () {
    final m = F0182HyperbolicJulia();
    expect(m.id, 'f0182_hyperbolic_julia');
    expect(m.shader, 'shaders/f0182_hyperbolic_julia_gpu.frag');
  });

  test('F0182HyperbolicJulia presets are well-formed', () {
    final m = F0182HyperbolicJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0182HyperbolicJulia metadata is consistent', () {
    final m = F0182HyperbolicJulia();
    expect(m.metadata.id, m.id);
  });
}
