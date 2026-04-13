// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0162_lightning_julia_presets.dart';
import 'f0162_lightning_julia_variants.dart';
import 'f0162_lightning_julia_metadata.dart';

/// Lightning Julia — Escape-Time (Complex Plane).
class F0162LightningJulia extends EscapeTimeModule {
  F0162LightningJulia()
      : super(
          id: 'f0162_lightning_julia',
          shader: 'shaders/f0162_lightning_julia_gpu.frag',
        );

  @override
  F0162LightningJuliaMetadata get metadata => F0162LightningJuliaMetadata.instance;

  @override
  List<F0162LightningJuliaPreset> get presets => F0162LightningJuliaPresets.all;

  @override
  List<F0162LightningJuliaVariant> get variants => F0162LightningJuliaVariants.all;

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
