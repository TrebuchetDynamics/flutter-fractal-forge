// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1214_nova_z_5_z_2_1_presets.dart';
import 'f1214_nova_z_5_z_2_1_variants.dart';
import 'f1214_nova_z_5_z_2_1_metadata.dart';

/// Nova z^5 + z^2 - 1 — Newton / Root-Finding.
class F1214NovaZ5Z21 extends EscapeTimeModule {
  F1214NovaZ5Z21()
      : super(
          id: 'f1214_nova_z_5_z_2_1',
          shader: 'shaders/f1214_nova_z_5_z_2_1_gpu.frag',
        );

  @override
  F1214NovaZ5Z21Metadata get metadata => F1214NovaZ5Z21Metadata.instance;

  @override
  List<F1214NovaZ5Z21Preset> get presets => F1214NovaZ5Z21Presets.all;

  @override
  List<F1214NovaZ5Z21Variant> get variants => F1214NovaZ5Z21Variants.all;

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
