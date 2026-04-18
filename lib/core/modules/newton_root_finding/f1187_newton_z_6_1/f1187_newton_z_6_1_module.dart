// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1187_newton_z_6_1_presets.dart';
import 'f1187_newton_z_6_1_variants.dart';
import 'f1187_newton_z_6_1_metadata.dart';

/// Newton z^6 - 1 — Newton / Root-Finding.
class F1187NewtonZ61 extends EscapeTimeModule {
  F1187NewtonZ61()
      : super(
          id: 'f1187_newton_z_6_1',
          shader: 'shaders/f1187_newton_z_6_1_gpu.frag',
        );

  @override
  F1187NewtonZ61Metadata get metadata => F1187NewtonZ61Metadata.instance;

  @override
  List<F1187NewtonZ61Preset> get presets => F1187NewtonZ61Presets.all;

  @override
  List<F1187NewtonZ61Variant> get variants => F1187NewtonZ61Variants.all;

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
