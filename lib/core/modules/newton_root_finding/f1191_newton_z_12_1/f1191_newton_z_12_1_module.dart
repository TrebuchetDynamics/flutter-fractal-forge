// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1191_newton_z_12_1_presets.dart';
import 'f1191_newton_z_12_1_variants.dart';
import 'f1191_newton_z_12_1_metadata.dart';

/// Newton z^12 - 1 — Newton / Root-Finding.
class F1191NewtonZ121 extends EscapeTimeModule {
  F1191NewtonZ121()
      : super(
          id: 'f1191_newton_z_12_1',
          shader: 'shaders/f1191_newton_z_12_1_gpu.frag',
        );

  @override
  F1191NewtonZ121Metadata get metadata => F1191NewtonZ121Metadata.instance;

  @override
  List<F1191NewtonZ121Preset> get presets => F1191NewtonZ121Presets.all;

  @override
  List<F1191NewtonZ121Variant> get variants => F1191NewtonZ121Variants.all;

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
