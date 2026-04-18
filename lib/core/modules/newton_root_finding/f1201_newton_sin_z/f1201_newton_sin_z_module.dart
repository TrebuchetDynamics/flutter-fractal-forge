// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1201_newton_sin_z_presets.dart';
import 'f1201_newton_sin_z_variants.dart';
import 'f1201_newton_sin_z_metadata.dart';

/// Newton sin(z) — Newton / Root-Finding.
class F1201NewtonSinZ extends EscapeTimeModule {
  F1201NewtonSinZ()
      : super(
          id: 'f1201_newton_sin_z',
          shader: 'shaders/f1201_newton_sin_z_gpu.frag',
        );

  @override
  F1201NewtonSinZMetadata get metadata => F1201NewtonSinZMetadata.instance;

  @override
  List<F1201NewtonSinZPreset> get presets => F1201NewtonSinZPresets.all;

  @override
  List<F1201NewtonSinZVariant> get variants => F1201NewtonSinZVariants.all;

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
