// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/attractor_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1057_svensson_disk_presets.dart';
import 'f1057_svensson_disk_variants.dart';
import 'f1057_svensson_disk_metadata.dart';

/// Svensson Disk — Strange Attractors.
class F1057SvenssonDisk extends AttractorModule {
  F1057SvenssonDisk()
      : super(
          id: 'f1057_svensson_disk',
          shader: 'shaders/f1057_svensson_disk_gpu.frag',
        );

  @override
  F1057SvenssonDiskMetadata get metadata => F1057SvenssonDiskMetadata.instance;

  @override
  List<F1057SvenssonDiskPreset> get presets => F1057SvenssonDiskPresets.all;

  @override
  List<F1057SvenssonDiskVariant> get variants => F1057SvenssonDiskVariants.all;

  @override
  int get defaultIterations => 200000;

  @override
  double get defaultStepSize => 0.01;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('iterations', defaultIterations);
    p.setFloat('stepSize', defaultStepSize);
  }
}
