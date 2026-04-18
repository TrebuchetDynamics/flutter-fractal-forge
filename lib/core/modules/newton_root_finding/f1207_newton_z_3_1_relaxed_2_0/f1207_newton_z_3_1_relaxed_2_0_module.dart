// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1207_newton_z_3_1_relaxed_2_0_presets.dart';
import 'f1207_newton_z_3_1_relaxed_2_0_variants.dart';
import 'f1207_newton_z_3_1_relaxed_2_0_metadata.dart';

/// Newton z^3 - 1 (Relaxed 2.0) — Newton / Root-Finding.
class F1207NewtonZ31Relaxed20 extends EscapeTimeModule {
  F1207NewtonZ31Relaxed20()
      : super(
          id: 'f1207_newton_z_3_1_relaxed_2_0',
          shader: 'shaders/f1207_newton_z_3_1_relaxed_2_0_gpu.frag',
        );

  @override
  F1207NewtonZ31Relaxed20Metadata get metadata => F1207NewtonZ31Relaxed20Metadata.instance;

  @override
  List<F1207NewtonZ31Relaxed20Preset> get presets => F1207NewtonZ31Relaxed20Presets.all;

  @override
  List<F1207NewtonZ31Relaxed20Variant> get variants => F1207NewtonZ31Relaxed20Variants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 100.0;

  @override
  int get defaultIterations => 200;


  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
