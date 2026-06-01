// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'metadata/f0556_mandelbulb_n_3_metadata.dart';
import 'presets/f0556_mandelbulb_n_3_presets.dart';
import 'variants/f0556_mandelbulb_n_3_variants.dart';

/// Mandelbulb n=3 — 3D Raymarching & Hypercomplex.
class F0556MandelbulbN3 extends Raymarched3DModule {
  F0556MandelbulbN3()
      : super(
          id: 'f0556_mandelbulb_n_3',
          shader: 'shaders/f0556_mandelbulb_n_3_gpu.frag',
        );

  @override
  F0556MandelbulbN3Metadata get metadata => F0556MandelbulbN3Metadata.instance;

  @override
  List<F0556MandelbulbN3Preset> get presets => F0556MandelbulbN3Presets.all;

  @override
  List<F0556MandelbulbN3Variant> get variants => F0556MandelbulbN3Variants.all;

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
