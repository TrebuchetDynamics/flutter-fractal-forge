// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0198_grainy_julia/f0198_grainy_julia_module.dart';

void main() {
  test('F0198GrainyJulia instantiates', () {
    final m = F0198GrainyJulia();
    expect(m.id, 'f0198_grainy_julia');
    expect(m.shader, 'shaders/f0198_grainy_julia_gpu.frag');
  });

  test('F0198GrainyJulia presets are well-formed', () {
    final m = F0198GrainyJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0198GrainyJulia metadata is consistent', () {
    final m = F0198GrainyJulia();
    expect(m.metadata.id, m.id);
  });
}
