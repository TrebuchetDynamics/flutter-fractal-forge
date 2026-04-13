// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/l_systems_space_filling/f0256_moore_like_hilbert/f0256_moore_like_hilbert_module.dart';

void main() {
  test('F0256MooreLikeHilbert instantiates', () {
    final m = F0256MooreLikeHilbert();
    expect(m.id, 'f0256_moore_like_hilbert');
    expect(m.shader, 'shaders/f0256_moore_like_hilbert_gpu.frag');
  });

  test('F0256MooreLikeHilbert presets are well-formed', () {
    final m = F0256MooreLikeHilbert();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0256MooreLikeHilbert metadata is consistent', () {
    final m = F0256MooreLikeHilbert();
    expect(m.metadata.id, m.id);
  });
}
