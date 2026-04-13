// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0479_tendril_crown/f0479_tendril_crown_module.dart';

void main() {
  test('F0479TendrilCrown instantiates', () {
    final m = F0479TendrilCrown();
    expect(m.id, 'f0479_tendril_crown');
    expect(m.shader, 'shaders/f0479_tendril_crown_gpu.frag');
  });

  test('F0479TendrilCrown presets are well-formed', () {
    final m = F0479TendrilCrown();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0479TendrilCrown metadata is consistent', () {
    final m = F0479TendrilCrown();
    expect(m.metadata.id, m.id);
  });
}
