// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f1152_buddhabrot_burning_ship/f1152_buddhabrot_burning_ship_module.dart';

void main() {
  test('F1152BuddhabrotBurningShip instantiates', () {
    final m = F1152BuddhabrotBurningShip();
    expect(m.id, 'f1152_buddhabrot_burning_ship');
    expect(m.shader, 'shaders/f1152_buddhabrot_burning_ship_gpu.frag');
  });

  test('F1152BuddhabrotBurningShip presets are well-formed', () {
    final m = F1152BuddhabrotBurningShip();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F1152BuddhabrotBurningShip metadata is consistent', () {
    final m = F1152BuddhabrotBurningShip();
    expect(m.metadata.id, m.id);
  });
}
