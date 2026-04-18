// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1194_newton_z_5_z_presets.dart';
import 'f1194_newton_z_5_z_variants.dart';
import 'f1194_newton_z_5_z_metadata.dart';

/// Newton z^5 - z — Newton / Root-Finding.
class F1194NewtonZ5Z extends EscapeTimeModule {
  F1194NewtonZ5Z()
      : super(
          id: 'f1194_newton_z_5_z',
          shader: 'shaders/f1194_newton_z_5_z_gpu.frag',
        );

  @override
  F1194NewtonZ5ZMetadata get metadata => F1194NewtonZ5ZMetadata.instance;

  @override
  List<F1194NewtonZ5ZPreset> get presets => F1194NewtonZ5ZPresets.all;

  @override
  List<F1194NewtonZ5ZVariant> get variants => F1194NewtonZ5ZVariants.all;

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
