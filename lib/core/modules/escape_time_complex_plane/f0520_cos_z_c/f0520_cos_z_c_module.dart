// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0520_cos_z_c_presets.dart';
import 'f0520_cos_z_c_variants.dart';
import 'f0520_cos_z_c_metadata.dart';

/// cos(z)² + c — Escape-Time (Complex Plane).
class F0520CosZC extends EscapeTimeModule {
  F0520CosZC()
      : super(
          id: 'f0520_cos_z_c',
          shader: 'shaders/f0520_cos_z_c_gpu.frag',
        );

  @override
  F0520CosZCMetadata get metadata => F0520CosZCMetadata.instance;

  @override
  List<F0520CosZCPreset> get presets => F0520CosZCPresets.all;

  @override
  List<F0520CosZCVariant> get variants => F0520CosZCVariants.all;

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
