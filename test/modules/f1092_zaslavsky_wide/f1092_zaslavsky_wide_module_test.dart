// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1092_zaslavsky_wide/f1092_zaslavsky_wide_module.dart';

void main() {
  test('F1092ZaslavskyWide instantiates', () {
    final m = F1092ZaslavskyWide();
    expect(m.id, 'f1092_zaslavsky_wide');
    expect(m.shader, 'shaders/f1092_zaslavsky_wide_gpu.frag');
  });

  test('F1092ZaslavskyWide presets are well-formed', () {
    final m = F1092ZaslavskyWide();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1092ZaslavskyWide metadata is consistent', () {
    final m = F1092ZaslavskyWide();
    expect(m.metadata.id, m.id);
  });
}
