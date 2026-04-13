// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0502_sin_1_z_c_presets.dart';
import 'f0502_sin_1_z_c_variants.dart';
import 'f0502_sin_1_z_c_metadata.dart';

/// sin(1/z) + c — Escape-Time (Complex Plane).
class F0502Sin1ZC extends EscapeTimeModule {
  F0502Sin1ZC()
      : super(
          id: 'f0502_sin_1_z_c',
          shader: 'shaders/f0502_sin_1_z_c_gpu.frag',
        );

  @override
  F0502Sin1ZCMetadata get metadata => F0502Sin1ZCMetadata.instance;

  @override
  List<F0502Sin1ZCPreset> get presets => F0502Sin1ZCPresets.all;

  @override
  List<F0502Sin1ZCVariant> get variants => F0502Sin1ZCVariants.all;

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
