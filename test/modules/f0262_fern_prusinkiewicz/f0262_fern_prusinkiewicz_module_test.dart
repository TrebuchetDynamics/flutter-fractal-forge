// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/l_systems_space_filling/f0262_fern_prusinkiewicz/f0262_fern_prusinkiewicz_module.dart';

void main() {
  test('F0262FernPrusinkiewicz instantiates', () {
    final m = F0262FernPrusinkiewicz();
    expect(m.id, 'f0262_fern_prusinkiewicz');
    expect(m.shader, 'shaders/f0262_fern_prusinkiewicz_gpu.frag');
  });

  test('F0262FernPrusinkiewicz presets are well-formed', () {
    final m = F0262FernPrusinkiewicz();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0262FernPrusinkiewicz metadata is consistent', () {
    final m = F0262FernPrusinkiewicz();
    expect(m.metadata.id, m.id);
  });
}
