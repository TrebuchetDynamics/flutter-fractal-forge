// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0153_dragon_julia/f0153_dragon_julia_module.dart';

void main() {
  test('F0153DragonJulia instantiates', () {
    final m = F0153DragonJulia();
    expect(m.id, 'f0153_dragon_julia');
    expect(m.shader, 'shaders/f0153_dragon_julia_gpu.frag');
  });

  test('F0153DragonJulia presets are well-formed', () {
    final m = F0153DragonJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0153DragonJulia metadata is consistent', () {
    final m = F0153DragonJulia();
    expect(m.metadata.id, m.id);
  });
}
