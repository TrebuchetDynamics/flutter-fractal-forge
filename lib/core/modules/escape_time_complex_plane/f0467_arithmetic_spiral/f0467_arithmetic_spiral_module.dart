// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/escape_time_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0467_arithmetic_spiral_presets.dart';
import 'f0467_arithmetic_spiral_variants.dart';
import 'f0467_arithmetic_spiral_metadata.dart';

/// Arithmetic Spiral — Escape-Time (Complex Plane).
class F0467ArithmeticSpiral extends EscapeTimeModule {
  F0467ArithmeticSpiral()
      : super(
          id: 'f0467_arithmetic_spiral',
          shader: 'shaders/f0467_arithmetic_spiral_gpu.frag',
        );

  @override
  F0467ArithmeticSpiralMetadata get metadata => F0467ArithmeticSpiralMetadata.instance;

  @override
  List<F0467ArithmeticSpiralPreset> get presets => F0467ArithmeticSpiralPresets.all;

  @override
  List<F0467ArithmeticSpiralVariant> get variants => F0467ArithmeticSpiralVariants.all;

  @override
  double get defaultPower => 2.0;

  @override
  double get defaultBailout => 4.0;

  @override
  int get defaultIterations => 8000;

  @override
  DeepZoomStrategy get deepZoom => DeepZoomStrategy.perturbation;

  @override
  void configureShader(ShaderParams p) {
    p.setFloat('power', defaultPower);
    p.setFloat('bailout', defaultBailout);
    p.setInt('iterations', defaultIterations);
  }
}
