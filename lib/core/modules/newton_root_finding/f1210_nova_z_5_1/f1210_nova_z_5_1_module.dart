// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1210_nova_z_5_1_presets.dart';
import 'f1210_nova_z_5_1_variants.dart';
import 'f1210_nova_z_5_1_metadata.dart';

/// Nova z^5 - 1 — Newton / Root-Finding.
class F1210NovaZ51 extends EscapeTimeModule {
  F1210NovaZ51()
      : super(
          id: 'f1210_nova_z_5_1',
          shader: 'shaders/f1210_nova_z_5_1_gpu.frag',
        );

  @override
  F1210NovaZ51Metadata get metadata => F1210NovaZ51Metadata.instance;

  @override
  List<F1210NovaZ51Preset> get presets => F1210NovaZ51Presets.all;

  @override
  List<F1210NovaZ51Variant> get variants => F1210NovaZ51Variants.all;

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
