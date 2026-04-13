// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0177_mink_julia/f0177_mink_julia_module.dart';

void main() {
  test('F0177MinkJulia instantiates', () {
    final m = F0177MinkJulia();
    expect(m.id, 'f0177_mink_julia');
    expect(m.shader, 'shaders/f0177_mink_julia_gpu.frag');
  });

  test('F0177MinkJulia presets are well-formed', () {
    final m = F0177MinkJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0177MinkJulia metadata is consistent', () {
    final m = F0177MinkJulia();
    expect(m.metadata.id, m.id);
  });
}
