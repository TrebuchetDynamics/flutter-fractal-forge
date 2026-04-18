// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1188_newton_z_7_1_presets.dart';
import 'f1188_newton_z_7_1_variants.dart';
import 'f1188_newton_z_7_1_metadata.dart';

/// Newton z^7 - 1 — Newton / Root-Finding.
class F1188NewtonZ71 extends EscapeTimeModule {
  F1188NewtonZ71()
      : super(
          id: 'f1188_newton_z_7_1',
          shader: 'shaders/f1188_newton_z_7_1_gpu.frag',
        );

  @override
  F1188NewtonZ71Metadata get metadata => F1188NewtonZ71Metadata.instance;

  @override
  List<F1188NewtonZ71Preset> get presets => F1188NewtonZ71Presets.all;

  @override
  List<F1188NewtonZ71Variant> get variants => F1188NewtonZ71Variants.all;

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
