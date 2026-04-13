// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0526_sin_z_z_c_presets.dart';
import 'f0526_sin_z_z_c_variants.dart';
import 'f0526_sin_z_z_c_metadata.dart';

/// sin(z) + z² + c — Escape-Time (Complex Plane).
class F0526SinZZC extends EscapeTimeModule {
  F0526SinZZC()
      : super(
          id: 'f0526_sin_z_z_c',
          shader: 'shaders/f0526_sin_z_z_c_gpu.frag',
        );

  @override
  F0526SinZZCMetadata get metadata => F0526SinZZCMetadata.instance;

  @override
  List<F0526SinZZCPreset> get presets => F0526SinZZCPresets.all;

  @override
  List<F0526SinZZCVariant> get variants => F0526SinZZCVariants.all;

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
