import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:vector_math/vector_math.dart';

/// Diagnostic module: proves FragmentProgram renders on GPU with minimal uniforms.
///
/// Shader: shaders/diagnostic/diag_min.frag
/// Uniforms: uSize (vec2) only.
FractalModule buildGpuGradientModule() {
  final defaultPreset = FractalPreset(
    id: 'gpu-gradient-default',
    moduleId: 'gpu_gradient',
    name: 'Default',
    params: const {},
    view: FractalViewState(
      pan: Vector2.zero(),
      zoom: 1.0,
      rotation: Vector3.zero(),
    ),
    createdAt: DateTime.now(),
    isBuiltIn: true,
  );

  return FractalModule(
    id: 'gpu_gradient',
    displayName: (l10n) => 'GPU Gradient (Diag)',
    dimension: FractalDimension.twoD,
    shaderAsset: 'shaders/diagnostic/diag_min.frag',
    parameters: const <FractalParameter>[],
    defaultPreset: defaultPreset,
    builtInPresets: [defaultPreset],
    setUniforms: (shader, state, size, time) {
      // diag_min.frag expects uSize vec2 as float indices 0-1.
      shader.setFloat(0, size.width);
      shader.setFloat(1, size.height);
    },
  );
}
