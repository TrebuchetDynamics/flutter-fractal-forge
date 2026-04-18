// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1202_newton_cos_z_presets.dart';
import 'f1202_newton_cos_z_variants.dart';
import 'f1202_newton_cos_z_metadata.dart';

/// Newton cos(z) — Newton / Root-Finding.
class F1202NewtonCosZ extends EscapeTimeModule {
  F1202NewtonCosZ()
      : super(
          id: 'f1202_newton_cos_z',
          shader: 'shaders/f1202_newton_cos_z_gpu.frag',
        );

  @override
  F1202NewtonCosZMetadata get metadata => F1202NewtonCosZMetadata.instance;

  @override
  List<F1202NewtonCosZPreset> get presets => F1202NewtonCosZPresets.all;

  @override
  List<F1202NewtonCosZVariant> get variants => F1202NewtonCosZVariants.all;

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
