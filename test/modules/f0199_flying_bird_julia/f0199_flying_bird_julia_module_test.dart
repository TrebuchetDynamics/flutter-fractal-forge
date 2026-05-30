// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0199_flying_bird_julia/f0199_flying_bird_julia_module.dart';

void main() {
  test('F0199FlyingBirdJulia instantiates', () {
    final m = F0199FlyingBirdJulia();
    expect(m.id, 'f0199_flying_bird_julia');
    expect(m.shader, 'shaders/f0199_flying_bird_julia_gpu.frag');
  });

  test('F0199FlyingBirdJulia presets are well-formed', () {
    final m = F0199FlyingBirdJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0199FlyingBirdJulia metadata is consistent', () {
    final m = F0199FlyingBirdJulia();
    expect(m.metadata.id, m.id);
  });
}
