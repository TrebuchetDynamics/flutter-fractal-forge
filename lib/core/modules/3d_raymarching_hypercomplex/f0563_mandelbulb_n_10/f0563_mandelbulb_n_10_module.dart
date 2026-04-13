// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0563_mandelbulb_n_10_presets.dart';
import 'f0563_mandelbulb_n_10_variants.dart';
import 'f0563_mandelbulb_n_10_metadata.dart';

/// Mandelbulb n=10 — 3D Raymarching & Hypercomplex.
class F0563MandelbulbN10 extends Raymarched3DModule {
  F0563MandelbulbN10()
      : super(
          id: 'f0563_mandelbulb_n_10',
          shader: 'shaders/f0563_mandelbulb_n_10_gpu.frag',
        );

  @override
  F0563MandelbulbN10Metadata get metadata => F0563MandelbulbN10Metadata.instance;

  @override
  List<F0563MandelbulbN10Preset> get presets => F0563MandelbulbN10Presets.all;

  @override
  List<F0563MandelbulbN10Variant> get variants => F0563MandelbulbN10Variants.all;

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
