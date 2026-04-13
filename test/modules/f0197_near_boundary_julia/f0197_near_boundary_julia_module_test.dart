// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0197_near_boundary_julia/f0197_near_boundary_julia_module.dart';

void main() {
  test('F0197NearBoundaryJulia instantiates', () {
    final m = F0197NearBoundaryJulia();
    expect(m.id, 'f0197_near_boundary_julia');
    expect(m.shader, 'shaders/f0197_near_boundary_julia_gpu.frag');
  });

  test('F0197NearBoundaryJulia presets are well-formed', () {
    final m = F0197NearBoundaryJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0197NearBoundaryJulia metadata is consistent', () {
    final m = F0197NearBoundaryJulia();
    expect(m.metadata.id, m.id);
  });
}
