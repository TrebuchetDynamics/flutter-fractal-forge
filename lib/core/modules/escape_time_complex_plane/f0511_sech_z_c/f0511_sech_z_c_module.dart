// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0511_sech_z_c_presets.dart';
import 'f0511_sech_z_c_variants.dart';
import 'f0511_sech_z_c_metadata.dart';

/// sech(z) + c — Escape-Time (Complex Plane).
class F0511SechZC extends EscapeTimeModule {
  F0511SechZC()
      : super(
          id: 'f0511_sech_z_c',
          shader: 'shaders/f0511_sech_z_c_gpu.frag',
        );

  @override
  F0511SechZCMetadata get metadata => F0511SechZCMetadata.instance;

  @override
  List<F0511SechZCPreset> get presets => F0511SechZCPresets.all;

  @override
  List<F0511SechZCVariant> get variants => F0511SechZCVariants.all;

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
