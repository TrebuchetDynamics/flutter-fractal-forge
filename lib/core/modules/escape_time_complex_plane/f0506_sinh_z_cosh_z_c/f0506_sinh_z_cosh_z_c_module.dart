// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0506_sinh_z_cosh_z_c_presets.dart';
import 'f0506_sinh_z_cosh_z_c_variants.dart';
import 'f0506_sinh_z_cosh_z_c_metadata.dart';

/// sinh(z)·cosh(z) + c — Escape-Time (Complex Plane).
class F0506SinhZCoshZC extends EscapeTimeModule {
  F0506SinhZCoshZC()
      : super(
          id: 'f0506_sinh_z_cosh_z_c',
          shader: 'shaders/f0506_sinh_z_cosh_z_c_gpu.frag',
        );

  @override
  F0506SinhZCoshZCMetadata get metadata => F0506SinhZCoshZCMetadata.instance;

  @override
  List<F0506SinhZCoshZCPreset> get presets => F0506SinhZCoshZCPresets.all;

  @override
  List<F0506SinhZCoshZCVariant> get variants => F0506SinhZCoshZCVariants.all;

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
