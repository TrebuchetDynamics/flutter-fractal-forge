// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1056_svensson_twist/f1056_svensson_twist_module.dart';

void main() {
  test('F1056SvenssonTwist instantiates', () {
    final m = F1056SvenssonTwist();
    expect(m.id, 'f1056_svensson_twist');
    expect(m.shader, 'shaders/f1056_svensson_twist_gpu.frag');
  });

  test('F1056SvenssonTwist presets are well-formed', () {
    final m = F1056SvenssonTwist();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1056SvenssonTwist metadata is consistent', () {
    final m = F1056SvenssonTwist();
    expect(m.metadata.id, m.id);
  });
}
