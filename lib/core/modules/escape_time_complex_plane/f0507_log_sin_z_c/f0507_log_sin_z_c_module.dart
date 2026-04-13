// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0507_log_sin_z_c_presets.dart';
import 'f0507_log_sin_z_c_variants.dart';
import 'f0507_log_sin_z_c_metadata.dart';

/// log(sin(z)) + c — Escape-Time (Complex Plane).
class F0507LogSinZC extends EscapeTimeModule {
  F0507LogSinZC()
      : super(
          id: 'f0507_log_sin_z_c',
          shader: 'shaders/f0507_log_sin_z_c_gpu.frag',
        );

  @override
  F0507LogSinZCMetadata get metadata => F0507LogSinZCMetadata.instance;

  @override
  List<F0507LogSinZCPreset> get presets => F0507LogSinZCPresets.all;

  @override
  List<F0507LogSinZCVariant> get variants => F0507LogSinZCVariants.all;

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
