// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1189_newton_z_8_1_presets.dart';
import 'f1189_newton_z_8_1_variants.dart';
import 'f1189_newton_z_8_1_metadata.dart';

/// Newton z^8 - 1 — Newton / Root-Finding.
class F1189NewtonZ81 extends EscapeTimeModule {
  F1189NewtonZ81()
      : super(
          id: 'f1189_newton_z_8_1',
          shader: 'shaders/f1189_newton_z_8_1_gpu.frag',
        );

  @override
  F1189NewtonZ81Metadata get metadata => F1189NewtonZ81Metadata.instance;

  @override
  List<F1189NewtonZ81Preset> get presets => F1189NewtonZ81Presets.all;

  @override
  List<F1189NewtonZ81Variant> get variants => F1189NewtonZ81Variants.all;

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
