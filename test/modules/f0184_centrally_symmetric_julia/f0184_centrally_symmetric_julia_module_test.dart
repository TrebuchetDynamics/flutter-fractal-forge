// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0184_centrally_symmetric_julia/f0184_centrally_symmetric_julia_module.dart';

void main() {
  test('F0184CentrallySymmetricJulia instantiates', () {
    final m = F0184CentrallySymmetricJulia();
    expect(m.id, 'f0184_centrally_symmetric_julia');
    expect(m.shader, 'shaders/f0184_centrally_symmetric_julia_gpu.frag');
  });

  test('F0184CentrallySymmetricJulia presets are well-formed', () {
    final m = F0184CentrallySymmetricJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0184CentrallySymmetricJulia metadata is consistent', () {
    final m = F0184CentrallySymmetricJulia();
    expect(m.metadata.id, m.id);
  });
}
