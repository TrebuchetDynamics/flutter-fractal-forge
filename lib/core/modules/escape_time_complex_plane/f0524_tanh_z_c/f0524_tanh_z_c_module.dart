// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0524_tanh_z_c_presets.dart';
import 'f0524_tanh_z_c_variants.dart';
import 'f0524_tanh_z_c_metadata.dart';

/// tanh(z²) + c — Escape-Time (Complex Plane).
class F0524TanhZC extends EscapeTimeModule {
  F0524TanhZC()
      : super(
          id: 'f0524_tanh_z_c',
          shader: 'shaders/f0524_tanh_z_c_gpu.frag',
        );

  @override
  F0524TanhZCMetadata get metadata => F0524TanhZCMetadata.instance;

  @override
  List<F0524TanhZCPreset> get presets => F0524TanhZCPresets.all;

  @override
  List<F0524TanhZCVariant> get variants => F0524TanhZCVariants.all;

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
