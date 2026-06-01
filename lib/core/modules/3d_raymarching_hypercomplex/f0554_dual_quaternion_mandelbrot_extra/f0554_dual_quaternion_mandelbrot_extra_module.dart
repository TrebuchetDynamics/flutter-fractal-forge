// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/raymarch_3d_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'metadata/metadata.dart';
import 'presets/presets.dart';
import 'variants/variants.dart';

/// Dual Quaternion Mandelbrot (extra) — 3D Raymarching & Hypercomplex.
class F0554DualQuaternionMandelbrotExtra extends Raymarched3DModule {
  F0554DualQuaternionMandelbrotExtra()
      : super(
          id: 'f0554_dual_quaternion_mandelbrot_extra',
          shader: 'shaders/f0554_dual_quaternion_mandelbrot_extra_gpu.frag',
        );

  @override
  F0554DualQuaternionMandelbrotExtraMetadata get metadata => F0554DualQuaternionMandelbrotExtraMetadata.instance;

  @override
  List<F0554DualQuaternionMandelbrotExtraPreset> get presets => F0554DualQuaternionMandelbrotExtraPresets.all;

  @override
  List<F0554DualQuaternionMandelbrotExtraVariant> get variants => F0554DualQuaternionMandelbrotExtraVariants.all;

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
