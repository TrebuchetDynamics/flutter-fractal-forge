// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1185_newton_z_4_1_presets.dart';
import 'f1185_newton_z_4_1_variants.dart';
import 'f1185_newton_z_4_1_metadata.dart';

/// Newton z^4 - 1 — Newton / Root-Finding.
class F1185NewtonZ41 extends EscapeTimeModule {
  F1185NewtonZ41()
      : super(
          id: 'f1185_newton_z_4_1',
          shader: 'shaders/f1185_newton_z_4_1_gpu.frag',
        );

  @override
  F1185NewtonZ41Metadata get metadata => F1185NewtonZ41Metadata.instance;

  @override
  List<F1185NewtonZ41Preset> get presets => F1185NewtonZ41Presets.all;

  @override
  List<F1185NewtonZ41Variant> get variants => F1185NewtonZ41Variants.all;

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
