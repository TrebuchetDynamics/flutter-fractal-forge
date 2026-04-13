// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0191_spring_julia/f0191_spring_julia_module.dart';

void main() {
  test('F0191SpringJulia instantiates', () {
    final m = F0191SpringJulia();
    expect(m.id, 'f0191_spring_julia');
    expect(m.shader, 'shaders/f0191_spring_julia_gpu.frag');
  });

  test('F0191SpringJulia presets are well-formed', () {
    final m = F0191SpringJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0191SpringJulia metadata is consistent', () {
    final m = F0191SpringJulia();
    expect(m.metadata.id, m.id);
  });
}
