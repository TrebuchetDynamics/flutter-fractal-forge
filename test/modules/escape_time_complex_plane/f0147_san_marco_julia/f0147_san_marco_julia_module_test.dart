// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0147_san_marco_julia/f0147_san_marco_julia_module.dart';

void main() {
  test('F0147SanMarcoJulia instantiates', () {
    final m = F0147SanMarcoJulia();
    expect(m.id, 'f0147_san_marco_julia');
    expect(m.shader, 'shaders/f0147_san_marco_julia_gpu.frag');
  });

  test('F0147SanMarcoJulia presets are well-formed', () {
    final m = F0147SanMarcoJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0147SanMarcoJulia metadata is consistent', () {
    final m = F0147SanMarcoJulia();
    expect(m.metadata.id, m.id);
  });
}
