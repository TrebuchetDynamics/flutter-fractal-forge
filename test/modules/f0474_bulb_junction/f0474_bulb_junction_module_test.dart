// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0474_bulb_junction/f0474_bulb_junction_module.dart';

void main() {
  test('F0474BulbJunction instantiates', () {
    final m = F0474BulbJunction();
    expect(m.id, 'f0474_bulb_junction');
    expect(m.shader, 'shaders/f0474_bulb_junction_gpu.frag');
  });

  test('F0474BulbJunction presets are well-formed', () {
    final m = F0474BulbJunction();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0474BulbJunction metadata is consistent', () {
    final m = F0474BulbJunction();
    expect(m.metadata.id, m.id);
  });
}
