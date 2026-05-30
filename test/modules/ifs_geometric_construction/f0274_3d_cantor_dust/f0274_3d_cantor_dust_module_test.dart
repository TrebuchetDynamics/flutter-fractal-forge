// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f0274_3d_cantor_dust/f0274_3d_cantor_dust_module.dart';

void main() {
  test('F02743dCantorDust instantiates', () {
    final m = F02743dCantorDust();
    expect(m.id, 'f0274_3d_cantor_dust');
    expect(m.shader, 'shaders/f0274_3d_cantor_dust_gpu.frag');
  });

  test('F02743dCantorDust presets are well-formed', () {
    final m = F02743dCantorDust();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F02743dCantorDust metadata is consistent', () {
    final m = F02743dCantorDust();
    expect(m.metadata.id, m.id);
  });
}
