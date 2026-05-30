// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0836_peano_curve_original_1890/f0836_peano_curve_original_1890_module.dart';

void main() {
  test('F0836PeanoCurveOriginal1890 instantiates', () {
    final m = F0836PeanoCurveOriginal1890();
    expect(m.id, 'f0836_peano_curve_original_1890');
    expect(m.shader, 'shaders/f0836_peano_curve_original_1890_gpu.frag');
  });

  test('F0836PeanoCurveOriginal1890 presets are well-formed', () {
    final m = F0836PeanoCurveOriginal1890();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0836PeanoCurveOriginal1890 metadata is consistent', () {
    final m = F0836PeanoCurveOriginal1890();
    expect(m.metadata.id, m.id);
  });
}
