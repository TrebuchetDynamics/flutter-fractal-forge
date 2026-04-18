// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0773_thue_morse_2d_heatmap_presets.dart';
import 'f0773_thue_morse_2d_heatmap_variants.dart';
import 'f0773_thue_morse_2d_heatmap_metadata.dart';

/// Thue-Morse 2D Heatmap — Number-Theory Fractals.
class F0773ThueMorse2dHeatmap extends CellularModule {
  F0773ThueMorse2dHeatmap()
      : super(
          id: 'f0773_thue_morse_2d_heatmap',
          shader: 'shaders/f0773_thue_morse_2d_heatmap_gpu.frag',
        );

  @override
  F0773ThueMorse2dHeatmapMetadata get metadata => F0773ThueMorse2dHeatmapMetadata.instance;

  @override
  List<F0773ThueMorse2dHeatmapPreset> get presets => F0773ThueMorse2dHeatmapPresets.all;

  @override
  List<F0773ThueMorse2dHeatmapVariant> get variants => F0773ThueMorse2dHeatmapVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
