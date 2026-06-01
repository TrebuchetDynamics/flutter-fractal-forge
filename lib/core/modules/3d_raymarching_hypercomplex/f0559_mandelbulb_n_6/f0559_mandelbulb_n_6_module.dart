// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'metadata/f0559_mandelbulb_n_6_metadata.dart';
import 'presets/f0559_mandelbulb_n_6_presets.dart';
import 'variants/f0559_mandelbulb_n_6_variants.dart';

/// Mandelbulb n=6 — 3D Raymarching & Hypercomplex.
class F0559MandelbulbN6 extends Raymarched3DModule {
  F0559MandelbulbN6()
      : super(
          id: 'f0559_mandelbulb_n_6',
          shader: 'shaders/f0559_mandelbulb_n_6_gpu.frag',
        );

  @override
  F0559MandelbulbN6Metadata get metadata => F0559MandelbulbN6Metadata.instance;

  @override
  List<F0559MandelbulbN6Preset> get presets => F0559MandelbulbN6Presets.all;

  @override
  List<F0559MandelbulbN6Variant> get variants => F0559MandelbulbN6Variants.all;

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
