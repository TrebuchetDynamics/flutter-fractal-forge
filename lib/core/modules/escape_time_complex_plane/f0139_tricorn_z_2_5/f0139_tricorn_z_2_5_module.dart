// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0139_tricorn_z_2_5_presets.dart';
import 'f0139_tricorn_z_2_5_variants.dart';
import 'f0139_tricorn_z_2_5_metadata.dart';

/// Tricorn z^2.5 — Escape-Time (Complex Plane).
class F0139TricornZ25 extends EscapeTimeModule {
  F0139TricornZ25()
      : super(
          id: 'f0139_tricorn_z_2_5',
          shader: 'shaders/f0139_tricorn_z_2_5_gpu.frag',
        );

  @override
  F0139TricornZ25Metadata get metadata => F0139TricornZ25Metadata.instance;

  @override
  List<F0139TricornZ25Preset> get presets => F0139TricornZ25Presets.all;

  @override
  List<F0139TricornZ25Variant> get variants => F0139TricornZ25Variants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
