// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f1134_fractal_flame_v33_juliascope/f1134_fractal_flame_v33_juliascope_module.dart';

void main() {
  test('F1134FractalFlameV33Juliascope instantiates', () {
    final m = F1134FractalFlameV33Juliascope();
    expect(m.id, 'f1134_fractal_flame_v33_juliascope');
    expect(m.shader, 'shaders/f1134_fractal_flame_v33_juliascope_gpu.frag');
  });

  test('F1134FractalFlameV33Juliascope presets are well-formed', () {
    final m = F1134FractalFlameV33Juliascope();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1134FractalFlameV33Juliascope metadata is consistent', () {
    final m = F1134FractalFlameV33Juliascope();
    expect(m.metadata.id, m.id);
  });
}
