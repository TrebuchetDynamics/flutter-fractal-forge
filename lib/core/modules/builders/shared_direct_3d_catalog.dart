// GENERATED — reviewed direct 3D renderer promotions.
// Source: existing-app distance-estimated 3D leads.

import 'package:flutter_fractals/core/modules/builders/raymarched_3d_builder.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';

class SharedDirect3DCatalogEntry {
  final String id;
  final String name;
  final String shaderAsset;
  final double defaultPower;
  final double maxPower;

  const SharedDirect3DCatalogEntry({
    required this.id,
    required this.name,
    required this.shaderAsset,
    this.defaultPower = 2,
    this.maxPower = 4,
  });
}

const List<SharedDirect3DCatalogEntry> sharedDirect3DCatalogEntries = [
  SharedDirect3DCatalogEntry(
    id: 'f0593_sierpinski_tetrahedron_3d',
    name: 'Sierpinski Tetrahedron 3D',
    shaderAsset:
        'shaders/ifs_and_geometric/raymarched_3d/kifs_sierpinski_tetra_gpu.frag',
    maxPower: 3,
  ),
  SharedDirect3DCatalogEntry(
    id: 'f0598_3d_koch_snowflake',
    name: '3D Koch Snowflake',
    shaderAsset:
        'shaders/ifs_and_geometric/raymarched_3d/kifs_koch_fold_gpu.frag',
  ),
];

List<FractalModule> buildSharedDirect3DCatalogModules() =>
    sharedDirect3DCatalogEntries
        .map((entry) => buildRaymarched3DModule(Raymarched3DConfig(
              id: entry.id,
              name: entry.name,
              shaderAsset: entry.shaderAsset,
              category: '3D Fractals',
              defaultPower: entry.defaultPower,
              minPower: 1.5,
              maxPower: entry.maxPower,
              powerLabel: 'Scale',
              defaultIterations: 10,
              maxIterations: 20,
              defaultSteps: 120,
              defaultBailout: 4,
            )))
        .toList(growable: false);
