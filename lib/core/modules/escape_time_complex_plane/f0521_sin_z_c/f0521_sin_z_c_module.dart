// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0521_sin_z_c_presets.dart';
import 'f0521_sin_z_c_variants.dart';
import 'f0521_sin_z_c_metadata.dart';

/// sin(z)³ + c — Escape-Time (Complex Plane).
class F0521SinZC extends EscapeTimeModule {
  F0521SinZC()
      : super(
          id: 'f0521_sin_z_c',
          shader: 'shaders/f0521_sin_z_c_gpu.frag',
        );

  @override
  F0521SinZCMetadata get metadata => F0521SinZCMetadata.instance;

  @override
  List<F0521SinZCPreset> get presets => F0521SinZCPresets.all;

  @override
  List<F0521SinZCVariant> get variants => F0521SinZCVariants.all;

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
