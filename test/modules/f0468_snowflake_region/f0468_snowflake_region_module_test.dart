// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractal_forge/core/modules/escape_time_complex_plane/f0468_snowflake_region/f0468_snowflake_region_module.dart';

void main() {
  test('F0468SnowflakeRegion instantiates', () {
    final m = F0468SnowflakeRegion();
    expect(m.id, 'f0468_snowflake_region');
    expect(m.shader, 'shaders/f0468_snowflake_region_gpu.frag');
  });

  test('F0468SnowflakeRegion presets are well-formed', () {
    final m = F0468SnowflakeRegion();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0468SnowflakeRegion metadata is consistent', () {
    final m = F0468SnowflakeRegion();
    expect(m.metadata.id, m.id);
  });
}
