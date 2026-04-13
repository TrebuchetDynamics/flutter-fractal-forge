// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0525_sinh_z_c_presets.dart';
import 'f0525_sinh_z_c_variants.dart';
import 'f0525_sinh_z_c_metadata.dart';

/// sinh(z²) + c — Escape-Time (Complex Plane).
class F0525SinhZC extends EscapeTimeModule {
  F0525SinhZC()
      : super(
          id: 'f0525_sinh_z_c',
          shader: 'shaders/f0525_sinh_z_c_gpu.frag',
        );

  @override
  F0525SinhZCMetadata get metadata => F0525SinhZCMetadata.instance;

  @override
  List<F0525SinhZCPreset> get presets => F0525SinhZCPresets.all;

  @override
  List<F0525SinhZCVariant> get variants => F0525SinhZCVariants.all;

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
