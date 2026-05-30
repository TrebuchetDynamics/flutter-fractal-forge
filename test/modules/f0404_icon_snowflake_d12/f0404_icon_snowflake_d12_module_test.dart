// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/strange_attractors/f0404_icon_snowflake_d12/f0404_icon_snowflake_d12_module.dart';

void main() {
  test('F0404IconSnowflakeD12 instantiates', () {
    final m = F0404IconSnowflakeD12();
    expect(m.id, 'f0404_icon_snowflake_d12');
    expect(m.shader, 'shaders/f0404_icon_snowflake_d12_gpu.frag');
  });

  test('F0404IconSnowflakeD12 presets are well-formed', () {
    final m = F0404IconSnowflakeD12();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0404IconSnowflakeD12 metadata is consistent', () {
    final m = F0404IconSnowflakeD12();
    expect(m.metadata.id, m.id);
  });
}
