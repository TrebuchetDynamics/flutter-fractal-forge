// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1052_svensson_arc/f1052_svensson_arc_module.dart';

void main() {
  test('F1052SvenssonArc instantiates', () {
    final m = F1052SvenssonArc();
    expect(m.id, 'f1052_svensson_arc');
    expect(m.shader, 'shaders/f1052_svensson_arc_gpu.frag');
  });

  test('F1052SvenssonArc presets are well-formed', () {
    final m = F1052SvenssonArc();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1052SvenssonArc metadata is consistent', () {
    final m = F1052SvenssonArc();
    expect(m.metadata.id, m.id);
  });
}
