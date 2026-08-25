import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_fractals/features/catalog/data/catalog_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('3D catalog contains formula identities, not fixed parameter clones',
      () {
    final registry = ModuleRegistry();
    final catalog = CatalogRepository.fromRegistry(registry);
    final ids = {
      for (final entry in catalog.entries)
        if (entry.category == '3D Fractals') entry.module.id,
    };

    expect(ids, {
      'mandelbox',
      'f0597_sierpinski_carpet_3d_menger_cross',
      'kifs_menger',
      'kifs_sierpinski_tetra',
      'kifs_koch_fold',
      'kifs_snowflake_fold',
      'implicit_affine_fractal_surface',
      'sierpinski_octahedron_3d',
      'jerusalem_cube_3d',
      'vicsek_3d',
      'cantor_dust_3d',
      'pseudo_kleinian',
      'quaternion_julia_3d',
      'quaternion_mandelbrot_3d',
      'tetrabrot_3d',
      'arrowheadbrot_3d',
      'mousebrot_3d',
      'turtlebrot_3d',
      'hourglassbrot_3d',
      'juliabulb_3d',
      'dual_quaternion_julia',
      'mandelbox_shape_inversion',
      'apollonian_sphere_packing_3d',
      'inversive_limit_set_3d',
      'mandelbulb_time_modulated',
      'ternary_cayley_lumen',
      'gyroid_echo_reliquary',
      'mobius_echo_nest',
      'fibonacci_cone_bloom',
      'chebyshev_nodal_lantern',
      'amazing_box',
      'bulbils',
      'hartverdrahtet',
      'tglad_formula',
      'tortoise_toroidal_fractal',
      'mandelbulb',
    });

    final removedClones = <String>{
      'f0570_mandelbox_s_1_5',
      'f0571_mandelbox_s_1_8',
      'f0572_mandelbox_s_2_0',
      'f0573_mandelbox_s_2_2',
      'f0574_mandelbox_s_2_5',
      'f0575_mandelbox_s_2_7',
      'f0576_mandelbox_s_3_0',
      'f0577_mandelbox_s_3_5',
      'f0578_mandelbox_s_4_0',
      'f0561_mandelbulb_n_8',
      'f0562_mandelbulb_n_9',
      'f0563_mandelbulb_n_10',
      'f0564_mandelbulb_n_11',
      'f0565_mandelbulb_n_12',
      'f0566_mandelbulb_n_14',
      'f0567_mandelbulb_n_16',
      'f0568_mandelbulb_n_20',
      'f0569_mandelbulb_n_24',
      'f0540_quaternion_julia_0_2_0_8_0_0_0_0',
      'f0544_quaternion_julia_0_291_0_399_0_339_0_437',
      'f0545_quaternion_julia_0_08_0_0_0_8_0_0',
      'f0593_sierpinski_tetrahedron_3d',
      'f0594_menger_sponge_3d',
      'f0598_3d_koch_snowflake',
    };
    final registeredIds = registry.modules.map((module) => module.id).toSet();
    expect(registeredIds.intersection(removedClones), isEmpty);
  });

  test('consolidated modules preserve useful parameter ranges and presets', () {
    final registry = ModuleRegistry();
    final mandelbox = registry.byId('mandelbox');
    final timeBulb = registry.byId('mandelbulb_time_modulated');
    final quaternion = registry.byId('quaternion_julia_3d');
    final implicit = registry.byId('implicit_affine_fractal_surface');

    expect(mandelbox.parameters.singleWhere((p) => p.id == 'scale').max, 4.0);
    expect(timeBulb.parameters.singleWhere((p) => p.id == 'power').max, 24.0);
    expect(
      quaternion.parameters.map((parameter) => parameter.id),
      containsAll(['variant', 'c0', 'c1', 'c2', 'c3']),
    );
    expect(
      quaternion.builtInPresets
          .where((preset) => preset.params['variant'] == -1),
      hasLength(3),
    );
    expect(implicit.dimension, FractalDimension.threeD);
  });

  test('hydrogen orbital is not labeled as a fractal', () {
    final catalog = CatalogRepository.fromRegistry(ModuleRegistry());
    final hydrogen = catalog.entries.singleWhere(
      (entry) => entry.module.id == 'hydrogen_orbital',
    );

    expect(hydrogen.category, 'Scientific Visualization');
  });
}
