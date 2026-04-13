// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0189_medusa_julia/f0189_medusa_julia_module.dart';

void main() {
  test('F0189MedusaJulia instantiates', () {
    final m = F0189MedusaJulia();
    expect(m.id, 'f0189_medusa_julia');
    expect(m.shader, 'shaders/f0189_medusa_julia_gpu.frag');
  });

  test('F0189MedusaJulia presets are well-formed', () {
    final m = F0189MedusaJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0189MedusaJulia metadata is consistent', () {
    final m = F0189MedusaJulia();
    expect(m.metadata.id, m.id);
  });
}
