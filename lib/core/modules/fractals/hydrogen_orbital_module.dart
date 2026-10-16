import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/builders/uniform_layout.dart';
import 'package:flutter_fractals/core/modules/common_params.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/param_reader.dart';
import 'package:vector_math/vector_math_64.dart';

/// Stylized volume renderer for the viral prompt that combines a radial
/// hydrogen-like term with the Y_20 spherical harmonic.
///
/// The prompt's radial factor `(1 - r/2)e^(-r/2)` and `Y_{2,0}` angular term do
/// not form a single physical hydrogen eigenstate together; they are kept as-is
/// because the hybrid is the visual recipe the post used.
FractalModule buildHydrogenOrbitalModule() {
  final parameters = [
    FractalParameter(
      id: 'densityGain',
      label: (_) => 'Density Gain',
      type: FractalParamType.float,
      min: 0.25,
      max: 3.0,
      step: 0.05,
      defaultValue: 1.0,
    ),
    FractalParameter(
      id: 'noiseStrength',
      label: (_) => 'Outer Noise',
      type: FractalParamType.float,
      min: 0.0,
      max: 1.0,
      step: 0.01,
      defaultValue: 1.0,
    ),
    FractalParameter(
      id: 'radialScale',
      label: (_) => 'Orbital Scale',
      type: FractalParamType.float,
      min: 0.5,
      max: 1.8,
      step: 0.05,
      defaultValue: 1.0,
    ),
    CommonFractalParams.raySteps(
      defaultValue: 120,
      min: 32,
      max: 180,
      label: 'Volume Steps',
    ),
    FractalParameter(
      id: 'colorScheme',
      label: (l10n) => l10n.paramColorScheme,
      type: FractalParamType.enumeration,
      min: 0,
      max: 3,
      step: 1,
      defaultValue: 0,
      options: [
        FractalParamOption(value: 0, label: (_) => 'Hydrogen blue'),
        FractalParamOption(value: 1, label: (_) => 'Spectral'),
        FractalParamOption(value: 2, label: (_) => 'Violet'),
        FractalParamOption(value: 3, label: (_) => 'Density'),
      ],
    ),
  ];

  final defaultPreset = FractalPreset(
    id: 'hydrogen_orbital-default',
    moduleId: 'hydrogen_orbital',
    name: 'Default',
    params: const {
      'densityGain': 1.0,
      'noiseStrength': 1.0,
      'radialScale': 1.0,
      'steps': 120,
      'colorScheme': 0,
    },
    view: FractalViewState(
      pan: Vector2.zero(),
      zoom: 1.05,
      rotation: Vector3(0.55, -0.45, 0.08),
    ),
    createdAt: builtInPresetCreatedAt,
    isBuiltIn: true,
  );

  return FractalModule(
    id: 'hydrogen_orbital',
    displayName: (_) => 'Hydrogen Orbital',
    dimension: FractalDimension.threeD,
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/hydrogen_orbital_gpu.frag',
    parameters: parameters,
    defaultPreset: defaultPreset,
    builtInPresets: [
      defaultPreset.copyWith(
        id: 'hydrogen_orbital-quantum_jellyfish',
        name: 'Quantum Jellyfish',
      ),
      defaultPreset.copyWith(
        id: 'hydrogen_orbital-clean_y20',
        name: 'Clean Y20',
        params: {
          'densityGain': 1.15,
          'noiseStrength': 0.0,
          'radialScale': 0.95,
          'steps': 140,
          'colorScheme': 0,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.2,
          rotation: Vector3(0.2, -0.75, 0.0),
        ),
      ),
      defaultPreset.copyWith(
        id: 'hydrogen_orbital-white_core',
        name: 'White Core',
        params: {
          'densityGain': 1.85,
          'noiseStrength': 0.45,
          'radialScale': 1.05,
          'steps': 150,
          'colorScheme': 0,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.35,
          rotation: Vector3(0.75, -0.25, 0.15),
        ),
      ),
      defaultPreset.copyWith(
        id: 'hydrogen_orbital_violet_shell',
        name: 'Violet Shell',
        params: {
          'densityGain': 1.25,
          'noiseStrength': 0.8,
          'radialScale': 1.2,
          'steps': 130,
          'colorScheme': 2,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.0,
          rotation: Vector3(0.9, 0.35, -0.1),
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
      shader.setFloat(9, readDouble(state.params, 'densityGain', 1.0));
      shader.setFloat(10, readDouble(state.params, 'noiseStrength', 1.0));
      shader.setFloat(11, readDouble(state.params, 'radialScale', 1.0));
      shader.setFloat(12, readDouble(state.params, 'steps', 120));
      shader.setFloat(13, readDouble(state.params, 'colorScheme', 0));
      shader.setFloat(14, state.transparentBackground ? 1.0 : 0.0);
    },
  );
}
