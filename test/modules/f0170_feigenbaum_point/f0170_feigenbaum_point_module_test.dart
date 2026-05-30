// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/escape_time_complex_plane/f0170_feigenbaum_point/f0170_feigenbaum_point_module.dart';

void main() {
  test('F0170FeigenbaumPoint instantiates', () {
    final m = F0170FeigenbaumPoint();
    expect(m.id, 'f0170_feigenbaum_point');
    expect(m.shader, 'shaders/f0170_feigenbaum_point_gpu.frag');
  });

  test('F0170FeigenbaumPoint presets are well-formed', () {
    final m = F0170FeigenbaumPoint();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0170FeigenbaumPoint metadata is consistent', () {
    final m = F0170FeigenbaumPoint();
    expect(m.metadata.id, m.id);
  });
}
