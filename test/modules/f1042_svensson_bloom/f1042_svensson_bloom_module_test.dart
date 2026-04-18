// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1042_svensson_bloom/f1042_svensson_bloom_module.dart';

void main() {
  test('F1042SvenssonBloom instantiates', () {
    final m = F1042SvenssonBloom();
    expect(m.id, 'f1042_svensson_bloom');
    expect(m.shader, 'shaders/f1042_svensson_bloom_gpu.frag');
  });

  test('F1042SvenssonBloom presets are well-formed', () {
    final m = F1042SvenssonBloom();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1042SvenssonBloom metadata is consistent', () {
    final m = F1042SvenssonBloom();
    expect(m.metadata.id, m.id);
  });
}
