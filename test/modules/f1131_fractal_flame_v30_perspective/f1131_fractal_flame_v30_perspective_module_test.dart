// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f1131_fractal_flame_v30_perspective/f1131_fractal_flame_v30_perspective_module.dart';

void main() {
  test('F1131FractalFlameV30Perspective instantiates', () {
    final m = F1131FractalFlameV30Perspective();
    expect(m.id, 'f1131_fractal_flame_v30_perspective');
    expect(m.shader, 'shaders/f1131_fractal_flame_v30_perspective_gpu.frag');
  });

  test('F1131FractalFlameV30Perspective presets are well-formed', () {
    final m = F1131FractalFlameV30Perspective();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1131FractalFlameV30Perspective metadata is consistent', () {
    final m = F1131FractalFlameV30Perspective();
    expect(m.metadata.id, m.id);
  });
}
