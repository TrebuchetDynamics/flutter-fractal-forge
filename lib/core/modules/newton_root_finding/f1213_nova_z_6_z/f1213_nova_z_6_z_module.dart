// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1213_nova_z_6_z_presets.dart';
import 'f1213_nova_z_6_z_variants.dart';
import 'f1213_nova_z_6_z_metadata.dart';

/// Nova z^6 - z — Newton / Root-Finding.
class F1213NovaZ6Z extends EscapeTimeModule {
  F1213NovaZ6Z()
      : super(
          id: 'f1213_nova_z_6_z',
          shader: 'shaders/f1213_nova_z_6_z_gpu.frag',
        );

  @override
  F1213NovaZ6ZMetadata get metadata => F1213NovaZ6ZMetadata.instance;

  @override
  List<F1213NovaZ6ZPreset> get presets => F1213NovaZ6ZPresets.all;

  @override
  List<F1213NovaZ6ZVariant> get variants => F1213NovaZ6ZVariants.all;

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
