// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1195_newton_z_6_z_presets.dart';
import 'f1195_newton_z_6_z_variants.dart';
import 'f1195_newton_z_6_z_metadata.dart';

/// Newton z^6 - z — Newton / Root-Finding.
class F1195NewtonZ6Z extends EscapeTimeModule {
  F1195NewtonZ6Z()
      : super(
          id: 'f1195_newton_z_6_z',
          shader: 'shaders/f1195_newton_z_6_z_gpu.frag',
        );

  @override
  F1195NewtonZ6ZMetadata get metadata => F1195NewtonZ6ZMetadata.instance;

  @override
  List<F1195NewtonZ6ZPreset> get presets => F1195NewtonZ6ZPresets.all;

  @override
  List<F1195NewtonZ6ZVariant> get variants => F1195NewtonZ6ZVariants.all;

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
