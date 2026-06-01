import 'package:flutter_fractals/core/modules/base_classes/attractor_module_base.dart';
import 'package:flutter_fractals/core/modules/base_classes/cellular_module_base.dart';
import 'package:flutter_fractals/core/modules/base_classes/escape_time_module_base.dart';
import 'package:flutter_fractals/core/modules/base_classes/ifs_module_base.dart';
import 'package:flutter_fractals/core/modules/base_classes/l_system_module_base.dart';
import 'package:flutter_fractals/core/modules/base_classes/raymarch_3d_module_base.dart';
import 'package:flutter_fractals/core/modules/base_classes/shader_params.dart';

void main() {
  _expectEqual(_Attractor().defaultIterations, 100000);
  _expectEqual(_Attractor().defaultStepSize, 0.01);

  _expectEqual(_Cellular().defaultGenerations, 100);

  final escapeTime = _EscapeTime();
  _expectEqual(escapeTime.defaultPower, 2.0);
  _expectEqual(escapeTime.defaultBailout, 2.0);
  _expectEqual(escapeTime.defaultIterations, 500);
  _expectEqual(escapeTime.deepZoom, DeepZoomStrategy.none);

  _expectEqual(_IFS().defaultIterations, 50000);
  _expectEqual(_LSystem().defaultDepth, 6);

  final raymarched3D = _Raymarched3D();
  _expectEqual(raymarched3D.defaultPower, 8.0);
  _expectEqual(raymarched3D.defaultSteps, 120);
  _expectEqual(raymarched3D.defaultIterations, 10);

  final params = _RecordingShaderParams();
  params
    ..setFloat('power', 2.5)
    ..setInt('iterations', 80)
    ..setBool('enabled', true)
    ..setVec2('center', -0.5, 0.25)
    ..setVec3('camera', 1, 2, 3);

  _expectEqual(params.calls, <String>[
    'float:power=2.5',
    'int:iterations=80',
    'bool:enabled=true',
    'vec2:center=-0.5,0.25',
    'vec3:camera=1.0,2.0,3.0',
  ]);
}

void _expectEqual(Object? actual, Object? expected) {
  final matches = actual is List && expected is List
      ? actual.length == expected.length &&
          Iterable.generate(actual.length).every((i) => actual[i] == expected[i])
      : actual == expected;
  if (!matches) {
    throw StateError('Expected <$expected>, got <$actual>.');
  }
}

class _Attractor extends AttractorModule {
  const _Attractor() : super(id: 'attractor', shader: 'shader.frag');

  @override
  Object get metadata => const {};

  @override
  List<Object> get presets => const [];

  @override
  List<Object> get variants => const [];

  @override
  void configureShader(ShaderParams p) {}
}

class _Cellular extends CellularModule {
  const _Cellular() : super(id: 'cellular', shader: 'shader.frag');

  @override
  Object get metadata => const {};

  @override
  List<Object> get presets => const [];

  @override
  List<Object> get variants => const [];

  @override
  void configureShader(ShaderParams p) {}
}

class _EscapeTime extends EscapeTimeModule {
  const _EscapeTime() : super(id: 'escape-time', shader: 'shader.frag');

  @override
  Object get metadata => const {};

  @override
  List<Object> get presets => const [];

  @override
  List<Object> get variants => const [];

  @override
  void configureShader(ShaderParams p) {}
}

class _IFS extends IFSModule {
  const _IFS() : super(id: 'ifs', shader: 'shader.frag');

  @override
  Object get metadata => const {};

  @override
  List<Object> get presets => const [];

  @override
  List<Object> get variants => const [];

  @override
  void configureShader(ShaderParams p) {}
}

class _LSystem extends LSystemModule {
  const _LSystem() : super(id: 'l-system', shader: 'shader.frag');

  @override
  Object get metadata => const {};

  @override
  List<Object> get presets => const [];

  @override
  List<Object> get variants => const [];

  @override
  void configureShader(ShaderParams p) {}
}

class _Raymarched3D extends Raymarched3DModule {
  const _Raymarched3D() : super(id: 'raymarched-3d', shader: 'shader.frag');

  @override
  Object get metadata => const {};

  @override
  List<Object> get presets => const [];

  @override
  List<Object> get variants => const [];

  @override
  void configureShader(ShaderParams p) {}
}

class _RecordingShaderParams implements ShaderParams {
  final List<String> calls = [];

  @override
  void setBool(String name, bool value) => calls.add('bool:$name=$value');

  @override
  void setFloat(String name, double value) => calls.add('float:$name=$value');

  @override
  void setInt(String name, int value) => calls.add('int:$name=$value');

  @override
  void setVec2(String name, double x, double y) => calls.add('vec2:$name=$x,$y');

  @override
  void setVec3(String name, double x, double y, double z) =>
      calls.add('vec3:$name=$x,$y,$z');
}
