// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1200_newton_z_4_z_3_2_presets.dart';
import 'f1200_newton_z_4_z_3_2_variants.dart';
import 'f1200_newton_z_4_z_3_2_metadata.dart';

/// Newton z^4 - z^3 - 2 — Newton / Root-Finding.
class F1200NewtonZ4Z32 extends EscapeTimeModule {
  F1200NewtonZ4Z32()
      : super(
          id: 'f1200_newton_z_4_z_3_2',
          shader: 'shaders/f1200_newton_z_4_z_3_2_gpu.frag',
        );

  @override
  F1200NewtonZ4Z32Metadata get metadata => F1200NewtonZ4Z32Metadata.instance;

  @override
  List<F1200NewtonZ4Z32Preset> get presets => F1200NewtonZ4Z32Presets.all;

  @override
  List<F1200NewtonZ4Z32Variant> get variants => F1200NewtonZ4Z32Variants.all;

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
