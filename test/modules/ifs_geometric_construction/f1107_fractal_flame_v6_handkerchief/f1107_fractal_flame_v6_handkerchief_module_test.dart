// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/ifs_geometric_construction/f1107_fractal_flame_v6_handkerchief/f1107_fractal_flame_v6_handkerchief_module.dart';

void main() {
  test('F1107FractalFlameV6Handkerchief instantiates', () {
    final m = F1107FractalFlameV6Handkerchief();
    expect(m.id, 'f1107_fractal_flame_v6_handkerchief');
    expect(m.shader, 'shaders/f1107_fractal_flame_v6_handkerchief_gpu.frag');
  });

  test('F1107FractalFlameV6Handkerchief presets are well-formed', () {
    final m = F1107FractalFlameV6Handkerchief();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1107FractalFlameV6Handkerchief metadata is consistent', () {
    final m = F1107FractalFlameV6Handkerchief();
    expect(m.metadata.id, m.id);
  });
}
