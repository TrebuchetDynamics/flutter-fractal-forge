// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0174_elephant_valley_julia/f0174_elephant_valley_julia_module.dart';

void main() {
  test('F0174ElephantValleyJulia instantiates', () {
    final m = F0174ElephantValleyJulia();
    expect(m.id, 'f0174_elephant_valley_julia');
    expect(m.shader, 'shaders/f0174_elephant_valley_julia_gpu.frag');
  });

  test('F0174ElephantValleyJulia presets are well-formed', () {
    final m = F0174ElephantValleyJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0174ElephantValleyJulia metadata is consistent', () {
    final m = F0174ElephantValleyJulia();
    expect(m.metadata.id, m.id);
  });
}
