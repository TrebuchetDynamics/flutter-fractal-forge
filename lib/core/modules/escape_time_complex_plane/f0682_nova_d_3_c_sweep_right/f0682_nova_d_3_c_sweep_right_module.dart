// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0682_nova_d_3_c_sweep_right_presets.dart';
import 'f0682_nova_d_3_c_sweep_right_variants.dart';
import 'f0682_nova_d_3_c_sweep_right_metadata.dart';

/// Nova d=3 c-sweep right — Escape-Time (Complex Plane).
class F0682NovaD3CSweepRight extends EscapeTimeModule {
  F0682NovaD3CSweepRight()
      : super(
          id: 'f0682_nova_d_3_c_sweep_right',
          shader: 'shaders/f0682_nova_d_3_c_sweep_right_gpu.frag',
        );

  @override
  F0682NovaD3CSweepRightMetadata get metadata => F0682NovaD3CSweepRightMetadata.instance;

  @override
  List<F0682NovaD3CSweepRightPreset> get presets => F0682NovaD3CSweepRightPresets.all;

  @override
  List<F0682NovaD3CSweepRightVariant> get variants => F0682NovaD3CSweepRightVariants.all;

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
