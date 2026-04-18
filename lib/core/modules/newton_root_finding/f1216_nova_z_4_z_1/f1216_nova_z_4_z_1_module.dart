// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1216_nova_z_4_z_1_presets.dart';
import 'f1216_nova_z_4_z_1_variants.dart';
import 'f1216_nova_z_4_z_1_metadata.dart';

/// Nova z^4 - z + 1 — Newton / Root-Finding.
class F1216NovaZ4Z1 extends EscapeTimeModule {
  F1216NovaZ4Z1()
      : super(
          id: 'f1216_nova_z_4_z_1',
          shader: 'shaders/f1216_nova_z_4_z_1_gpu.frag',
        );

  @override
  F1216NovaZ4Z1Metadata get metadata => F1216NovaZ4Z1Metadata.instance;

  @override
  List<F1216NovaZ4Z1Preset> get presets => F1216NovaZ4Z1Presets.all;

  @override
  List<F1216NovaZ4Z1Variant> get variants => F1216NovaZ4Z1Variants.all;

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
