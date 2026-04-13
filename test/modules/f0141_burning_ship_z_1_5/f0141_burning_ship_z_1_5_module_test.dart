// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0141_burning_ship_z_1_5/f0141_burning_ship_z_1_5_module.dart';

void main() {
  test('F0141BurningShipZ15 instantiates', () {
    final m = F0141BurningShipZ15();
    expect(m.id, 'f0141_burning_ship_z_1_5');
    expect(m.shader, 'shaders/f0141_burning_ship_z_1_5_gpu.frag');
  });

  test('F0141BurningShipZ15 presets are well-formed', () {
    final m = F0141BurningShipZ15();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0141BurningShipZ15 metadata is consistent', () {
    final m = F0141BurningShipZ15();
    expect(m.metadata.id, m.id);
  });
}
