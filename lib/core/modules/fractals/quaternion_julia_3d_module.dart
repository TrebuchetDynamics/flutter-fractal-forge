import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/builders/uniform_layout.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math_64.dart';

FractalModule buildQuaternionJulia3DModule() {
  const defaultParams = <String, Object>{
    'power': 2.0,
    'iterations': 14,
    'steps': 120,
    'bailout': 4.0,
    'colorScheme': 0,
    'variant': 0,
    'c0': -0.2,
    'c1': 0.8,
    'c2': 0.0,
    'c3': 0.0,
  };
  final defaultView = FractalViewState(
    pan: Vector2.zero(),
    zoom: 1.0,
    rotation: Vector3(0.3, -0.4, 0.0),
  );
  final defaultPreset = catalogPreset(
    id: 'quaternion_julia_3d-default',
    moduleId: 'quaternion_julia_3d',
    name: 'Classic',
    params: defaultParams,
    view: defaultView,
  );

  return FractalModule(
    id: 'quaternion_julia_3d',
    displayName: (_) => 'Quaternion Julia 3D',
    dimension: FractalDimension.threeD,
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/quaternion_julia_3d_gpu.frag',
    parameters: [
      FractalParameter(
        id: 'power',
        label: (_) => 'Preset Scale',
        type: FractalParamType.float,
        min: 0.2,
        max: 4.0,
        step: 0.1,
        defaultValue: 2.0,
      ),
      CommonFractalParams.iterations(defaultValue: 14, min: 4, max: 20),
      CommonFractalParams.raySteps(defaultValue: 120),
      CommonFractalParams.bailout(defaultValue: 4.0, min: 1.0, max: 8.0),
      CommonFractalParams.colorScheme4(defaultValue: 0),
      FractalParameter(
        id: 'variant',
        label: (_) => 'Constant',
        type: FractalParamType.enumeration,
        min: -1,
        max: 3,
        step: 1,
        defaultValue: 0,
        options: [
          FractalParamOption(value: -1, label: (_) => 'Custom'),
          FractalParamOption(value: 0, label: (_) => 'Classic'),
          FractalParamOption(value: 1, label: (_) => 'Organic'),
          FractalParamOption(value: 2, label: (_) => 'Crystalline'),
          FractalParamOption(value: 3, label: (_) => 'Spiral'),
        ],
      ),
      CommonFractalParams.constantCoordinate(
        id: 'c0',
        label: 'C0',
        defaultValue: -0.2,
        min: -0.95,
        max: 0.95,
      ),
      CommonFractalParams.constantCoordinate(
        id: 'c1',
        label: 'C1',
        defaultValue: 0.8,
        min: -0.95,
        max: 0.95,
      ),
      CommonFractalParams.constantCoordinate(
        id: 'c2',
        label: 'C2',
        defaultValue: 0.0,
        min: -0.95,
        max: 0.95,
      ),
      CommonFractalParams.constantCoordinate(
        id: 'c3',
        label: 'C3',
        defaultValue: 0.0,
        min: -0.95,
        max: 0.95,
      ),
    ],
    defaultPreset: defaultPreset,
    builtInPresets: [
      defaultPreset,
      _preset(
        id: 'quaternion_julia_3d-norton',
        name: 'Norton',
        c: const [-0.2, 0.8, 0.0, 0.0],
        view: defaultView,
      ),
      _preset(
        id: 'quaternion_julia_3d-crystal',
        name: 'Crystal',
        c: const [0.291, 0.399, 0.339, 0.437],
        view: defaultView,
      ),
      _preset(
        id: 'quaternion_julia_3d-axis',
        name: 'Axis',
        c: const [0.08, 0.0, 0.8, 0.0],
        view: defaultView,
      ),
    ],
    setUniforms: (shader, state, size, time) {
      setRaymarched3DFrameUniforms(
        setFloat: shader.setFloat,
        time: time,
        width: size.width,
        height: size.height,
        view: state.view,
      );
      setRaymarched3DParameterUniforms(
        setFloat: shader.setFloat,
        power: readDouble(state.params, 'power', 2.0),
        iterations: readDouble(state.params, 'iterations', 14),
        steps: readDouble(state.params, 'steps', 120),
        bailout: readDouble(state.params, 'bailout', 4.0),
        colorScheme: readDouble(state.params, 'colorScheme', 0),
        fractalType: readDouble(state.params, 'variant', 0),
        transparentBackground: state.transparentBackground,
      );
      shader.setFloat(16, _safeC(readDouble(state.params, 'c0', -0.2)));
      shader.setFloat(17, _safeC(readDouble(state.params, 'c1', 0.8)));
      shader.setFloat(18, _safeC(readDouble(state.params, 'c2', 0.0)));
      shader.setFloat(19, _safeC(readDouble(state.params, 'c3', 0.0)));
    },
  );
}

double _safeC(double value) => value.clamp(-0.95, 0.95).toDouble();

FractalPreset _preset({
  required String id,
  required String name,
  required List<double> c,
  required FractalViewState view,
}) =>
    catalogPreset(
      id: id,
      moduleId: 'quaternion_julia_3d',
      name: name,
      params: {
        'power': 2.0,
        'iterations': 14,
        'steps': 120,
        'bailout': 4.0,
        'colorScheme': 0,
        'variant': -1,
        'c0': c[0],
        'c1': c[1],
        'c2': c[2],
        'c3': c[3],
      },
      view: view,
    );
