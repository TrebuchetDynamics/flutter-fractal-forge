// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0117_burning_ship_d_11/f0117_burning_ship_d_11_module.dart';

void main() {
  test('F0117BurningShipD11 instantiates', () {
    final m = F0117BurningShipD11();
    expect(m.id, 'f0117_burning_ship_d_11');
    expect(m.shader, 'shaders/f0117_burning_ship_d_11_gpu.frag');
  });

  test('F0117BurningShipD11 presets are well-formed', () {
    final m = F0117BurningShipD11();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0117BurningShipD11 metadata is consistent', () {
    final m = F0117BurningShipD11();
    expect(m.metadata.id, m.id);
  });
}
