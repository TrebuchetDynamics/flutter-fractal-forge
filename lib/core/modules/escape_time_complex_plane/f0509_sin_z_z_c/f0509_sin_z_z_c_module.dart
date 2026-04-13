// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0509_sin_z_z_c_presets.dart';
import 'f0509_sin_z_z_c_variants.dart';
import 'f0509_sin_z_z_c_metadata.dart';

/// sin(z)/z + c — Escape-Time (Complex Plane).
class F0509SinZZC extends EscapeTimeModule {
  F0509SinZZC()
      : super(
          id: 'f0509_sin_z_z_c',
          shader: 'shaders/f0509_sin_z_z_c_gpu.frag',
        );

  @override
  F0509SinZZCMetadata get metadata => F0509SinZZCMetadata.instance;

  @override
  List<F0509SinZZCPreset> get presets => F0509SinZZCPresets.all;

  @override
  List<F0509SinZZCVariant> get variants => F0509SinZZCVariants.all;

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
