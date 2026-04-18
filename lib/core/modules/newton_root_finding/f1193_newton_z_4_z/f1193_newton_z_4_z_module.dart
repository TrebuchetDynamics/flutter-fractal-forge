// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1193_newton_z_4_z_presets.dart';
import 'f1193_newton_z_4_z_variants.dart';
import 'f1193_newton_z_4_z_metadata.dart';

/// Newton z^4 - z — Newton / Root-Finding.
class F1193NewtonZ4Z extends EscapeTimeModule {
  F1193NewtonZ4Z()
      : super(
          id: 'f1193_newton_z_4_z',
          shader: 'shaders/f1193_newton_z_4_z_gpu.frag',
        );

  @override
  F1193NewtonZ4ZMetadata get metadata => F1193NewtonZ4ZMetadata.instance;

  @override
  List<F1193NewtonZ4ZPreset> get presets => F1193NewtonZ4ZPresets.all;

  @override
  List<F1193NewtonZ4ZVariant> get variants => F1193NewtonZ4ZVariants.all;

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
