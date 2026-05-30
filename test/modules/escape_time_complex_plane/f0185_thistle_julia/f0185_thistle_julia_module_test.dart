// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0185_thistle_julia/f0185_thistle_julia_module.dart';

void main() {
  test('F0185ThistleJulia instantiates', () {
    final m = F0185ThistleJulia();
    expect(m.id, 'f0185_thistle_julia');
    expect(m.shader, 'shaders/f0185_thistle_julia_gpu.frag');
  });

  test('F0185ThistleJulia presets are well-formed', () {
    final m = F0185ThistleJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0185ThistleJulia metadata is consistent', () {
    final m = F0185ThistleJulia();
    expect(m.metadata.id, m.id);
  });
}
