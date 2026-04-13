// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0514_cot_z_c_presets.dart';
import 'f0514_cot_z_c_variants.dart';
import 'f0514_cot_z_c_metadata.dart';

/// cot(z) + c — Escape-Time (Complex Plane).
class F0514CotZC extends EscapeTimeModule {
  F0514CotZC()
      : super(
          id: 'f0514_cot_z_c',
          shader: 'shaders/f0514_cot_z_c_gpu.frag',
        );

  @override
  F0514CotZCMetadata get metadata => F0514CotZCMetadata.instance;

  @override
  List<F0514CotZCPreset> get presets => F0514CotZCPresets.all;

  @override
  List<F0514CotZCVariant> get variants => F0514CotZCVariants.all;

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
