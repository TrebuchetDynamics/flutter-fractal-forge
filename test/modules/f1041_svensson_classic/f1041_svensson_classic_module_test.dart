// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f1041_svensson_classic/f1041_svensson_classic_module.dart';

void main() {
  test('F1041SvenssonClassic instantiates', () {
    final m = F1041SvenssonClassic();
    expect(m.id, 'f1041_svensson_classic');
    expect(m.shader, 'shaders/f1041_svensson_classic_gpu.frag');
  });

  test('F1041SvenssonClassic presets are well-formed', () {
    final m = F1041SvenssonClassic();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1041SvenssonClassic metadata is consistent', () {
    final m = F1041SvenssonClassic();
    expect(m.metadata.id, m.id);
  });
}
