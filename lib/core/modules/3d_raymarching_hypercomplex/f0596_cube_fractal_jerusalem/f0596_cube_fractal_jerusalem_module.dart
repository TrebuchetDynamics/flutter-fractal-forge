// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0596_cube_fractal_jerusalem_presets.dart';
import 'f0596_cube_fractal_jerusalem_variants.dart';
import 'f0596_cube_fractal_jerusalem_metadata.dart';

/// Cube Fractal (Jerusalem) — 3D Raymarching & Hypercomplex.
class F0596CubeFractalJerusalem extends Raymarched3DModule {
  F0596CubeFractalJerusalem()
      : super(
          id: 'f0596_cube_fractal_jerusalem',
          shader: 'shaders/f0596_cube_fractal_jerusalem_gpu.frag',
        );

  @override
  F0596CubeFractalJerusalemMetadata get metadata => F0596CubeFractalJerusalemMetadata.instance;

  @override
  List<F0596CubeFractalJerusalemPreset> get presets => F0596CubeFractalJerusalemPresets.all;

  @override
  List<F0596CubeFractalJerusalemVariant> get variants => F0596CubeFractalJerusalemVariants.all;

  @override
  double get defaultPower => 8.0;

  @override
  int get defaultSteps => 200;

  @override
  int get defaultIterations => 20;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setInt('steps', defaultSteps);
    p.setInt('iterations', defaultIterations);
  }
}
