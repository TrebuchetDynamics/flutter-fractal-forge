// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0498_sin_z_c_presets.dart';
import 'f0498_sin_z_c_variants.dart';
import 'f0498_sin_z_c_metadata.dart';

/// sin(z²) + c — Escape-Time (Complex Plane).
class F0498SinZC extends EscapeTimeModule {
  F0498SinZC()
      : super(
          id: 'f0498_sin_z_c',
          shader: 'shaders/f0498_sin_z_c_gpu.frag',
        );

  @override
  F0498SinZCMetadata get metadata => F0498SinZCMetadata.instance;

  @override
  List<F0498SinZCPreset> get presets => F0498SinZCPresets.all;

  @override
  List<F0498SinZCVariant> get variants => F0498SinZCVariants.all;

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
