// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0143_dendrite_julia/f0143_dendrite_julia_module.dart';

void main() {
  test('F0143DendriteJulia instantiates', () {
    final m = F0143DendriteJulia();
    expect(m.id, 'f0143_dendrite_julia');
    expect(m.shader, 'shaders/f0143_dendrite_julia_gpu.frag');
  });

  test('F0143DendriteJulia presets are well-formed', () {
    final m = F0143DendriteJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0143DendriteJulia metadata is consistent', () {
    final m = F0143DendriteJulia();
    expect(m.metadata.id, m.id);
  });
}
