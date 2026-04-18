// GENERATED — DO NOT EDIT BY HAND.
// Source: research pipeline admit stage.
// Regenerate via: forge admit <batch_id>

import '../../base_classes/cellular_module_base.dart';
import '../../base_classes/shader_params.dart';
import 'f0785_eisenstein_integer_lattice_fractal_presets.dart';
import 'f0785_eisenstein_integer_lattice_fractal_variants.dart';
import 'f0785_eisenstein_integer_lattice_fractal_metadata.dart';

/// Eisenstein Integer Lattice Fractal — Number-Theory Fractals.
class F0785EisensteinIntegerLatticeFractal extends CellularModule {
  F0785EisensteinIntegerLatticeFractal()
      : super(
          id: 'f0785_eisenstein_integer_lattice_fractal',
          shader: 'shaders/f0785_eisenstein_integer_lattice_fractal_gpu.frag',
        );

  @override
  F0785EisensteinIntegerLatticeFractalMetadata get metadata => F0785EisensteinIntegerLatticeFractalMetadata.instance;

  @override
  List<F0785EisensteinIntegerLatticeFractalPreset> get presets => F0785EisensteinIntegerLatticeFractalPresets.all;

  @override
  List<F0785EisensteinIntegerLatticeFractalVariant> get variants => F0785EisensteinIntegerLatticeFractalVariants.all;

  @override
  int get defaultGenerations => 100;

  @override
  void configureShader(ShaderParams p) {
    p.setInt('generations', defaultGenerations);
  }
}
