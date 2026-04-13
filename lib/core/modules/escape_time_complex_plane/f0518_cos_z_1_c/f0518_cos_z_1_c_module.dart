// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0518_cos_z_1_c_presets.dart';
import 'f0518_cos_z_1_c_variants.dart';
import 'f0518_cos_z_1_c_metadata.dart';

/// cos(z-1) + c — Escape-Time (Complex Plane).
class F0518CosZ1C extends EscapeTimeModule {
  F0518CosZ1C()
      : super(
          id: 'f0518_cos_z_1_c',
          shader: 'shaders/f0518_cos_z_1_c_gpu.frag',
        );

  @override
  F0518CosZ1CMetadata get metadata => F0518CosZ1CMetadata.instance;

  @override
  List<F0518CosZ1CPreset> get presets => F0518CosZ1CPresets.all;

  @override
  List<F0518CosZ1CVariant> get variants => F0518CosZ1CVariants.all;

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
