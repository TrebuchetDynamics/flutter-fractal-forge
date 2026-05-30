// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/cellular_stochastic/f1004_land_rush_b35_s234578/f1004_land_rush_b35_s234578_module.dart';

void main() {
  test('F1004LandRushB35S234578 instantiates', () {
    final m = F1004LandRushB35S234578();
    expect(m.id, 'f1004_land_rush_b35_s234578');
    expect(m.shader, 'shaders/f1004_land_rush_b35_s234578_gpu.frag');
  });

  test('F1004LandRushB35S234578 presets are well-formed', () {
    final m = F1004LandRushB35S234578();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1004LandRushB35S234578 metadata is consistent', () {
    final m = F1004LandRushB35S234578();
    expect(m.metadata.id, m.id);
  });
}
