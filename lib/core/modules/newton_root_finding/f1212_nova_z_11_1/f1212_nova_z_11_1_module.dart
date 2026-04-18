// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1212_nova_z_11_1_presets.dart';
import 'f1212_nova_z_11_1_variants.dart';
import 'f1212_nova_z_11_1_metadata.dart';

/// Nova z^11 - 1 — Newton / Root-Finding.
class F1212NovaZ111 extends EscapeTimeModule {
  F1212NovaZ111()
      : super(
          id: 'f1212_nova_z_11_1',
          shader: 'shaders/f1212_nova_z_11_1_gpu.frag',
        );

  @override
  F1212NovaZ111Metadata get metadata => F1212NovaZ111Metadata.instance;

  @override
  List<F1212NovaZ111Preset> get presets => F1212NovaZ111Presets.all;

  @override
  List<F1212NovaZ111Variant> get variants => F1212NovaZ111Variants.all;

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
