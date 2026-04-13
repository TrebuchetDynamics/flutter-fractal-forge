// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0114_burning_ship_d_8/f0114_burning_ship_d_8_module.dart';

void main() {
  test('F0114BurningShipD8 instantiates', () {
    final m = F0114BurningShipD8();
    expect(m.id, 'f0114_burning_ship_d_8');
    expect(m.shader, 'shaders/f0114_burning_ship_d_8_gpu.frag');
  });

  test('F0114BurningShipD8 presets are well-formed', () {
    final m = F0114BurningShipD8();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0114BurningShipD8 metadata is consistent', () {
    final m = F0114BurningShipD8();
    expect(m.metadata.id, m.id);
  });
}
