// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0504_z_tan_z_c_presets.dart';
import 'f0504_z_tan_z_c_variants.dart';
import 'f0504_z_tan_z_c_metadata.dart';

/// z·tan(z) + c — Escape-Time (Complex Plane).
class F0504ZTanZC extends EscapeTimeModule {
  F0504ZTanZC()
      : super(
          id: 'f0504_z_tan_z_c',
          shader: 'shaders/f0504_z_tan_z_c_gpu.frag',
        );

  @override
  F0504ZTanZCMetadata get metadata => F0504ZTanZCMetadata.instance;

  @override
  List<F0504ZTanZCPreset> get presets => F0504ZTanZCPresets.all;

  @override
  List<F0504ZTanZCVariant> get variants => F0504ZTanZCVariants.all;

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
