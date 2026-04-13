// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0332_nagel_schreckenberg_traffic_presets.dart';
import 'f0332_nagel_schreckenberg_traffic_variants.dart';
import 'f0332_nagel_schreckenberg_traffic_metadata.dart';

/// Nagel-Schreckenberg Traffic — Cellular & Stochastic.
class F0332NagelSchreckenbergTraffic extends CellularModule {
  F0332NagelSchreckenbergTraffic()
      : super(
          id: 'f0332_nagel_schreckenberg_traffic',
          shader: 'shaders/f0332_nagel_schreckenberg_traffic_gpu.frag',
        );

  @override
  F0332NagelSchreckenbergTrafficMetadata get metadata => F0332NagelSchreckenbergTrafficMetadata.instance;

  @override
  List<F0332NagelSchreckenbergTrafficPreset> get presets => F0332NagelSchreckenbergTrafficPresets.all;

  @override
  List<F0332NagelSchreckenbergTrafficVariant> get variants => F0332NagelSchreckenbergTrafficVariants.all;

  @override
  int get defaultGenerations => 256;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
