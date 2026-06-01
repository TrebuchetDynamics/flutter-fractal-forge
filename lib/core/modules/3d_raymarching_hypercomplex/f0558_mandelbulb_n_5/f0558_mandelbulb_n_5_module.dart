// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'metadata/f0558_mandelbulb_n_5_metadata.dart';
import 'presets/f0558_mandelbulb_n_5_presets.dart';
import 'variants/f0558_mandelbulb_n_5_variants.dart';

/// Mandelbulb n=5 — 3D Raymarching & Hypercomplex.
class F0558MandelbulbN5 extends Raymarched3DModule {
  F0558MandelbulbN5()
      : super(
          id: 'f0558_mandelbulb_n_5',
          shader: 'shaders/f0558_mandelbulb_n_5_gpu.frag',
        );

  @override
  F0558MandelbulbN5Metadata get metadata => F0558MandelbulbN5Metadata.instance;

  @override
  List<F0558MandelbulbN5Preset> get presets => F0558MandelbulbN5Presets.all;

  @override
  List<F0558MandelbulbN5Variant> get variants => F0558MandelbulbN5Variants.all;

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
