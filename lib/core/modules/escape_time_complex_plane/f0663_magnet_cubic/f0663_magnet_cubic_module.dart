// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0663_magnet_cubic_presets.dart';
import 'f0663_magnet_cubic_variants.dart';
import 'f0663_magnet_cubic_metadata.dart';

/// Magnet-Cubic — Escape-Time (Complex Plane).
class F0663MagnetCubic extends EscapeTimeModule {
  F0663MagnetCubic()
      : super(
          id: 'f0663_magnet_cubic',
          shader: 'shaders/f0663_magnet_cubic_gpu.frag',
        );

  @override
  F0663MagnetCubicMetadata get metadata => F0663MagnetCubicMetadata.instance;

  @override
  List<F0663MagnetCubicPreset> get presets => F0663MagnetCubicPresets.all;

  @override
  List<F0663MagnetCubicVariant> get variants => F0663MagnetCubicVariants.all;

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
