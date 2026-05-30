// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1050_svensson_bay/f1050_svensson_bay_module.dart';

void main() {
  test('F1050SvenssonBay instantiates', () {
    final m = F1050SvenssonBay();
    expect(m.id, 'f1050_svensson_bay');
    expect(m.shader, 'shaders/f1050_svensson_bay_gpu.frag');
  });

  test('F1050SvenssonBay presets are well-formed', () {
    final m = F1050SvenssonBay();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1050SvenssonBay metadata is consistent', () {
    final m = F1050SvenssonBay();
    expect(m.metadata.id, m.id);
  });
}
