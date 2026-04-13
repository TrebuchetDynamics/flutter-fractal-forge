// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0561_mandelbulb_n_8_presets.dart';
import 'f0561_mandelbulb_n_8_variants.dart';
import 'f0561_mandelbulb_n_8_metadata.dart';

/// Mandelbulb n=8 — 3D Raymarching & Hypercomplex.
class F0561MandelbulbN8 extends Raymarched3DModule {
  F0561MandelbulbN8()
      : super(
          id: 'f0561_mandelbulb_n_8',
          shader: 'shaders/f0561_mandelbulb_n_8_gpu.frag',
        );

  @override
  F0561MandelbulbN8Metadata get metadata => F0561MandelbulbN8Metadata.instance;

  @override
  List<F0561MandelbulbN8Preset> get presets => F0561MandelbulbN8Presets.all;

  @override
  List<F0561MandelbulbN8Variant> get variants => F0561MandelbulbN8Variants.all;

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
