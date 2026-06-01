// GENERATED smoke test.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_fractals/core/modules/3d_raymarching_hypercomplex/f0560_mandelbulb_n_7/f0560_mandelbulb_n_7_module.dart';
import 'package:flutter_fractals/core/modules/base_classes/shader_params.dart';

void main() {
  test('F0560MandelbulbN7 instantiates', () {
    final m = F0560MandelbulbN7();
    expect(m.id, 'f0560_mandelbulb_n_7');
    expect(m.shader, 'shaders/f0560_mandelbulb_n_7_gpu.frag');
  });

  test('F0560MandelbulbN7 presets are well-formed', () {
    final m = F0560MandelbulbN7();
    expect(m.presets, isNotEmpty);
    for (final p in m.presets) {
      expect(p.id, isNotEmpty);
      expect(p.name, isNotEmpty);
    }
  });

  test('F0560MandelbulbN7 metadata is consistent', () {
    final m = F0560MandelbulbN7();
    expect(m.metadata.id, m.id);
  });

  test('F0560MandelbulbN7 configures raymarch shader defaults', () {
    final m = F0560MandelbulbN7();
    final params = _RecordingShaderParams();

    m.configureShader(params);

    expect(params.floats, {'power': 8.0});
    expect(params.ints, {'steps': 200, 'iterations': 20});
  });
}

class _RecordingShaderParams implements ShaderParams {
  final Map<String, double> floats = {};
  final Map<String, int> ints = {};
  final Map<String, bool> bools = {};
  final Map<String, List<double>> vec2s = {};
  final Map<String, List<double>> vec3s = {};

  @override
  void setBool(String name, bool value) {
    bools[name] = value;
  }

  @override
  void setFloat(String name, double value) {
    floats[name] = value;
  }

  @override
  void setInt(String name, int value) {
    ints[name] = value;
  }

  @override
  void setVec2(String name, double x, double y) {
    vec2s[name] = [x, y];
  }

  @override
  void setVec3(String name, double x, double y, double z) {
    vec3s[name] = [x, y, z];
  }
}
