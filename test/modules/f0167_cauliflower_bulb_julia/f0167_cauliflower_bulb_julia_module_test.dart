// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0167_cauliflower_bulb_julia/f0167_cauliflower_bulb_julia_module.dart';

void main() {
  test('F0167CauliflowerBulbJulia instantiates', () {
    final m = F0167CauliflowerBulbJulia();
    expect(m.id, 'f0167_cauliflower_bulb_julia');
    expect(m.shader, 'shaders/f0167_cauliflower_bulb_julia_gpu.frag');
  });

  test('F0167CauliflowerBulbJulia presets are well-formed', () {
    final m = F0167CauliflowerBulbJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0167CauliflowerBulbJulia metadata is consistent', () {
    final m = F0167CauliflowerBulbJulia();
    expect(m.metadata.id, m.id);
  });
}
