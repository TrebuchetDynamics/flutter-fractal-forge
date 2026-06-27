import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
import 'package:flutter_fractals/core/modules/builders/built_in_preset_contract.dart';
import 'package:flutter_fractals/core/modules/builders/raymarched_3d_builder.dart';
import 'package:flutter_fractals/core/modules/fractal_module.dart';
import 'package:vector_math/vector_math.dart';

/// All 3D ray-marched fractals defined declaratively.
///
/// To add a new 3D ray-marched fractal:
/// 1. Write a .frag shader following the standard 3D uniform layout
///    (see raymarched_3d_builder.dart for the layout)
/// 2. Add a [Raymarched3DConfig] entry here
/// 3. Register the shader in pubspec.yaml under flutter.shaders
/// 4. Done! No new Dart file needed.

final List<Raymarched3DConfig> raymarched3DCatalog = [
  // ── KIFS (Kaleidoscopic IFS) Family ──────────────────────────

  Raymarched3DConfig(
    id: 'kifs_menger',
    name: 'KIFS Menger Sponge',
    shaderAsset: 'shaders/ifs_and_geometric/raymarched_3d/kifs_menger_gpu.frag',
    category: '3D Fractals',
    defaultPower: 3.0,
    minPower: 2.0,
    maxPower: 5.0,
    powerLabel: 'Scale',
    defaultIterations: 8,
    maxIterations: 20,
    defaultSteps: 120,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'kifs_menger-cathedral',
        moduleId: 'kifs_menger',
        name: 'Cathedral',
        params: const {
          'power': 3.0,
          'iterations': 12,
          'steps': 150,
          'bailout': 4.0,
          'colorScheme': 1,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 2.0,
          rotation: Vector3(0.5, 0.3, 0.0),
        ),
      ),
    ],
  ),

  Raymarched3DConfig(
    id: 'kifs_sierpinski_tetra',
    name: 'KIFS Sierpinski Tetrahedron',
    shaderAsset:
        'shaders/ifs_and_geometric/raymarched_3d/kifs_sierpinski_tetra_gpu.frag',
    category: '3D Fractals',
    defaultPower: 2.0,
    minPower: 1.5,
    maxPower: 3.0,
    powerLabel: 'Scale',
    defaultIterations: 10,
    maxIterations: 20,
    defaultSteps: 120,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'kifs_sierpinski_tetra-crystal',
        moduleId: 'kifs_sierpinski_tetra',
        name: 'Crystal Pyramid',
        params: const {
          'power': 2.0,
          'iterations': 14,
          'steps': 150,
          'bailout': 4.0,
          'colorScheme': 2,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.5,
          rotation: Vector3(0.4, 0.6, 0.0),
        ),
      ),
    ],
  ),

  Raymarched3DConfig(
    id: 'kifs_koch_fold',
    name: 'KIFS Koch 3D',
    shaderAsset:
        'shaders/ifs_and_geometric/raymarched_3d/kifs_koch_fold_gpu.frag',
    category: '3D Fractals',
    defaultPower: 2.0,
    minPower: 1.5,
    maxPower: 4.0,
    powerLabel: 'Scale',
    defaultIterations: 10,
    maxIterations: 20,
    defaultSteps: 120,
    defaultBailout: 4.0,
  ),

  Raymarched3DConfig(
    id: 'kifs_snowflake_fold',
    name: 'KIFS Snowflake 3D',
    shaderAsset:
        'shaders/ifs_and_geometric/raymarched_3d/kifs_snowflake_fold_gpu.frag',
    category: '3D Fractals',
    defaultPower: 3.0,
    minPower: 2.0,
    maxPower: 5.0,
    powerLabel: 'Scale',
    defaultIterations: 8,
    maxIterations: 20,
    defaultSteps: 120,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'kifs_snowflake_fold-ice',
        moduleId: 'kifs_snowflake_fold',
        name: 'Ice Crystal',
        params: const {
          'power': 3.0,
          'iterations': 12,
          'steps': 140,
          'bailout': 4.0,
          'colorScheme': 1,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.8,
          rotation: Vector3(0.3, 0.5, 0.1),
        ),
      ),
    ],
  ),

  // ── Hypercomplex / Quaternion Family ──────────────────────────

  Raymarched3DConfig(
    id: 'quaternion_julia_3d',
    name: 'Quaternion Julia 3D',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/quaternion_julia_3d_gpu.frag',
    category: '3D Fractals',
    defaultPower: 2.0,
    minPower: 1.0,
    maxPower: 5.0,
    powerLabel: 'C Magnitude',
    defaultIterations: 20,
    maxIterations: 50,
    defaultSteps: 120,
    defaultBailout: 4.0,
    defaultFractalType: 0,
    maxFractalType: 3,
    fractalTypeOptions: [
      FractalParamOption(value: 0, label: (_) => 'Classic'),
      FractalParamOption(value: 1, label: (_) => 'Organic'),
      FractalParamOption(value: 2, label: (_) => 'Crystalline'),
      FractalParamOption(value: 3, label: (_) => 'Spiral'),
    ],
    extraPresets: [
      catalogPreset(
        id: 'quaternion_julia_3d-organic',
        moduleId: 'quaternion_julia_3d',
        name: 'Organic Shell',
        params: const {
          'power': 2.0,
          'iterations': 25,
          'steps': 140,
          'bailout': 4.0,
          'colorScheme': 1,
          'fractalType': 1,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.5,
          rotation: Vector3(0.4, 0.2, 0.0),
        ),
      ),
    ],
  ),

  Raymarched3DConfig(
    id: 'dual_quaternion_julia',
    name: 'Dual-Quaternion Julia',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/dual_quaternion_julia_gpu.frag',
    category: '3D Fractals',
    defaultPower: 1.0,
    minPower: 0.1,
    maxPower: 3.0,
    powerLabel: 'Dual Coupling',
    defaultIterations: 20,
    maxIterations: 50,
    defaultSteps: 120,
    defaultBailout: 4.0,
  ),

  // ── Exotic 3D Family ──────────────────────────

  Raymarched3DConfig(
    id: 'mandelbox_shape_inversion',
    name: 'Mandelbox Shape Inversion',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbox_shape_inversion_gpu.frag',
    category: '3D Fractals',
    defaultPower: 2.0,
    minPower: 1.5,
    maxPower: 3.5,
    powerLabel: 'Scale',
    defaultIterations: 15,
    maxIterations: 40,
    defaultSteps: 100,
    defaultBailout: 8.0,
    defaultFractalType: 0,
    maxFractalType: 3,
    fractalTypeOptions: [
      FractalParamOption(value: 0, label: (_) => 'Sphere'),
      FractalParamOption(value: 1, label: (_) => 'Cube'),
      FractalParamOption(value: 2, label: (_) => 'Torus'),
      FractalParamOption(value: 3, label: (_) => 'Octahedron'),
    ],
    extraPresets: [
      catalogPreset(
        id: 'mandelbox_shape_inversion-torus',
        moduleId: 'mandelbox_shape_inversion',
        name: 'Toroidal Fold',
        params: const {
          'power': 2.0,
          'iterations': 18,
          'steps': 120,
          'bailout': 8.0,
          'colorScheme': 2,
          'fractalType': 2,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.3,
          rotation: Vector3(0.5, 0.3, 0.0),
        ),
      ),
    ],
  ),

  Raymarched3DConfig(
    id: 'inversive_limit_set_3d',
    name: 'Inversive Limit Set 3D',
    shaderAsset:
        'shaders/ifs_and_geometric/raymarched_3d/inversive_limit_set_3d_gpu.frag',
    category: '3D Fractals',
    defaultPower: 1.4,
    minPower: 1.0,
    maxPower: 2.0,
    powerLabel: 'Sphere Radius',
    defaultIterations: 20,
    maxIterations: 50,
    defaultSteps: 120,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'inversive_limit_set_3d-pearls',
        moduleId: 'inversive_limit_set_3d',
        name: 'Pearl Necklace',
        params: const {
          'power': 1.35,
          'iterations': 30,
          'steps': 150,
          'bailout': 4.0,
          'colorScheme': 1,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 2.0,
          rotation: Vector3(0.3, 0.5, 0.0),
        ),
      ),
    ],
  ),

  Raymarched3DConfig(
    id: 'mandelbulb_time_modulated',
    name: 'Time-Modulated Mandelbulb',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/mandelbulb_time_modulated_gpu.frag',
    category: '3D Fractals',
    defaultPower: 8.0,
    minPower: 2.0,
    maxPower: 12.0,
    powerLabel: 'Power',
    defaultIterations: 50,
    maxIterations: 100,
    defaultSteps: 120,
    defaultBailout: 2.0,
    extraPresets: [
      catalogPreset(
        id: 'mandelbulb_time_modulated-breathing',
        moduleId: 'mandelbulb_time_modulated',
        name: 'Breathing Form',
        params: const {
          'power': 7.0,
          'iterations': 60,
          'steps': 140,
          'bailout': 2.0,
          'colorScheme': 2,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.8,
          rotation: Vector3(0.4, 0.3, 0.1),
        ),
      ),
    ],
  ),

  Raymarched3DConfig(
    id: 'amazing_box',
    name: 'Amazing Box',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/amazing_box_gpu.frag',
    category: '3D Fractals',
    defaultPower: 2.0,
    minPower: 1.6,
    maxPower: 3.2,
    powerLabel: 'Fold Scale',
    defaultIterations: 16,
    maxIterations: 32,
    defaultSteps: 120,
    defaultBailout: 6.0,
    extraPresets: [
      catalogPreset(
        id: 'amazing_box-compact',
        moduleId: 'amazing_box',
        name: 'Compact Wirebox',
        params: const {
          'power': 2.25,
          'iterations': 18,
          'steps': 140,
          'bailout': 6.0,
          'colorScheme': 1,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.4,
          rotation: Vector3(0.45, 0.35, 0.0),
        ),
      ),
    ],
  ),

  Raymarched3DConfig(
    id: 'bulbils',
    name: 'Bulbils',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/bulbils_gpu.frag',
    category: '3D Fractals',
    defaultPower: 6.0,
    minPower: 3.0,
    maxPower: 10.0,
    powerLabel: 'Bulb Power',
    defaultIterations: 18,
    maxIterations: 50,
    defaultSteps: 120,
    defaultBailout: 4.0,
    extraPresets: [
      catalogPreset(
        id: 'bulbils-cluster',
        moduleId: 'bulbils',
        name: 'Bulbil Cluster',
        params: const {
          'power': 7.0,
          'iterations': 24,
          'steps': 140,
          'bailout': 4.0,
          'colorScheme': 2,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.5,
          rotation: Vector3(0.35, -0.45, 0.1),
        ),
      ),
    ],
  ),

  Raymarched3DConfig(
    id: 'hartverdrahtet',
    name: 'Hartverdrahtet',
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/hartverdrahtet_gpu.frag',
    category: '3D Fractals',
    defaultPower: 2.2,
    minPower: 1.4,
    maxPower: 3.6,
    powerLabel: 'Wire Scale',
    defaultIterations: 18,
    maxIterations: 40,
    defaultSteps: 120,
    defaultBailout: 5.0,
  ),

  Raymarched3DConfig(
    id: 'tglad_formula',
    name: "Tglad's Formula",
    shaderAsset:
        'shaders/3d_and_hypercomplex/raymarched_volumes/tglad_formula_gpu.frag',
    category: '3D Fractals',
    defaultPower: 2.1,
    minPower: 1.6,
    maxPower: 3.4,
    powerLabel: 'Fold Scale',
    defaultIterations: 18,
    maxIterations: 40,
    defaultSteps: 120,
    defaultBailout: 5.0,
  ),

  // ── Mandelbulb Family ──────────────────────────

  Raymarched3DConfig(
    id: 'mandelbulb',
    name: 'Mandelbulb',
    shaderAsset: 'shaders/legacy/raymarched_3d/mandelbulb.frag',
    category: '3D Fractals',
    defaultPower: 8.0,
    minPower: 2.0,
    maxPower: 12.0,
    powerLabel: 'Power',
    defaultIterations: 50,
    maxIterations: 100,
    defaultSteps: 120,
    defaultBailout: 2.0,
    defaultFractalType: 0,
    maxFractalType: 1,
    fractalTypeOptions: [
      FractalParamOption(value: 0, label: (_) => 'Mandelbulb'),
      FractalParamOption(value: 1, label: (_) => 'Mandelbox'),
    ],
    extraPresets: [
      catalogPreset(
        id: 'mandelbulb-classic',
        moduleId: 'mandelbulb',
        name: 'Classic Bulb',
        params: const {
          'power': 8.0,
          'iterations': 50,
          'steps': 120,
          'bailout': 2.0,
          'colorScheme': 0,
          'fractalType': 0,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.5,
          rotation: Vector3(0.3, -0.4, 0.0),
        ),
      ),
      catalogPreset(
        id: 'mandelbulb-spiky',
        moduleId: 'mandelbulb',
        name: 'Spiky Variant',
        params: const {
          'power': 10.0,
          'iterations': 60,
          'steps': 140,
          'bailout': 2.0,
          'colorScheme': 2,
          'fractalType': 0,
        },
        view: FractalViewState(
          pan: Vector2.zero(),
          zoom: 1.8,
          rotation: Vector3(0.5, 0.2, 0.1),
        ),
      ),
    ],
  ),
];

/// Build all 3D ray-marched modules from the catalog.
List<FractalModule> buildRaymarched3DCatalogModules() {
  return raymarched3DCatalog.map(buildRaymarched3DModule).toList();
}
