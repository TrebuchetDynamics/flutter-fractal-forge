// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0568_mandelbulb_n_20_presets.dart';
import 'f0568_mandelbulb_n_20_variants.dart';
import 'f0568_mandelbulb_n_20_metadata.dart';

/// Mandelbulb n=20 — 3D Raymarching & Hypercomplex.
class F0568MandelbulbN20 extends Raymarched3DModule {
  F0568MandelbulbN20()
      : super(
          id: 'f0568_mandelbulb_n_20',
          shader: 'shaders/f0568_mandelbulb_n_20_gpu.frag',
        );

  @override
  F0568MandelbulbN20Metadata get metadata => F0568MandelbulbN20Metadata.instance;

  @override
  List<F0568MandelbulbN20Preset> get presets => F0568MandelbulbN20Presets.all;

  @override
  List<F0568MandelbulbN20Variant> get variants => F0568MandelbulbN20Variants.all;

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
