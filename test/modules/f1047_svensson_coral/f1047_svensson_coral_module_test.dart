// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1047_svensson_coral/f1047_svensson_coral_module.dart';

void main() {
  test('F1047SvenssonCoral instantiates', () {
    final m = F1047SvenssonCoral();
    expect(m.id, 'f1047_svensson_coral');
    expect(m.shader, 'shaders/f1047_svensson_coral_gpu.frag');
  });

  test('F1047SvenssonCoral presets are well-formed', () {
    final m = F1047SvenssonCoral();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1047SvenssonCoral metadata is consistent', () {
    final m = F1047SvenssonCoral();
    expect(m.metadata.id, m.id);
  });
}
