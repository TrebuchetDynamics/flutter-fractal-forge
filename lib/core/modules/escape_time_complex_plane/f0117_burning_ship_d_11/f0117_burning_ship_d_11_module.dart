// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0117_burning_ship_d_11_presets.dart';
import 'f0117_burning_ship_d_11_variants.dart';
import 'f0117_burning_ship_d_11_metadata.dart';

/// Burning Ship d=11 — Escape-Time (Complex Plane).
class F0117BurningShipD11 extends EscapeTimeModule {
  F0117BurningShipD11()
      : super(
          id: 'f0117_burning_ship_d_11',
          shader: 'shaders/f0117_burning_ship_d_11_gpu.frag',
        );

  @override
  F0117BurningShipD11Metadata get metadata => F0117BurningShipD11Metadata.instance;

  @override
  List<F0117BurningShipD11Preset> get presets => F0117BurningShipD11Presets.all;

  @override
  List<F0117BurningShipD11Variant> get variants => F0117BurningShipD11Variants.all;

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
