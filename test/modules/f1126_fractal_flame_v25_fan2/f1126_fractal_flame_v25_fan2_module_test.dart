// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f1126_fractal_flame_v25_fan2/f1126_fractal_flame_v25_fan2_module.dart';

void main() {
  test('F1126FractalFlameV25Fan2 instantiates', () {
    final m = F1126FractalFlameV25Fan2();
    expect(m.id, 'f1126_fractal_flame_v25_fan2');
    expect(m.shader, 'shaders/f1126_fractal_flame_v25_fan2_gpu.frag');
  });

  test('F1126FractalFlameV25Fan2 presets are well-formed', () {
    final m = F1126FractalFlameV25Fan2();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1126FractalFlameV25Fan2 metadata is consistent', () {
    final m = F1126FractalFlameV25Fan2();
    expect(m.metadata.id, m.id);
  });
}
