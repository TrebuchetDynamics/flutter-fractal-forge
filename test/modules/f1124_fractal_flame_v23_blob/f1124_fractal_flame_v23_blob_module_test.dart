// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f1124_fractal_flame_v23_blob/f1124_fractal_flame_v23_blob_module.dart';

void main() {
  test('F1124FractalFlameV23Blob instantiates', () {
    final m = F1124FractalFlameV23Blob();
    expect(m.id, 'f1124_fractal_flame_v23_blob');
    expect(m.shader, 'shaders/f1124_fractal_flame_v23_blob_gpu.frag');
  });

  test('F1124FractalFlameV23Blob presets are well-formed', () {
    final m = F1124FractalFlameV23Blob();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1124FractalFlameV23Blob metadata is consistent', () {
    final m = F1124FractalFlameV23Blob();
    expect(m.metadata.id, m.id);
  });
}
