// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1043_svensson_storm/f1043_svensson_storm_module.dart';

void main() {
  test('F1043SvenssonStorm instantiates', () {
    final m = F1043SvenssonStorm();
    expect(m.id, 'f1043_svensson_storm');
    expect(m.shader, 'shaders/f1043_svensson_storm_gpu.frag');
  });

  test('F1043SvenssonStorm presets are well-formed', () {
    final m = F1043SvenssonStorm();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1043SvenssonStorm metadata is consistent', () {
    final m = F1043SvenssonStorm();
    expect(m.metadata.id, m.id);
  });
}
