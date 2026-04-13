// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/strange_attractors/f0021_sprott_h/f0021_sprott_h_module.dart';

void main() {
  test('F0021SprottH instantiates', () {
    final m = F0021SprottH();
    expect(m.id, 'f0021_sprott_h');
    expect(m.shader, 'shaders/f0021_sprott_h_gpu.frag');
  });

  test('F0021SprottH presets are well-formed', () {
    final m = F0021SprottH();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0021SprottH metadata is consistent', () {
    final m = F0021SprottH();
    expect(m.metadata.id, m.id);
  });
}
