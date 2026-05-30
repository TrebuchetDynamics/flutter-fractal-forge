// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1060_svensson_fan/f1060_svensson_fan_module.dart';

void main() {
  test('F1060SvenssonFan instantiates', () {
    final m = F1060SvenssonFan();
    expect(m.id, 'f1060_svensson_fan');
    expect(m.shader, 'shaders/f1060_svensson_fan_gpu.frag');
  });

  test('F1060SvenssonFan presets are well-formed', () {
    final m = F1060SvenssonFan();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1060SvenssonFan metadata is consistent', () {
    final m = F1060SvenssonFan();
    expect(m.metadata.id, m.id);
  });
}
