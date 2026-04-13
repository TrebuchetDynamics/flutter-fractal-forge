// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0565_mandelbulb_n_12_presets.dart';
import 'f0565_mandelbulb_n_12_variants.dart';
import 'f0565_mandelbulb_n_12_metadata.dart';

/// Mandelbulb n=12 — 3D Raymarching & Hypercomplex.
class F0565MandelbulbN12 extends Raymarched3DModule {
  F0565MandelbulbN12()
      : super(
          id: 'f0565_mandelbulb_n_12',
          shader: 'shaders/f0565_mandelbulb_n_12_gpu.frag',
        );

  @override
  F0565MandelbulbN12Metadata get metadata => F0565MandelbulbN12Metadata.instance;

  @override
  List<F0565MandelbulbN12Preset> get presets => F0565MandelbulbN12Presets.all;

  @override
  List<F0565MandelbulbN12Variant> get variants => F0565MandelbulbN12Variants.all;

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
