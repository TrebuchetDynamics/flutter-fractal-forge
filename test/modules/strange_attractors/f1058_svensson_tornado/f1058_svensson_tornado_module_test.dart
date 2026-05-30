// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1058_svensson_tornado/f1058_svensson_tornado_module.dart';

void main() {
  test('F1058SvenssonTornado instantiates', () {
    final m = F1058SvenssonTornado();
    expect(m.id, 'f1058_svensson_tornado');
    expect(m.shader, 'shaders/f1058_svensson_tornado_gpu.frag');
  });

  test('F1058SvenssonTornado presets are well-formed', () {
    final m = F1058SvenssonTornado();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1058SvenssonTornado metadata is consistent', () {
    final m = F1058SvenssonTornado();
    expect(m.metadata.id, m.id);
  });
}
