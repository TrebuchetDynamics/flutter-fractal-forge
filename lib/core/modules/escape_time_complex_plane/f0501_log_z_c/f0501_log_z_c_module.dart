// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0501_log_z_c_presets.dart';
import 'f0501_log_z_c_variants.dart';
import 'f0501_log_z_c_metadata.dart';

/// log(z²) + c — Escape-Time (Complex Plane).
class F0501LogZC extends EscapeTimeModule {
  F0501LogZC()
      : super(
          id: 'f0501_log_z_c',
          shader: 'shaders/f0501_log_z_c_gpu.frag',
        );

  @override
  F0501LogZCMetadata get metadata => F0501LogZCMetadata.instance;

  @override
  List<F0501LogZCPreset> get presets => F0501LogZCPresets.all;

  @override
  List<F0501LogZCVariant> get variants => F0501LogZCVariants.all;

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
