// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0484_miniature_julia_region/f0484_miniature_julia_region_module.dart';

void main() {
  test('F0484MiniatureJuliaRegion instantiates', () {
    final m = F0484MiniatureJuliaRegion();
    expect(m.id, 'f0484_miniature_julia_region');
    expect(m.shader, 'shaders/f0484_miniature_julia_region_gpu.frag');
  });

  test('F0484MiniatureJuliaRegion presets are well-formed', () {
    final m = F0484MiniatureJuliaRegion();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0484MiniatureJuliaRegion metadata is consistent', () {
    final m = F0484MiniatureJuliaRegion();
    expect(m.metadata.id, m.id);
  });
}
