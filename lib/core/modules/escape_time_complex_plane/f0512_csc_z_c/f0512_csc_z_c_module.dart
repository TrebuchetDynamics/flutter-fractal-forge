// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0512_csc_z_c_presets.dart';
import 'f0512_csc_z_c_variants.dart';
import 'f0512_csc_z_c_metadata.dart';

/// csc(z) + c — Escape-Time (Complex Plane).
class F0512CscZC extends EscapeTimeModule {
  F0512CscZC()
      : super(
          id: 'f0512_csc_z_c',
          shader: 'shaders/f0512_csc_z_c_gpu.frag',
        );

  @override
  F0512CscZCMetadata get metadata => F0512CscZCMetadata.instance;

  @override
  List<F0512CscZCPreset> get presets => F0512CscZCPresets.all;

  @override
  List<F0512CscZCVariant> get variants => F0512CscZCVariants.all;

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
