// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0113_burning_ship_d_7/f0113_burning_ship_d_7_module.dart';

void main() {
  test('F0113BurningShipD7 instantiates', () {
    final m = F0113BurningShipD7();
    expect(m.id, 'f0113_burning_ship_d_7');
    expect(m.shader, 'shaders/f0113_burning_ship_d_7_gpu.frag');
  });

  test('F0113BurningShipD7 presets are well-formed', () {
    final m = F0113BurningShipD7();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0113BurningShipD7 metadata is consistent', () {
    final m = F0113BurningShipD7();
    expect(m.metadata.id, m.id);
  });
}
