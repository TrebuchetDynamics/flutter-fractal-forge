// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0193_gossamer_julia/f0193_gossamer_julia_module.dart';

void main() {
  test('F0193GossamerJulia instantiates', () {
    final m = F0193GossamerJulia();
    expect(m.id, 'f0193_gossamer_julia');
    expect(m.shader, 'shaders/f0193_gossamer_julia_gpu.frag');
  });

  test('F0193GossamerJulia presets are well-formed', () {
    final m = F0193GossamerJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0193GossamerJulia metadata is consistent', () {
    final m = F0193GossamerJulia();
    expect(m.metadata.id, m.id);
  });
}
