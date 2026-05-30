// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0188_flower_julia/f0188_flower_julia_module.dart';

void main() {
  test('F0188FlowerJulia instantiates', () {
    final m = F0188FlowerJulia();
    expect(m.id, 'f0188_flower_julia');
    expect(m.shader, 'shaders/f0188_flower_julia_gpu.frag');
  });

  test('F0188FlowerJulia presets are well-formed', () {
    final m = F0188FlowerJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0188FlowerJulia metadata is consistent', () {
    final m = F0188FlowerJulia();
    expect(m.metadata.id, m.id);
  });
}
