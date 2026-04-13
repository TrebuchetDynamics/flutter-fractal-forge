// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0523_exp_z_z_c_presets.dart';
import 'f0523_exp_z_z_c_variants.dart';
import 'f0523_exp_z_z_c_metadata.dart';

/// exp(z) - z + c — Escape-Time (Complex Plane).
class F0523ExpZZC extends EscapeTimeModule {
  F0523ExpZZC()
      : super(
          id: 'f0523_exp_z_z_c',
          shader: 'shaders/f0523_exp_z_z_c_gpu.frag',
        );

  @override
  F0523ExpZZCMetadata get metadata => F0523ExpZZCMetadata.instance;

  @override
  List<F0523ExpZZCPreset> get presets => F0523ExpZZCPresets.all;

  @override
  List<F0523ExpZZCVariant> get variants => F0523ExpZZCVariants.all;

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
