// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0161_swirl_julia/f0161_swirl_julia_module.dart';

void main() {
  test('F0161SwirlJulia instantiates', () {
    final m = F0161SwirlJulia();
    expect(m.id, 'f0161_swirl_julia');
    expect(m.shader, 'shaders/f0161_swirl_julia_gpu.frag');
  });

  test('F0161SwirlJulia presets are well-formed', () {
    final m = F0161SwirlJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0161SwirlJulia metadata is consistent', () {
    final m = F0161SwirlJulia();
    expect(m.metadata.id, m.id);
  });
}
