// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1217_nova_z_6_1_presets.dart';
import 'f1217_nova_z_6_1_variants.dart';
import 'f1217_nova_z_6_1_metadata.dart';

/// Nova z^6 - 1 — Newton / Root-Finding.
class F1217NovaZ61 extends EscapeTimeModule {
  F1217NovaZ61()
      : super(
          id: 'f1217_nova_z_6_1',
          shader: 'shaders/f1217_nova_z_6_1_gpu.frag',
        );

  @override
  F1217NovaZ61Metadata get metadata => F1217NovaZ61Metadata.instance;

  @override
  List<F1217NovaZ61Preset> get presets => F1217NovaZ61Presets.all;

  @override
  List<F1217NovaZ61Variant> get variants => F1217NovaZ61Variants.all;

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
