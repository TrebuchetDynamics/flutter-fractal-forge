// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0515_z_exp_z_c_presets.dart';
import 'f0515_z_exp_z_c_variants.dart';
import 'f0515_z_exp_z_c_metadata.dart';

/// z·exp(-z²) + c — Escape-Time (Complex Plane).
class F0515ZExpZC extends EscapeTimeModule {
  F0515ZExpZC()
      : super(
          id: 'f0515_z_exp_z_c',
          shader: 'shaders/f0515_z_exp_z_c_gpu.frag',
        );

  @override
  F0515ZExpZCMetadata get metadata => F0515ZExpZCMetadata.instance;

  @override
  List<F0515ZExpZCPreset> get presets => F0515ZExpZCPresets.all;

  @override
  List<F0515ZExpZCVariant> get variants => F0515ZExpZCVariants.all;

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
