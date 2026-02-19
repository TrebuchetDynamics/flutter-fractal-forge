import 'package:flutter_fractals/core/models/fractal_parameter.dart';
import 'package:flutter_fractals/core/models/fractal_preset.dart';
import 'package:flutter_fractals/core/models/fractal_view_state.dart';
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
    shaderAsset: 'shaders/kifs_menger_gpu.frag',
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
      FractalPreset(
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
        createdAt: DateTime.utc(2025, 1, 1),
        isBuiltIn: true,
      ),
    ],
  ),

  Raymarched3DConfig(
    id: 'kifs_sierpinski_tetra',
    name: 'KIFS Sierpinski Tetrahedron',
    shaderAsset: 'shaders/kifs_sierpinski_tetra_gpu.frag',
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
      FractalPreset(
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
        createdAt: DateTime.utc(2025, 1, 1),
        isBuiltIn: true,
      ),
    ],
  ),

  Raymarched3DConfig(
    id: 'kifs_koch_fold',
    name: 'KIFS Koch 3D',
    shaderAsset: 'shaders/kifs_koch_fold_gpu.frag',
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
    shaderAsset: 'shaders/kifs_snowflake_fold_gpu.frag',
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
      FractalPreset(
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
        createdAt: DateTime.utc(2025, 1, 1),
        isBuiltIn: true,
      ),
    ],
  ),

  // ── Hypercomplex / Quaternion Family ──────────────────────────

  Raymarched3DConfig(
    id: 'quaternion_julia_3d',
    name: 'Quaternion Julia 3D',
    shaderAsset: 'shaders/quaternion_julia_3d_gpu.frag',
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
      FractalPreset(
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
        createdAt: DateTime.utc(2025, 1, 1),
        isBuiltIn: true,
      ),
    ],
  ),

  Raymarched3DConfig(
    id: 'dual_quaternion_julia',
    name: 'Dual-Quaternion Julia',
    shaderAsset: 'shaders/dual_quaternion_julia_gpu.frag',
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
    shaderAsset: 'shaders/mandelbox_shape_inversion_gpu.frag',
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
      FractalPreset(
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
        createdAt: DateTime.utc(2025, 1, 1),
        isBuiltIn: true,
      ),
    ],
  ),

  Raymarched3DConfig(
    id: 'inversive_limit_set_3d',
    name: 'Inversive Limit Set 3D',
    shaderAsset: 'shaders/inversive_limit_set_3d_gpu.frag',
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
      FractalPreset(
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
        createdAt: DateTime.utc(2025, 1, 1),
        isBuiltIn: true,
      ),
    ],
  ),

  Raymarched3DConfig(
    id: 'mandelbulb_time_modulated',
    name: 'Time-Modulated Mandelbulb',
    shaderAsset: 'shaders/mandelbulb_time_modulated_gpu.frag',
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
      FractalPreset(
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
        createdAt: DateTime.utc(2025, 1, 1),
        isBuiltIn: true,
      ),
    ],
  ),
];

/// Build all 3D ray-marched modules from the catalog.
List<FractalModule> buildRaymarched3DCatalogModules() {
  return raymarched3DCatalog.map(buildRaymarched3DModule).toList();
}
