// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0658_magnet_iv_presets.dart';
import 'f0658_magnet_iv_variants.dart';
import 'f0658_magnet_iv_metadata.dart';

/// Magnet IV — Escape-Time (Complex Plane).
class F0658MagnetIv extends EscapeTimeModule {
  F0658MagnetIv()
      : super(
          id: 'f0658_magnet_iv',
          shader: 'shaders/f0658_magnet_iv_gpu.frag',
        );

  @override
  F0658MagnetIvMetadata get metadata => F0658MagnetIvMetadata.instance;

  @override
  List<F0658MagnetIvPreset> get presets => F0658MagnetIvPresets.all;

  @override
  List<F0658MagnetIvVariant> get variants => F0658MagnetIvVariants.all;

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
