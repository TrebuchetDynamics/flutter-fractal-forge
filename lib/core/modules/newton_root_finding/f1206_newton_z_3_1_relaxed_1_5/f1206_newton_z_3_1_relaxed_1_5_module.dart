// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1206_newton_z_3_1_relaxed_1_5_presets.dart';
import 'f1206_newton_z_3_1_relaxed_1_5_variants.dart';
import 'f1206_newton_z_3_1_relaxed_1_5_metadata.dart';

/// Newton z^3 - 1 (Relaxed 1.5) — Newton / Root-Finding.
class F1206NewtonZ31Relaxed15 extends EscapeTimeModule {
  F1206NewtonZ31Relaxed15()
      : super(
          id: 'f1206_newton_z_3_1_relaxed_1_5',
          shader: 'shaders/f1206_newton_z_3_1_relaxed_1_5_gpu.frag',
        );

  @override
  F1206NewtonZ31Relaxed15Metadata get metadata => F1206NewtonZ31Relaxed15Metadata.instance;

  @override
  List<F1206NewtonZ31Relaxed15Preset> get presets => F1206NewtonZ31Relaxed15Presets.all;

  @override
  List<F1206NewtonZ31Relaxed15Variant> get variants => F1206NewtonZ31Relaxed15Variants.all;

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
