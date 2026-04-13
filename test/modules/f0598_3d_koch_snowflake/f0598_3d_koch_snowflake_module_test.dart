// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/3d_raymarching_hypercomplex/f0598_3d_koch_snowflake/f0598_3d_koch_snowflake_module.dart';

void main() {
  test('F05983dKochSnowflake instantiates', () {
    final m = F05983dKochSnowflake();
    expect(m.id, 'f0598_3d_koch_snowflake');
    expect(m.shader, 'shaders/f0598_3d_koch_snowflake_gpu.frag');
  });

  test('F05983dKochSnowflake presets are well-formed', () {
    final m = F05983dKochSnowflake();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F05983dKochSnowflake metadata is consistent', () {
    final m = F05983dKochSnowflake();
    expect(m.metadata.id, m.id);
  });
}
