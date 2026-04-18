// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1215_nova_z_3_2_z_2_presets.dart';
import 'f1215_nova_z_3_2_z_2_variants.dart';
import 'f1215_nova_z_3_2_z_2_metadata.dart';

/// Nova z^3 - 2*z + 2 — Newton / Root-Finding.
class F1215NovaZ32Z2 extends EscapeTimeModule {
  F1215NovaZ32Z2()
      : super(
          id: 'f1215_nova_z_3_2_z_2',
          shader: 'shaders/f1215_nova_z_3_2_z_2_gpu.frag',
        );

  @override
  F1215NovaZ32Z2Metadata get metadata => F1215NovaZ32Z2Metadata.instance;

  @override
  List<F1215NovaZ32Z2Preset> get presets => F1215NovaZ32Z2Presets.all;

  @override
  List<F1215NovaZ32Z2Variant> get variants => F1215NovaZ32Z2Variants.all;

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
