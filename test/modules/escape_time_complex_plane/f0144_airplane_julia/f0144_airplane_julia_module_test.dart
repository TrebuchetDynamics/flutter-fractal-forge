// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0144_airplane_julia/f0144_airplane_julia_module.dart';

void main() {
  test('F0144AirplaneJulia instantiates', () {
    final m = F0144AirplaneJulia();
    expect(m.id, 'f0144_airplane_julia');
    expect(m.shader, 'shaders/f0144_airplane_julia_gpu.frag');
  });

  test('F0144AirplaneJulia presets are well-formed', () {
    final m = F0144AirplaneJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0144AirplaneJulia metadata is consistent', () {
    final m = F0144AirplaneJulia();
    expect(m.metadata.id, m.id);
  });
}
