// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f1125_fractal_flame_v24_pdj/f1125_fractal_flame_v24_pdj_module.dart';

void main() {
  test('F1125FractalFlameV24Pdj instantiates', () {
    final m = F1125FractalFlameV24Pdj();
    expect(m.id, 'f1125_fractal_flame_v24_pdj');
    expect(m.shader, 'shaders/f1125_fractal_flame_v24_pdj_gpu.frag');
  });

  test('F1125FractalFlameV24Pdj presets are well-formed', () {
    final m = F1125FractalFlameV24Pdj();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1125FractalFlameV24Pdj metadata is consistent', () {
    final m = F1125FractalFlameV24Pdj();
    expect(m.metadata.id, m.id);
  });
}
