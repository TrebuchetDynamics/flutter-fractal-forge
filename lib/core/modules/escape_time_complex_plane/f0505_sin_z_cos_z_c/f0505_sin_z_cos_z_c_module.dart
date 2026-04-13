// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0505_sin_z_cos_z_c_presets.dart';
import 'f0505_sin_z_cos_z_c_variants.dart';
import 'f0505_sin_z_cos_z_c_metadata.dart';

/// sin(z)·cos(z) + c — Escape-Time (Complex Plane).
class F0505SinZCosZC extends EscapeTimeModule {
  F0505SinZCosZC()
      : super(
          id: 'f0505_sin_z_cos_z_c',
          shader: 'shaders/f0505_sin_z_cos_z_c_gpu.frag',
        );

  @override
  F0505SinZCosZCMetadata get metadata => F0505SinZCosZCMetadata.instance;

  @override
  List<F0505SinZCosZCPreset> get presets => F0505SinZCosZCPresets.all;

  @override
  List<F0505SinZCosZCVariant> get variants => F0505SinZCosZCVariants.all;

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
