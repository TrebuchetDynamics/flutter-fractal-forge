// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0657_magnet_iii_presets.dart';
import 'f0657_magnet_iii_variants.dart';
import 'f0657_magnet_iii_metadata.dart';

/// Magnet III — Escape-Time (Complex Plane).
class F0657MagnetIii extends EscapeTimeModule {
  F0657MagnetIii()
      : super(
          id: 'f0657_magnet_iii',
          shader: 'shaders/f0657_magnet_iii_gpu.frag',
        );

  @override
  F0657MagnetIiiMetadata get metadata => F0657MagnetIiiMetadata.instance;

  @override
  List<F0657MagnetIiiPreset> get presets => F0657MagnetIiiPresets.all;

  @override
  List<F0657MagnetIiiVariant> get variants => F0657MagnetIiiVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
