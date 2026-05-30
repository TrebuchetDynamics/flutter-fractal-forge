// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0163_filigree_julia/f0163_filigree_julia_module.dart';

void main() {
  test('F0163FiligreeJulia instantiates', () {
    final m = F0163FiligreeJulia();
    expect(m.id, 'f0163_filigree_julia');
    expect(m.shader, 'shaders/f0163_filigree_julia_gpu.frag');
  });

  test('F0163FiligreeJulia presets are well-formed', () {
    final m = F0163FiligreeJulia();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0163FiligreeJulia metadata is consistent', () {
    final m = F0163FiligreeJulia();
    expect(m.metadata.id, m.id);
  });
}
