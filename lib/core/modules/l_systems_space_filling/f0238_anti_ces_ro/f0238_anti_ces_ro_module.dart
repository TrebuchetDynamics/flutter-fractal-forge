// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/l_system_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0238_anti_ces_ro_presets.dart';
import 'f0238_anti_ces_ro_variants.dart';
import 'f0238_anti_ces_ro_metadata.dart';

/// Anti-Cesàro — L-Systems & Space-Filling.
class F0238AntiCesRo extends LSystemModule {
  F0238AntiCesRo()
      : super(
          id: 'f0238_anti_ces_ro',
          shader: 'shaders/f0238_anti_ces_ro_gpu.frag',
        );

  @override
  F0238AntiCesRoMetadata get metadata => F0238AntiCesRoMetadata.instance;

  @override
  List<F0238AntiCesRoPreset> get presets => F0238AntiCesRoPresets.all;

  @override
  List<F0238AntiCesRoVariant> get variants => F0238AntiCesRoVariants.all;

  @override
  int get defaultDepth => 5;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('depth', defaultDepth);
  }
}
