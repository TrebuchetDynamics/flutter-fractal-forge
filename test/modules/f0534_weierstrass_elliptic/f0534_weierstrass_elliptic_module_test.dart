// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0534_weierstrass_elliptic/f0534_weierstrass_elliptic_module.dart';

void main() {
  test('F0534WeierstrassElliptic instantiates', () {
    final m = F0534WeierstrassElliptic();
    expect(m.id, 'f0534_weierstrass_elliptic');
    expect(m.shader, 'shaders/f0534_weierstrass_elliptic_gpu.frag');
  });

  test('F0534WeierstrassElliptic presets are well-formed', () {
    final m = F0534WeierstrassElliptic();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0534WeierstrassElliptic metadata is consistent', () {
    final m = F0534WeierstrassElliptic();
    expect(m.metadata.id, m.id);
  });
}
