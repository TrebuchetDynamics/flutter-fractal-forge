// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1203_newton_tan_z_z_presets.dart';
import 'f1203_newton_tan_z_z_variants.dart';
import 'f1203_newton_tan_z_z_metadata.dart';

/// Newton tan(z) - z — Newton / Root-Finding.
class F1203NewtonTanZZ extends EscapeTimeModule {
  F1203NewtonTanZZ()
      : super(
          id: 'f1203_newton_tan_z_z',
          shader: 'shaders/f1203_newton_tan_z_z_gpu.frag',
        );

  @override
  F1203NewtonTanZZMetadata get metadata => F1203NewtonTanZZMetadata.instance;

  @override
  List<F1203NewtonTanZZPreset> get presets => F1203NewtonTanZZPresets.all;

  @override
  List<F1203NewtonTanZZVariant> get variants => F1203NewtonTanZZVariants.all;

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
