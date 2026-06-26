import 'dart:io';

import 'package:flutter_fractals/core/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'research-backed expansion topics are represented by working catalog modules',
      () {
    final registry = ModuleRegistry();
    final ids = registry.modules.map((module) => module.id).toSet();

    const topicRepresentatives = <String, List<String>>{
      'rational maps / advanced complex dynamics': [
        'rational_map',
        'blaschke',
        'mcmullen_map',
        'generalized_mcmullen',
      ],
      'Kleinian groups + circle inversion limit sets': [
        'apollonian_gasket',
        'pseudo_kleinian',
        'schottky_limit_set',
      ],
      'nonlinear/projective IFS': [
        'fractal_flame',
        'f1104_fractal_flame_v3_swirl',
      ],
      'Sprott / jerk / hidden strange attractors': [
        'sprott_a',
        'f0015_sprott_b',
        'f0020_sprott_g',
      ],
      'aperiodic substitution tilings': [
        'penrose_tiling',
        'rauzy_fractal',
        'pinwheel_tiling',
        'chair_tiling',
      ],
      '3D distance-estimator / KIFS variants': [
        'kifs_menger',
        'kifs_sierpinski_tetra',
        'quaternion_julia_3d',
        'dual_quaternion_julia',
        'mandelbox_shape_inversion',
      ],
      'curated CA families, not elementary rule spam': [
        'wolfram_rule30',
        'seeds_ca',
        'cyclic_ca',
        'replicator_ca',
      ],
    };

    for (final entry in topicRepresentatives.entries) {
      final missing = entry.value.where((id) => !ids.contains(id)).toList();
      expect(
        missing,
        isEmpty,
        reason: '${entry.key} representatives missing from ModuleRegistry',
      );
    }

    expect(
      ids.where((id) => id.contains('elementary_ca_rule')),
      isEmpty,
      reason:
          'Elementary CA rule spam should stay collapsed into wolfram_rule30.',
    );
  });

  test('academic expansion research provenance is checked in', () {
    const base = 'research/fractal-catalog-academic-expansion';
    for (final file in const [
      '$base/report.md',
      '$base/provenance.json',
      '$base/search-stats.txt',
    ]) {
      expect(File(file).existsSync(), isTrue, reason: '$file is missing');
    }
  });
}
