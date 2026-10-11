import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/builders/uniform_layout.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math_64.dart';

/// Julia set of the White-Nylander polar power map in three dimensions.
FractalModule buildJuliabulb3DModule() {
  const defaultParams = <String, Object>{
    'power': 8.0,
    'iterations': 12,
    'steps': 120,
    'bailout': 4.0,
    'colorScheme': 0,
    'cx': -0.2,
    'cy': 0.7,
    'cz': 0.0,
  };
  final defaultView = FractalViewState(
    pan: Vector2.zero(),
    zoom: 1.15,
    rotation: Vector3(0.35, -0.45, 0.0),
  );
  final defaultPreset = catalogPreset(
    id: 'juliabulb_3d-default',
    moduleId: 'juliabulb_3d',
    name: 'Classic',
    params: defaultParams,
    view: defaultView,
  );

  return FractalModule(
    id: 'juliabulb_3d',
    displayName: (_) => 'Juliabulb 3D',
    dimension: FractalDimension.threeD,
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/juliabulb_3d_gpu.frag',
    parameters: [
      FractalParameter(
        id: 'power',
        label: (l10n) => l10n.paramPower,
        type: FractalParamType.float,
        min: 2.0,
        max: 12.0,
        step: 0.1,
        defaultValue: 8.0,
      ),
      CommonFractalParams.iterations(defaultValue: 12, min: 4, max: 20),
      CommonFractalParams.raySteps(
        defaultValue: 120,
        min: 30,
        max: 180,
      ),
      CommonFractalParams.bailout(defaultValue: 4.0, min: 2.0, max: 8.0),
      CommonFractalParams.colorScheme4(defaultValue: 0),
      CommonFractalParams.constantCoordinate(
        id: 'cx',
        label: 'C X',
        defaultValue: -0.2,
      ),
      CommonFractalParams.constantCoordinate(
        id: 'cy',
        label: 'C Y',
        defaultValue: 0.7,
      ),
      CommonFractalParams.constantCoordinate(
        id: 'cz',
        label: 'C Z',
        defaultValue: 0.0,
      ),
    ],
    defaultPreset: defaultPreset,
    builtInPresets: [
      defaultPreset,
      defaultPreset.copyWith(
        id: 'juliabulb_3d-branching',
        name: 'Branching',
        params: {
          ...defaultParams,
          'power': 6.0,
          'cx': 0.28,
          'cy': 0.18,
          'cz': 0.12
        },
        view: defaultView.copyWith(
          rotation: Vector3(0.55, 0.3, 0.1),
          zoom: 1.25,
        ),
      ),
      defaultPreset.copyWith(
        id: 'juliabulb_3d-symmetric',
        name: 'Symmetric',
        params: {...defaultParams, 'cx': 0.0, 'cy': 0.55, 'cz': 0.0},
        view: defaultView.copyWith(
          rotation: Vector3(0.4, 0.55, 0.0),
          zoom: 1.3,
        ),
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
        power: readDouble(state.params, 'power', 8.0),
        iterations: readDouble(state.params, 'iterations', 12),
        steps: readDouble(state.params, 'steps', 120),
        bailout: readDouble(state.params, 'bailout', 4.0),
        colorScheme: readDouble(state.params, 'colorScheme', 0),
        fractalType: 0.0,
        transparentBackground: state.transparentBackground,
      );
      shader.setFloat(16, _safeConstant(readDouble(state.params, 'cx', -0.2)));
      shader.setFloat(17, _safeConstant(readDouble(state.params, 'cy', 0.7)));
      shader.setFloat(18, _safeConstant(readDouble(state.params, 'cz', 0.0)));
    },
  );
}

double _safeConstant(double value) => value.clamp(-1.0, 1.0).toDouble();
