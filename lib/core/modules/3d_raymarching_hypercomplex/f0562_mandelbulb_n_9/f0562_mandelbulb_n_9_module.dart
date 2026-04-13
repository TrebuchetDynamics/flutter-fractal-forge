// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0562_mandelbulb_n_9_presets.dart';
import 'f0562_mandelbulb_n_9_variants.dart';
import 'f0562_mandelbulb_n_9_metadata.dart';

/// Mandelbulb n=9 — 3D Raymarching & Hypercomplex.
class F0562MandelbulbN9 extends Raymarched3DModule {
  F0562MandelbulbN9()
      : super(
          id: 'f0562_mandelbulb_n_9',
          shader: 'shaders/f0562_mandelbulb_n_9_gpu.frag',
        );

  @override
  F0562MandelbulbN9Metadata get metadata => F0562MandelbulbN9Metadata.instance;

  @override
  List<F0562MandelbulbN9Preset> get presets => F0562MandelbulbN9Presets.all;

  @override
  List<F0562MandelbulbN9Variant> get variants => F0562MandelbulbN9Variants.all;

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
