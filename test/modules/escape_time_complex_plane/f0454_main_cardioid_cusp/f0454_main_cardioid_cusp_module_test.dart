// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0454_main_cardioid_cusp/f0454_main_cardioid_cusp_module.dart';

void main() {
  test('F0454MainCardioidCusp instantiates', () {
    final m = F0454MainCardioidCusp();
    expect(m.id, 'f0454_main_cardioid_cusp');
    expect(m.shader, 'shaders/f0454_main_cardioid_cusp_gpu.frag');
  });

  test('F0454MainCardioidCusp presets are well-formed', () {
    final m = F0454MainCardioidCusp();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0454MainCardioidCusp metadata is consistent', () {
    final m = F0454MainCardioidCusp();
    expect(m.metadata.id, m.id);
  });
}
