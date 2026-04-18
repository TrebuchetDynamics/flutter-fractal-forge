// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1183_newton_z_2_1_presets.dart';
import 'f1183_newton_z_2_1_variants.dart';
import 'f1183_newton_z_2_1_metadata.dart';

/// Newton z^2 - 1 — Newton / Root-Finding.
class F1183NewtonZ21 extends EscapeTimeModule {
  F1183NewtonZ21()
      : super(
          id: 'f1183_newton_z_2_1',
          shader: 'shaders/f1183_newton_z_2_1_gpu.frag',
        );

  @override
  F1183NewtonZ21Metadata get metadata => F1183NewtonZ21Metadata.instance;

  @override
  List<F1183NewtonZ21Preset> get presets => F1183NewtonZ21Presets.all;

  @override
  List<F1183NewtonZ21Variant> get variants => F1183NewtonZ21Variants.all;

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
