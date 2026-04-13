// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0140_burning_ship_z_2_5/f0140_burning_ship_z_2_5_module.dart';

void main() {
  test('F0140BurningShipZ25 instantiates', () {
    final m = F0140BurningShipZ25();
    expect(m.id, 'f0140_burning_ship_z_2_5');
    expect(m.shader, 'shaders/f0140_burning_ship_z_2_5_gpu.frag');
  });

  test('F0140BurningShipZ25 presets are well-formed', () {
    final m = F0140BurningShipZ25();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0140BurningShipZ25 metadata is consistent', () {
    final m = F0140BurningShipZ25();
    expect(m.metadata.id, m.id);
  });
}
