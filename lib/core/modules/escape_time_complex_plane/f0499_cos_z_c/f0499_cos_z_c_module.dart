// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0499_cos_z_c_presets.dart';
import 'f0499_cos_z_c_variants.dart';
import 'f0499_cos_z_c_metadata.dart';

/// cos(z²) + c — Escape-Time (Complex Plane).
class F0499CosZC extends EscapeTimeModule {
  F0499CosZC()
      : super(
          id: 'f0499_cos_z_c',
          shader: 'shaders/f0499_cos_z_c_gpu.frag',
        );

  @override
  F0499CosZCMetadata get metadata => F0499CosZCMetadata.instance;

  @override
  List<F0499CosZCPreset> get presets => F0499CosZCPresets.all;

  @override
  List<F0499CosZCVariant> get variants => F0499CosZCVariants.all;

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
