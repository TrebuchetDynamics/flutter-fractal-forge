// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0167_cauliflower_bulb_julia_presets.dart';
import 'f0167_cauliflower_bulb_julia_variants.dart';
import 'f0167_cauliflower_bulb_julia_metadata.dart';

/// Cauliflower Bulb Julia — Escape-Time (Complex Plane).
class F0167CauliflowerBulbJulia extends EscapeTimeModule {
  F0167CauliflowerBulbJulia()
      : super(
          id: 'f0167_cauliflower_bulb_julia',
          shader: 'shaders/f0167_cauliflower_bulb_julia_gpu.frag',
        );

  @override
  F0167CauliflowerBulbJuliaMetadata get metadata => F0167CauliflowerBulbJuliaMetadata.instance;

  @override
  List<F0167CauliflowerBulbJuliaPreset> get presets => F0167CauliflowerBulbJuliaPresets.all;

  @override
  List<F0167CauliflowerBulbJuliaVariant> get variants => F0167CauliflowerBulbJuliaVariants.all;

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
