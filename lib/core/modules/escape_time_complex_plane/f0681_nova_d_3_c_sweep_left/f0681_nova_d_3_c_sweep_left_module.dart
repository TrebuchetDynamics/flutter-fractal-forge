// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0681_nova_d_3_c_sweep_left_presets.dart';
import 'f0681_nova_d_3_c_sweep_left_variants.dart';
import 'f0681_nova_d_3_c_sweep_left_metadata.dart';

/// Nova d=3 c-sweep left — Escape-Time (Complex Plane).
class F0681NovaD3CSweepLeft extends EscapeTimeModule {
  F0681NovaD3CSweepLeft()
      : super(
          id: 'f0681_nova_d_3_c_sweep_left',
          shader: 'shaders/f0681_nova_d_3_c_sweep_left_gpu.frag',
        );

  @override
  F0681NovaD3CSweepLeftMetadata get metadata => F0681NovaD3CSweepLeftMetadata.instance;

  @override
  List<F0681NovaD3CSweepLeftPreset> get presets => F0681NovaD3CSweepLeftPresets.all;

  @override
  List<F0681NovaD3CSweepLeftVariant> get variants => F0681NovaD3CSweepLeftVariants.all;

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
