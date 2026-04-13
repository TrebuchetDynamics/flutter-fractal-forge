// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0508_log_cos_z_c_presets.dart';
import 'f0508_log_cos_z_c_variants.dart';
import 'f0508_log_cos_z_c_metadata.dart';

/// log(cos(z)) + c — Escape-Time (Complex Plane).
class F0508LogCosZC extends EscapeTimeModule {
  F0508LogCosZC()
      : super(
          id: 'f0508_log_cos_z_c',
          shader: 'shaders/f0508_log_cos_z_c_gpu.frag',
        );

  @override
  F0508LogCosZCMetadata get metadata => F0508LogCosZCMetadata.instance;

  @override
  List<F0508LogCosZCPreset> get presets => F0508LogCosZCPresets.all;

  @override
  List<F0508LogCosZCVariant> get variants => F0508LogCosZCVariants.all;

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
