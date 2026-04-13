// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0175_near_elephant_julia/f0175_near_elephant_julia_module.dart';

void main() {
  test('F0175NearElephantJulia instantiates', () {
    final m = F0175NearElephantJulia();
    expect(m.id, 'f0175_near_elephant_julia');
    expect(m.shader, 'shaders/f0175_near_elephant_julia_gpu.frag');
  });

  test('F0175NearElephantJulia presets are well-formed', () {
    final m = F0175NearElephantJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0175NearElephantJulia metadata is consistent', () {
    final m = F0175NearElephantJulia();
    expect(m.metadata.id, m.id);
  });
}
