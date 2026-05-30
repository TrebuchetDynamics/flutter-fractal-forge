// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0162_lightning_julia/f0162_lightning_julia_module.dart';

void main() {
  test('F0162LightningJulia instantiates', () {
    final m = F0162LightningJulia();
    expect(m.id, 'f0162_lightning_julia');
    expect(m.shader, 'shaders/f0162_lightning_julia_gpu.frag');
  });

  test('F0162LightningJulia presets are well-formed', () {
    final m = F0162LightningJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0162LightningJulia metadata is consistent', () {
    final m = F0162LightningJulia();
    expect(m.metadata.id, m.id);
  });
}
