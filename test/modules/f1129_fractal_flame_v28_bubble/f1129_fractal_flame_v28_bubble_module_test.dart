// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/ifs_geometric_construction/f1129_fractal_flame_v28_bubble/f1129_fractal_flame_v28_bubble_module.dart';

void main() {
  test('F1129FractalFlameV28Bubble instantiates', () {
    final m = F1129FractalFlameV28Bubble();
    expect(m.id, 'f1129_fractal_flame_v28_bubble');
    expect(m.shader, 'shaders/f1129_fractal_flame_v28_bubble_gpu.frag');
  });

  test('F1129FractalFlameV28Bubble presets are well-formed', () {
    final m = F1129FractalFlameV28Bubble();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1129FractalFlameV28Bubble metadata is consistent', () {
    final m = F1129FractalFlameV28Bubble();
    expect(m.metadata.id, m.id);
  });
}
