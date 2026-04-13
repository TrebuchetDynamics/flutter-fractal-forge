// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0516_exp_i_z_c_presets.dart';
import 'f0516_exp_i_z_c_variants.dart';
import 'f0516_exp_i_z_c_metadata.dart';

/// exp(i·z) + c — Escape-Time (Complex Plane).
class F0516ExpIZC extends EscapeTimeModule {
  F0516ExpIZC()
      : super(
          id: 'f0516_exp_i_z_c',
          shader: 'shaders/f0516_exp_i_z_c_gpu.frag',
        );

  @override
  F0516ExpIZCMetadata get metadata => F0516ExpIZCMetadata.instance;

  @override
  List<F0516ExpIZCPreset> get presets => F0516ExpIZCPresets.all;

  @override
  List<F0516ExpIZCVariant> get variants => F0516ExpIZCVariants.all;

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
