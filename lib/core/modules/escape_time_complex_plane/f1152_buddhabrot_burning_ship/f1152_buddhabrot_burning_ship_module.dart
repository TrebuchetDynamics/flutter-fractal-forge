// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f1152_buddhabrot_burning_ship_presets.dart';
import 'f1152_buddhabrot_burning_ship_variants.dart';
import 'f1152_buddhabrot_burning_ship_metadata.dart';

/// Buddhabrot Burning Ship — Escape-Time (Complex Plane).
class F1152BuddhabrotBurningShip extends EscapeTimeModule {
  F1152BuddhabrotBurningShip()
      : super(
          id: 'f1152_buddhabrot_burning_ship',
          shader: 'shaders/f1152_buddhabrot_burning_ship_gpu.frag',
        );

  @override
  F1152BuddhabrotBurningShipMetadata get metadata => F1152BuddhabrotBurningShipMetadata.instance;

  @override
  List<F1152BuddhabrotBurningShipPreset> get presets => F1152BuddhabrotBurningShipPresets.all;

  @override
  List<F1152BuddhabrotBurningShipVariant> get variants => F1152BuddhabrotBurningShipVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 1024;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
