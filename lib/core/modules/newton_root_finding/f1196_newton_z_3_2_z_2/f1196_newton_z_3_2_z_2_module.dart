// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1196_newton_z_3_2_z_2_presets.dart';
import 'f1196_newton_z_3_2_z_2_variants.dart';
import 'f1196_newton_z_3_2_z_2_metadata.dart';

/// Newton z^3 - 2*z + 2 — Newton / Root-Finding.
class F1196NewtonZ32Z2 extends EscapeTimeModule {
  F1196NewtonZ32Z2()
      : super(
          id: 'f1196_newton_z_3_2_z_2',
          shader: 'shaders/f1196_newton_z_3_2_z_2_gpu.frag',
        );

  @override
  F1196NewtonZ32Z2Metadata get metadata => F1196NewtonZ32Z2Metadata.instance;

  @override
  List<F1196NewtonZ32Z2Preset> get presets => F1196NewtonZ32Z2Presets.all;

  @override
  List<F1196NewtonZ32Z2Variant> get variants => F1196NewtonZ32Z2Variants.all;

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
