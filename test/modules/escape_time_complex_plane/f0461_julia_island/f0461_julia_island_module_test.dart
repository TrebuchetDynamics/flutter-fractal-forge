// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0461_julia_island/f0461_julia_island_module.dart';

void main() {
  test('F0461JuliaIsland instantiates', () {
    final m = F0461JuliaIsland();
    expect(m.id, 'f0461_julia_island');
    expect(m.shader, 'shaders/f0461_julia_island_gpu.frag');
  });

  test('F0461JuliaIsland presets are well-formed', () {
    final m = F0461JuliaIsland();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0461JuliaIsland metadata is consistent', () {
    final m = F0461JuliaIsland();
    expect(m.metadata.id, m.id);
  });
}
