// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0569_mandelbulb_n_24_presets.dart';
import 'f0569_mandelbulb_n_24_variants.dart';
import 'f0569_mandelbulb_n_24_metadata.dart';

/// Mandelbulb n=24 — 3D Raymarching & Hypercomplex.
class F0569MandelbulbN24 extends Raymarched3DModule {
  F0569MandelbulbN24()
      : super(
          id: 'f0569_mandelbulb_n_24',
          shader: 'shaders/f0569_mandelbulb_n_24_gpu.frag',
        );

  @override
  F0569MandelbulbN24Metadata get metadata => F0569MandelbulbN24Metadata.instance;

  @override
  List<F0569MandelbulbN24Preset> get presets => F0569MandelbulbN24Presets.all;

  @override
  List<F0569MandelbulbN24Variant> get variants => F0569MandelbulbN24Variants.all;

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
