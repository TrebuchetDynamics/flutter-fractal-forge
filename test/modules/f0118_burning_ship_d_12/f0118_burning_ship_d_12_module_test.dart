// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0118_burning_ship_d_12/f0118_burning_ship_d_12_module.dart';

void main() {
  test('F0118BurningShipD12 instantiates', () {
    final m = F0118BurningShipD12();
    expect(m.id, 'f0118_burning_ship_d_12');
    expect(m.shader, 'shaders/f0118_burning_ship_d_12_gpu.frag');
  });

  test('F0118BurningShipD12 presets are well-formed', () {
    final m = F0118BurningShipD12();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0118BurningShipD12 metadata is consistent', () {
    final m = F0118BurningShipD12();
    expect(m.metadata.id, m.id);
  });
}
