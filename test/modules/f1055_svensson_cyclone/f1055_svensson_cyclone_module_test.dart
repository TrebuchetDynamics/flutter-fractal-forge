// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1055_svensson_cyclone/f1055_svensson_cyclone_module.dart';

void main() {
  test('F1055SvenssonCyclone instantiates', () {
    final m = F1055SvenssonCyclone();
    expect(m.id, 'f1055_svensson_cyclone');
    expect(m.shader, 'shaders/f1055_svensson_cyclone_gpu.frag');
  });

  test('F1055SvenssonCyclone presets are well-formed', () {
    final m = F1055SvenssonCyclone();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1055SvenssonCyclone metadata is consistent', () {
    final m = F1055SvenssonCyclone();
    expect(m.metadata.id, m.id);
  });
}
