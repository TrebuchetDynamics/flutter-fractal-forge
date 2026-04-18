// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1209_nova_z_4_1_presets.dart';
import 'f1209_nova_z_4_1_variants.dart';
import 'f1209_nova_z_4_1_metadata.dart';

/// Nova z^4 - 1 — Newton / Root-Finding.
class F1209NovaZ41 extends EscapeTimeModule {
  F1209NovaZ41()
      : super(
          id: 'f1209_nova_z_4_1',
          shader: 'shaders/f1209_nova_z_4_1_gpu.frag',
        );

  @override
  F1209NovaZ41Metadata get metadata => F1209NovaZ41Metadata.instance;

  @override
  List<F1209NovaZ41Preset> get presets => F1209NovaZ41Presets.all;

  @override
  List<F1209NovaZ41Variant> get variants => F1209NovaZ41Variants.all;

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
