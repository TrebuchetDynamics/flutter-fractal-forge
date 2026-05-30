// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0146_basilica_julia/f0146_basilica_julia_module.dart';

void main() {
  test('F0146BasilicaJulia instantiates', () {
    final m = F0146BasilicaJulia();
    expect(m.id, 'f0146_basilica_julia');
    expect(m.shader, 'shaders/f0146_basilica_julia_gpu.frag');
  });

  test('F0146BasilicaJulia presets are well-formed', () {
    final m = F0146BasilicaJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0146BasilicaJulia metadata is consistent', () {
    final m = F0146BasilicaJulia();
    expect(m.metadata.id, m.id);
  });
}
