// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1192_newton_z_3_z_presets.dart';
import 'f1192_newton_z_3_z_variants.dart';
import 'f1192_newton_z_3_z_metadata.dart';

/// Newton z^3 - z — Newton / Root-Finding.
class F1192NewtonZ3Z extends EscapeTimeModule {
  F1192NewtonZ3Z()
      : super(
          id: 'f1192_newton_z_3_z',
          shader: 'shaders/f1192_newton_z_3_z_gpu.frag',
        );

  @override
  F1192NewtonZ3ZMetadata get metadata => F1192NewtonZ3ZMetadata.instance;

  @override
  List<F1192NewtonZ3ZPreset> get presets => F1192NewtonZ3ZPresets.all;

  @override
  List<F1192NewtonZ3ZVariant> get variants => F1192NewtonZ3ZVariants.all;

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
