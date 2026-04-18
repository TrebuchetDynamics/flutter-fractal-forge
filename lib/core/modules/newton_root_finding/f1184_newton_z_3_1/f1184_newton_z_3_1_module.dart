// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1184_newton_z_3_1_presets.dart';
import 'f1184_newton_z_3_1_variants.dart';
import 'f1184_newton_z_3_1_metadata.dart';

/// Newton z^3 - 1 — Newton / Root-Finding.
class F1184NewtonZ31 extends EscapeTimeModule {
  F1184NewtonZ31()
      : super(
          id: 'f1184_newton_z_3_1',
          shader: 'shaders/f1184_newton_z_3_1_gpu.frag',
        );

  @override
  F1184NewtonZ31Metadata get metadata => F1184NewtonZ31Metadata.instance;

  @override
  List<F1184NewtonZ31Preset> get presets => F1184NewtonZ31Presets.all;

  @override
  List<F1184NewtonZ31Variant> get variants => F1184NewtonZ31Variants.all;

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
