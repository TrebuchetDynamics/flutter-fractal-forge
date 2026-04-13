// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0483_sunrise_valley_presets.dart';
import 'f0483_sunrise_valley_variants.dart';
import 'f0483_sunrise_valley_metadata.dart';

/// Sunrise Valley — Escape-Time (Complex Plane).
class F0483SunriseValley extends EscapeTimeModule {
  F0483SunriseValley()
      : super(
          id: 'f0483_sunrise_valley',
          shader: 'shaders/f0483_sunrise_valley_gpu.frag',
        );

  @override
  F0483SunriseValleyMetadata get metadata => F0483SunriseValleyMetadata.instance;

  @override
  List<F0483SunriseValleyPreset> get presets => F0483SunriseValleyPresets.all;

  @override
  List<F0483SunriseValleyVariant> get variants => F0483SunriseValleyVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 1500;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
