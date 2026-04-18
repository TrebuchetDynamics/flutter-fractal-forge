// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1211_nova_z_7_1_presets.dart';
import 'f1211_nova_z_7_1_variants.dart';
import 'f1211_nova_z_7_1_metadata.dart';

/// Nova z^7 - 1 — Newton / Root-Finding.
class F1211NovaZ71 extends EscapeTimeModule {
  F1211NovaZ71()
      : super(
          id: 'f1211_nova_z_7_1',
          shader: 'shaders/f1211_nova_z_7_1_gpu.frag',
        );

  @override
  F1211NovaZ71Metadata get metadata => F1211NovaZ71Metadata.instance;

  @override
  List<F1211NovaZ71Preset> get presets => F1211NovaZ71Presets.all;

  @override
  List<F1211NovaZ71Variant> get variants => F1211NovaZ71Variants.all;

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
