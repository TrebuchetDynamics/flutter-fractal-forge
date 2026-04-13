// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0519_sin_z_c_presets.dart';
import 'f0519_sin_z_c_variants.dart';
import 'f0519_sin_z_c_metadata.dart';

/// sin(z)² + c — Escape-Time (Complex Plane).
class F0519SinZC extends EscapeTimeModule {
  F0519SinZC()
      : super(
          id: 'f0519_sin_z_c',
          shader: 'shaders/f0519_sin_z_c_gpu.frag',
        );

  @override
  F0519SinZCMetadata get metadata => F0519SinZCMetadata.instance;

  @override
  List<F0519SinZCPreset> get presets => F0519SinZCPresets.all;

  @override
  List<F0519SinZCVariant> get variants => F0519SinZCVariants.all;

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
