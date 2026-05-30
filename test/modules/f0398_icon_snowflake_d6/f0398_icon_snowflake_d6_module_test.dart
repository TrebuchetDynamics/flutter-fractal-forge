// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0398_icon_snowflake_d6/f0398_icon_snowflake_d6_module.dart';

void main() {
  test('F0398IconSnowflakeD6 instantiates', () {
    final m = F0398IconSnowflakeD6();
    expect(m.id, 'f0398_icon_snowflake_d6');
    expect(m.shader, 'shaders/f0398_icon_snowflake_d6_gpu.frag');
  });

  test('F0398IconSnowflakeD6 presets are well-formed', () {
    final m = F0398IconSnowflakeD6();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0398IconSnowflakeD6 metadata is consistent', () {
    final m = F0398IconSnowflakeD6();
    expect(m.metadata.id, m.id);
  });
}
