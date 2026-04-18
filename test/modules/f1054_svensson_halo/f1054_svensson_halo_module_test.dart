// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1054_svensson_halo/f1054_svensson_halo_module.dart';

void main() {
  test('F1054SvenssonHalo instantiates', () {
    final m = F1054SvenssonHalo();
    expect(m.id, 'f1054_svensson_halo');
    expect(m.shader, 'shaders/f1054_svensson_halo_gpu.frag');
  });

  test('F1054SvenssonHalo presets are well-formed', () {
    final m = F1054SvenssonHalo();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1054SvenssonHalo metadata is consistent', () {
    final m = F1054SvenssonHalo();
    expect(m.metadata.id, m.id);
  });
}
