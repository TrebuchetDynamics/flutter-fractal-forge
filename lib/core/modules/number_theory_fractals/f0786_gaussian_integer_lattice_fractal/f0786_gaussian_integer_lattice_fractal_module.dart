// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0786_gaussian_integer_lattice_fractal_presets.dart';
import 'f0786_gaussian_integer_lattice_fractal_variants.dart';
import 'f0786_gaussian_integer_lattice_fractal_metadata.dart';

/// Gaussian Integer Lattice Fractal — Number-Theory Fractals.
class F0786GaussianIntegerLatticeFractal extends CellularModule {
  F0786GaussianIntegerLatticeFractal()
      : super(
          id: 'f0786_gaussian_integer_lattice_fractal',
          shader: 'shaders/f0786_gaussian_integer_lattice_fractal_gpu.frag',
        );

  @override
  F0786GaussianIntegerLatticeFractalMetadata get metadata => F0786GaussianIntegerLatticeFractalMetadata.instance;

  @override
  List<F0786GaussianIntegerLatticeFractalPreset> get presets => F0786GaussianIntegerLatticeFractalPresets.all;

  @override
  List<F0786GaussianIntegerLatticeFractalVariant> get variants => F0786GaussianIntegerLatticeFractalVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
