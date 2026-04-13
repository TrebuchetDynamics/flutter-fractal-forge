// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0510_tan_z_c_presets.dart';
import 'f0510_tan_z_c_variants.dart';
import 'f0510_tan_z_c_metadata.dart';

/// tan(z²) + c — Escape-Time (Complex Plane).
class F0510TanZC extends EscapeTimeModule {
  F0510TanZC()
      : super(
          id: 'f0510_tan_z_c',
          shader: 'shaders/f0510_tan_z_c_gpu.frag',
        );

  @override
  F0510TanZCMetadata get metadata => F0510TanZCMetadata.instance;

  @override
  List<F0510TanZCPreset> get presets => F0510TanZCPresets.all;

  @override
  List<F0510TanZCVariant> get variants => F0510TanZCVariants.all;

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
