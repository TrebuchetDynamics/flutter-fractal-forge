// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1186_newton_z_5_1_presets.dart';
import 'f1186_newton_z_5_1_variants.dart';
import 'f1186_newton_z_5_1_metadata.dart';

/// Newton z^5 - 1 — Newton / Root-Finding.
class F1186NewtonZ51 extends EscapeTimeModule {
  F1186NewtonZ51()
      : super(
          id: 'f1186_newton_z_5_1',
          shader: 'shaders/f1186_newton_z_5_1_gpu.frag',
        );

  @override
  F1186NewtonZ51Metadata get metadata => F1186NewtonZ51Metadata.instance;

  @override
  List<F1186NewtonZ51Preset> get presets => F1186NewtonZ51Presets.all;

  @override
  List<F1186NewtonZ51Variant> get variants => F1186NewtonZ51Variants.all;

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
