// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0503_exp_1_z_c_presets.dart';
import 'f0503_exp_1_z_c_variants.dart';
import 'f0503_exp_1_z_c_metadata.dart';

/// exp(1/z) + c — Escape-Time (Complex Plane).
class F0503Exp1ZC extends EscapeTimeModule {
  F0503Exp1ZC()
      : super(
          id: 'f0503_exp_1_z_c',
          shader: 'shaders/f0503_exp_1_z_c_gpu.frag',
        );

  @override
  F0503Exp1ZCMetadata get metadata => F0503Exp1ZCMetadata.instance;

  @override
  List<F0503Exp1ZCPreset> get presets => F0503Exp1ZCPresets.all;

  @override
  List<F0503Exp1ZCVariant> get variants => F0503Exp1ZCVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 50.0;

  @override
  int get defaultIterations => 300;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
