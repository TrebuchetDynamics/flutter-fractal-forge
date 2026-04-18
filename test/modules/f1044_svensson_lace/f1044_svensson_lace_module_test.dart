// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1044_svensson_lace/f1044_svensson_lace_module.dart';

void main() {
  test('F1044SvenssonLace instantiates', () {
    final m = F1044SvenssonLace();
    expect(m.id, 'f1044_svensson_lace');
    expect(m.shader, 'shaders/f1044_svensson_lace_gpu.frag');
  });

  test('F1044SvenssonLace presets are well-formed', () {
    final m = F1044SvenssonLace();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1044SvenssonLace metadata is consistent', () {
    final m = F1044SvenssonLace();
    expect(m.metadata.id, m.id);
  });
}
