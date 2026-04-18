// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1205_newton_z_3_1_relaxed_0_5_presets.dart';
import 'f1205_newton_z_3_1_relaxed_0_5_variants.dart';
import 'f1205_newton_z_3_1_relaxed_0_5_metadata.dart';

/// Newton z^3 - 1 (Relaxed 0.5) — Newton / Root-Finding.
class F1205NewtonZ31Relaxed05 extends EscapeTimeModule {
  F1205NewtonZ31Relaxed05()
      : super(
          id: 'f1205_newton_z_3_1_relaxed_0_5',
          shader: 'shaders/f1205_newton_z_3_1_relaxed_0_5_gpu.frag',
        );

  @override
  F1205NewtonZ31Relaxed05Metadata get metadata => F1205NewtonZ31Relaxed05Metadata.instance;

  @override
  List<F1205NewtonZ31Relaxed05Preset> get presets => F1205NewtonZ31Relaxed05Presets.all;

  @override
  List<F1205NewtonZ31Relaxed05Variant> get variants => F1205NewtonZ31Relaxed05Variants.all;

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
