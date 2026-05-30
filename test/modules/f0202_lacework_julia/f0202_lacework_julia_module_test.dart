// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0202_lacework_julia/f0202_lacework_julia_module.dart';

void main() {
  test('F0202LaceworkJulia instantiates', () {
    final m = F0202LaceworkJulia();
    expect(m.id, 'f0202_lacework_julia');
    expect(m.shader, 'shaders/f0202_lacework_julia_gpu.frag');
  });

  test('F0202LaceworkJulia presets are well-formed', () {
    final m = F0202LaceworkJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0202LaceworkJulia metadata is consistent', () {
    final m = F0202LaceworkJulia();
    expect(m.metadata.id, m.id);
  });
}
