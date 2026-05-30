// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0150_fatou_dust_julia/f0150_fatou_dust_julia_module.dart';

void main() {
  test('F0150FatouDustJulia instantiates', () {
    final m = F0150FatouDustJulia();
    expect(m.id, 'f0150_fatou_dust_julia');
    expect(m.shader, 'shaders/f0150_fatou_dust_julia_gpu.frag');
  });

  test('F0150FatouDustJulia presets are well-formed', () {
    final m = F0150FatouDustJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0150FatouDustJulia metadata is consistent', () {
    final m = F0150FatouDustJulia();
    expect(m.metadata.id, m.id);
  });
}
