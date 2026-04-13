// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0529_siegel_disk_golden_presets.dart';
import 'f0529_siegel_disk_golden_variants.dart';
import 'f0529_siegel_disk_golden_metadata.dart';

/// Siegel Disk (golden) — Escape-Time (Complex Plane).
class F0529SiegelDiskGolden extends EscapeTimeModule {
  F0529SiegelDiskGolden()
      : super(
          id: 'f0529_siegel_disk_golden',
          shader: 'shaders/f0529_siegel_disk_golden_gpu.frag',
        );

  @override
  F0529SiegelDiskGoldenMetadata get metadata => F0529SiegelDiskGoldenMetadata.instance;

  @override
  List<F0529SiegelDiskGoldenPreset> get presets => F0529SiegelDiskGoldenPresets.all;

  @override
  List<F0529SiegelDiskGoldenVariant> get variants => F0529SiegelDiskGoldenVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 50.0;

  @override
  int get defaultIterations => 300;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
