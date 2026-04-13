// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0194_sparse_dust_julia/f0194_sparse_dust_julia_module.dart';

void main() {
  test('F0194SparseDustJulia instantiates', () {
    final m = F0194SparseDustJulia();
    expect(m.id, 'f0194_sparse_dust_julia');
    expect(m.shader, 'shaders/f0194_sparse_dust_julia_gpu.frag');
  });

  test('F0194SparseDustJulia presets are well-formed', () {
    final m = F0194SparseDustJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0194SparseDustJulia metadata is consistent', () {
    final m = F0194SparseDustJulia();
    expect(m.metadata.id, m.id);
  });
}
