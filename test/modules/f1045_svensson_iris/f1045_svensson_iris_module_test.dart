// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1045_svensson_iris/f1045_svensson_iris_module.dart';

void main() {
  test('F1045SvenssonIris instantiates', () {
    final m = F1045SvenssonIris();
    expect(m.id, 'f1045_svensson_iris');
    expect(m.shader, 'shaders/f1045_svensson_iris_gpu.frag');
  });

  test('F1045SvenssonIris presets are well-formed', () {
    final m = F1045SvenssonIris();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1045SvenssonIris metadata is consistent', () {
    final m = F1045SvenssonIris();
    expect(m.metadata.id, m.id);
  });
}
