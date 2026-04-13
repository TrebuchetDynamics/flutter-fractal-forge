// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0513_sec_z_c_presets.dart';
import 'f0513_sec_z_c_variants.dart';
import 'f0513_sec_z_c_metadata.dart';

/// sec(z) + c — Escape-Time (Complex Plane).
class F0513SecZC extends EscapeTimeModule {
  F0513SecZC()
      : super(
          id: 'f0513_sec_z_c',
          shader: 'shaders/f0513_sec_z_c_gpu.frag',
        );

  @override
  F0513SecZCMetadata get metadata => F0513SecZCMetadata.instance;

  @override
  List<F0513SecZCPreset> get presets => F0513SecZCPresets.all;

  @override
  List<F0513SecZCVariant> get variants => F0513SecZCVariants.all;

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
