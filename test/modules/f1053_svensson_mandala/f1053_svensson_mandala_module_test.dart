// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f1053_svensson_mandala/f1053_svensson_mandala_module.dart';

void main() {
  test('F1053SvenssonMandala instantiates', () {
    final m = F1053SvenssonMandala();
    expect(m.id, 'f1053_svensson_mandala');
    expect(m.shader, 'shaders/f1053_svensson_mandala_gpu.frag');
  });

  test('F1053SvenssonMandala presets are well-formed', () {
    final m = F1053SvenssonMandala();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1053SvenssonMandala metadata is consistent', () {
    final m = F1053SvenssonMandala();
    expect(m.metadata.id, m.id);
  });
}
