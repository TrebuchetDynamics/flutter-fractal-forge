// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0450_feigenbaum_point/f0450_feigenbaum_point_module.dart';

void main() {
  test('F0450FeigenbaumPoint instantiates', () {
    final m = F0450FeigenbaumPoint();
    expect(m.id, 'f0450_feigenbaum_point');
    expect(m.shader, 'shaders/f0450_feigenbaum_point_gpu.frag');
  });

  test('F0450FeigenbaumPoint presets are well-formed', () {
    final m = F0450FeigenbaumPoint();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0450FeigenbaumPoint metadata is consistent', () {
    final m = F0450FeigenbaumPoint();
    expect(m.metadata.id, m.id);
  });
}
