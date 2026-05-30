// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0180_jumping_jack_julia/f0180_jumping_jack_julia_module.dart';

void main() {
  test('F0180JumpingJackJulia instantiates', () {
    final m = F0180JumpingJackJulia();
    expect(m.id, 'f0180_jumping_jack_julia');
    expect(m.shader, 'shaders/f0180_jumping_jack_julia_gpu.frag');
  });

  test('F0180JumpingJackJulia presets are well-formed', () {
    final m = F0180JumpingJackJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0180JumpingJackJulia metadata is consistent', () {
    final m = F0180JumpingJackJulia();
    expect(m.metadata.id, m.id);
  });
}
