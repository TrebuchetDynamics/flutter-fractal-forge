// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1190_newton_z_11_1_presets.dart';
import 'f1190_newton_z_11_1_variants.dart';
import 'f1190_newton_z_11_1_metadata.dart';

/// Newton z^11 - 1 — Newton / Root-Finding.
class F1190NewtonZ111 extends EscapeTimeModule {
  F1190NewtonZ111()
      : super(
          id: 'f1190_newton_z_11_1',
          shader: 'shaders/f1190_newton_z_11_1_gpu.frag',
        );

  @override
  F1190NewtonZ111Metadata get metadata => F1190NewtonZ111Metadata.instance;

  @override
  List<F1190NewtonZ111Preset> get presets => F1190NewtonZ111Presets.all;

  @override
  List<F1190NewtonZ111Variant> get variants => F1190NewtonZ111Variants.all;

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
