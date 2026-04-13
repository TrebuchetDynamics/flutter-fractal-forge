// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0564_mandelbulb_n_11_presets.dart';
import 'f0564_mandelbulb_n_11_variants.dart';
import 'f0564_mandelbulb_n_11_metadata.dart';

/// Mandelbulb n=11 — 3D Raymarching & Hypercomplex.
class F0564MandelbulbN11 extends Raymarched3DModule {
  F0564MandelbulbN11()
      : super(
          id: 'f0564_mandelbulb_n_11',
          shader: 'shaders/f0564_mandelbulb_n_11_gpu.frag',
        );

  @override
  F0564MandelbulbN11Metadata get metadata => F0564MandelbulbN11Metadata.instance;

  @override
  List<F0564MandelbulbN11Preset> get presets => F0564MandelbulbN11Presets.all;

  @override
  List<F0564MandelbulbN11Variant> get variants => F0564MandelbulbN11Variants.all;

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
