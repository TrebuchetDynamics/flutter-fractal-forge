// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0522_exp_z_z_c_presets.dart';
import 'f0522_exp_z_z_c_variants.dart';
import 'f0522_exp_z_z_c_metadata.dart';

/// exp(z) + z + c — Escape-Time (Complex Plane).
class F0522ExpZZC extends EscapeTimeModule {
  F0522ExpZZC()
      : super(
          id: 'f0522_exp_z_z_c',
          shader: 'shaders/f0522_exp_z_z_c_gpu.frag',
        );

  @override
  F0522ExpZZCMetadata get metadata => F0522ExpZZCMetadata.instance;

  @override
  List<F0522ExpZZCPreset> get presets => F0522ExpZZCPresets.all;

  @override
  List<F0522ExpZZCVariant> get variants => F0522ExpZZCVariants.all;

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
